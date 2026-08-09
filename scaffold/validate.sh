#!/usr/bin/env bash
#
# validate.sh - validátor integrity scaffoldovaného projektu NSL Dark Factory
#
# Verze platformy má jediný domov: scaffold/VERSION. Tenhle soubor ji čte, nikdy nedrží
# vlastní kopii čísla - synchronizace verze ve třech souborech selže při prvním spěchu.
#
# Použití:
#   ./validate.sh <cesta-k-projektu>              # režim studio (default)
#   ./validate.sh <cesta-k-projektu> --tenant     # režim tenant
#   ./validate.sh --baseline <cesta-k-jednotce>   # režim baseline (fronta changesetů)
#
# Kontroluje soulad projektu s platformními normami (OR-03, OR-06, OR-10, AR-12).
# Výstup: per kontrola PASS/FAIL s vysvětlením. Exit 0 jen když vše PASS, jinak exit 1.
#
# Režim baseline je nezávislý na kontrolách integrity scaffoldu (B-065): počítá frontu
# nepřevzatých platformních changesetů pro jednu jednotku a umí po PASS testu zapsat
# převzetí do její baseline. Do baseline zapisuje JEN tenhle nástroj a JEN po PASS.
#
# KONTRAKT STROJOVÉHO ŘÁDKU (režim --baseline). Stálý, smí na něm stavět skill,
# orchestrátor i čtecí vrstva portfolia. Kanonický text: operations/changesets/README.md, sekce
# "Nástroj"; tady je jen tolik, aby to viděl každý, kdo sahá do tohohle souboru.
#
#   1. PRVNÍ řádek standardního výstupu je vždycky řádek "BASELINE ...", a to na KAŽDÉ
#      cestě kódu včetně chybových (nenalezená META, chybějící parser). Nic se před něj
#      netiskne - proto se v tomhle režimu netiskne ani úvodní hlavička "Validace: ...".
#   2. Pole se čtou jako klíč=hodnota, NE podle pozice. Přidat pole je aditivní změna,
#      odebrat nebo přejmenovat je rozbití kontraktu (MAJOR).
#   3. Diagnostika a chybové hlášky jdou na stderr, nikdy na stdout před strojový řádek.
#   4. S --line je ten řádek jediný výstup na stdout.
#   5. Návratové kódy: 0 aktuální nebo pozadu, 1 regrese nebo blokující ve frontě,
#      3 nezjištěno, 2 chyba použití.
#
# Kontrakt hlídá průchodem scaffold/tests/strojovy-radek.sh. Bez testu je to vlastnost
# implementace, kterou může kdokoli nevědomky rozbít - a čtečka pak tiše přestane číst.
#
# POSIX-friendly bash, kompatibilní s macOS (BSD grep/sed/awk). Bez GNU rozšíření.

set -u

PASS_N=0
FAIL_N=0

WARN_N=0
NA_N=0

ok()   { PASS_N=$((PASS_N + 1)); printf 'PASS  %s\n' "$1"; }
ko()   { FAIL_N=$((FAIL_N + 1)); printf 'FAIL  %s\n' "$1"; }
warn() { WARN_N=$((WARN_N + 1)); printf 'WARN  %s\n' "$1"; }
# Čtvrtý výsledek, ne třetí odstín druhého. "Netýká se mě" a "selhalo" jsou dva různé
# stavy a nesmí splynout - stejné rozlišení, jaké režim baseline dělá u SKIP proti FAIL.
# n/a má vlastní kolonku v souhrnu, aby se neschovalo do nuly.
na()   { NA_N=$((NA_N + 1)); printf 'n/a   %s\n' "$1"; }

usage() {
  cat <<'EOF'
Použití: ./validate.sh <cesta-k-projektu> [--tenant]
         ./validate.sh --baseline <cesta-k-jednotce> [--line]
         ./validate.sh --baseline <cesta-k-jednotce> --verify <ID>
         ./validate.sh --baseline <cesta-k-jednotce> --accept <ID> [--kdo <jméno>]
                       [--force --duvod "<věta>"]

  <cesta-k-projektu>   kořen scaffoldovaného projektu (studio nebo tenant)
  --tenant             validovat jako tenant vrstvu (jinak studio)
  --baseline           režim fronty platformních changesetů (osa A, B-065)
  --line               jen strojově čitelný první řádek (pro čtecí vrstvu portfolia)
  --verify <ID>        vyhodnotit testy jednoho changesetu, nic nezapsat
  --accept <ID>        zapsat převzetí do baseline jednotky; jen po PASS všech testů
  --kdo <jméno>        kdo převzetí provedl (sloupec Kdo v evidenci)
  --force --duvod ...  vynucené převzetí při NEZJISTENO; důvod je povinný a zapíše se
  -h, --help           tato nápověda

Režim studio kontroluje: (a) CLAUDE.md + Klasifikace (z CLAUDE.md, CLAUDE.local.md
nebo OR-03 headeru status.md), (b) OR-03 header, (c) OR-10 header bez řetězení historie,
(d) OR-06 číslování team-outcomes, (e) AR-12 identita agentů (rendered artefakt /
overlay / tenant-specific / zakázaný fork), (f) AR-12 overlay pointer + self-contained
rendered artefakt, (g) frontmatter sanity + shoda rendered artefaktu s manifestem,
(h) OR-03 pole Slouží: (osa mandátu; chybějící pole WARN do dokončení backfillu,
hodnota mimo uzavřený obor FAIL vždy).

Pole hlavičky se čtou z DEKLARACE - z řádku, který začíná `**<Pole>:**`. Zmínka jména
pole v próze uvnitř hlavičky (i v obráceném apostrofu) se ignoruje, hodnotu neurčuje
a do počtu polí se nepočítá. Průchod: scaffold/tests/hlavicka-deklarace-pole.sh.

Režim tenant kontroluje totéž pole jako (t6) - harness je jednotka jako každá jiná.

Identita souboru v .claude/agents/ se odvozuje z render-manifest.json (pokud existuje).
Bez manifestu se chování nemění oproti dřívějšku.

Režim tenant kontroluje existenci: CLAUDE.md, team-inbox/, escalations/, portfolio-status.md.

Předmětem tohohle skriptu je JEDNA jednotka nebo tenant harness. Strukturu celého
workspace tenant platformy (pilíře, jednotky v nich, manifest) validuje samostatný
scaffold/workspace/validate-workspace.sh - jiný předmět, jiný nástroj.

Režim baseline počítá frontu nepřevzatých changesetů (operations/changesets/ v METĚ)
proti baseline jednotky (operations/platform-baseline.md) a u převzatých spouští
verifikační test proti profilu jednotky. Profil se detekuje za běhu; neaplikovatelná
vrstva se přeskočí, nespadne. Zdroj changesetů: $NSL_META_ROOT, jinak kořen odvozený
od umístění tohoto skriptu.
EOF
}

# --- parsování argumentů ---------------------------------------------------
MODE="studio"
PROJ=""
BASELINE_LINE=0
ACCEPT_ID=""
VERIFY_ID=""
ACCEPT_WHO=""
FORCE=0
FORCE_REASON=""

need_value() { # <přepínač> <počet zbývajících argumentů>
  if [ "$2" -lt 2 ]; then
    printf 'Přepínač %s vyžaduje hodnotu.\n' "$1" >&2
    exit 2
  fi
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --tenant)   MODE="tenant" ;;
    --baseline) MODE="baseline" ;;
    --line)     BASELINE_LINE=1 ;;
    --force)    FORCE=1 ;;
    --accept)   need_value "$1" "$#"; shift; ACCEPT_ID="$1" ;;
    # --take je zastaralý alias --accept (návrh B-065 ho nesl dřív, než padlo rozhodnutí
    # o pojmenování). Ohlášeno ve scaffold 2.1.0, odstranění nejdřív ve scaffold 3.0.0.
    --take)     need_value "$1" "$#"; shift; ACCEPT_ID="$1"
                printf 'Poznámka: --take je zastaralý alias --accept (odstranění ve scaffold 3.0.0).\n' >&2 ;;
    --verify)   need_value "$1" "$#"; shift; VERIFY_ID="$1" ;;
    --kdo)      need_value "$1" "$#"; shift; ACCEPT_WHO="$1" ;;
    --duvod)    need_value "$1" "$#"; shift; FORCE_REASON="$1" ;;
    -h|--help)  usage; exit 0 ;;
    -*) printf 'Neznámý přepínač: %s\n' "$1" >&2; usage >&2; exit 2 ;;
    *)
      if [ -n "$PROJ" ]; then
        printf 'Zadej právě jednu cestu k projektu (druhá: %s).\n' "$1" >&2
        exit 2
      fi
      PROJ="$1"
      ;;
  esac
  shift
done

if [ -z "$PROJ" ]; then
  printf 'Chybí cesta k projektu.\n\n' >&2
  usage >&2
  exit 2
fi
if [ ! -d "$PROJ" ]; then
  printf 'Cesta neexistuje nebo není adresář: %s\n' "$PROJ" >&2
  exit 2
fi

# odstranit případné koncové lomítko pro čitelnější výstup
PROJ="${PROJ%/}"
AGENTS_GLOBAL="$HOME/.claude/agents"

# --- hranice repa ----------------------------------------------------------
#
# Tenhle validátor se ptá gitu VŽDYCKY do cizího repa: jednotka i platform library leží
# jinde než adresář, ze kterého ho kdo spustil. Když ho spustí něco, co samo běží pod
# gitem (hook, wrapper, budoucí CI krok), zděděné GIT_INDEX_FILE nebo GIT_DIR ta volání
# přesměruje do repa spouštěče. Výsledek není chyba, ale tichá lež: rendered artefakty
# vypadají jako untracked a do baseline se zapíše cizí SHA. Detail v knihovně.
#
# Fallback bez knihovny je vědomě konzervativní - čisté prostředí, ne "git -C jak dřív".
LIB_GIT_PROSTREDI=""
for cand in "$(dirname "$0")/lib/git-prostredi.sh" \
            "${NSL_META_ROOT:-}/scaffold/lib/git-prostredi.sh"; do
  case "$cand" in /scaffold/lib/*) continue ;; esac
  [ -f "$cand" ] && { LIB_GIT_PROSTREDI="$cand"; break; }
done
if [ -n "$LIB_GIT_PROSTREDI" ]; then
  # shellcheck source=lib/git-prostredi.sh
  . "$LIB_GIT_PROSTREDI"
else
  git_cizi() {
    gc_repo="$1"; shift
    ( unset GIT_INDEX_FILE GIT_DIR GIT_WORK_TREE GIT_OBJECT_DIRECTORY \
            GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_COMMON_DIR GIT_NAMESPACE GIT_PREFIX
      exec git -C "$gc_repo" "$@" )
  }
fi

# V režimu baseline je první řádek výstupu strojově čitelný kontrakt (viz KONTRAKT
# STROJOVÉHO ŘÁDKU v hlavičce souboru) - úvodní hlavička by ho rozbila. Cokoli, co by
# se sem doplnilo, musí jít na stderr, nebo až za strojový řádek.
if [ "$MODE" != "baseline" ]; then
  printf 'Validace: %s\n' "$PROJ"
  printf 'Režim:    %s\n\n' "$MODE"
fi

# --- pomocné funkce --------------------------------------------------------

# Extrahuje YAML frontmatter agent filu: řádky mezi prvním a druhým "---".
extract_frontmatter() {
  awk 'NR==1 && /^---[[:space:]]*$/ {f=1; next} f && /^---[[:space:]]*$/ {exit} f' "$1"
}

# Extrahuje OR-03 header: vše od začátku status.md po hranici header/rolling-log.
# Hranicí je PRVNÍ z: samostatný řádek "---" NEBO první nadpis úrovně H2 ("## ...").
# Důvod dvou hranic: NSL styl zakazuje horizontální dividery "---" v Markdown obsahu,
# takže konformní šablona odděluje header od rolling logu nadpisem "## Rolling log",
# ne řádkem "---". Starší soubory (META) používají "---". Validátor musí zvládnout obě.
# Bez rozpoznání H2 hranice by header pohltil i rolling log (a jeho instrukční komentář),
# což falešně shodí kontrolu (c) OR-10.
extract_header() {
  awk 'BEGIN{h=1} /^---[[:space:]]*$/{h=0} /^##[[:space:]]/{h=0} h==1{print}' "$1"
}

# --- deklarace pole vs. zmínka o poli (oprava 2026-08-09) -------------------
#
# Hodnota pole hlavičky se čte VÝHRADNĚ z řádku, který deklarací začíná:
#
#   **Slouží:** Dark Factory              <- deklarace, tohle je zdroj hodnoty
#   **Last update:** ... pole `Slouží:` ..  <- zmínka v próze, ignoruje se
#
# Do 2.12.0 se hodnota brala z prvního výskytu řetězce "<Pole>:" kdekoli v hlavičce.
# Stačilo o poli v hlavičce napsat větu - a validátor přečetl zbytek té věty jako
# hodnotu pole. Naměřeno hned první den na METĚ: hlavička zapsaná správně, kontrola (h)
# FAIL, protože hodnotu vzala z věty v `Last update`. Obejít se to dá přeformulováním
# té věty, jenže tím past zůstane nastražená pro každého dalšího, kdo o poli napíše.
#
# Vada je v přístupu, ne v jednom poli, proto tenhle pár funkcí používají všechny
# kontroly, které pole hlavičky čtou nebo počítají: (a) třetí zdroj, (b), (h), (t5), (t6).
#
# Tvar deklarace: řádek začíná `**`, jménem pole, volitelným upřesněním bez hvězdičky
# (v provozu existuje `**Next milestone (aktualizováno 3.8. 22:30):**`) a `:**`.
# Odrážka ani odsazení se nepřipouští - hlavička per OR-03 má pole na začátku řádku
# a položky odrážkových seznamů pod `Aktivní úkoly` nesmí jít omylem přečíst jako pole.
radek_pole() { # <text hlavičky> <název pole> - první deklarační řádek, jinak prázdno
  printf '%s\n' "$1" | grep -E "^\*\*$2[^*]*:\*\*" | head -1
}

hodnota_pole() { # <text hlavičky> <název pole> - hodnota z deklaračního řádku
  printf '%s' "$(radek_pole "$1" "$2")" \
    | sed -e 's/^\*\*[^*]*:\*\*//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

# Táž hranice pro soubor psaný volnou formou (CLAUDE.md, CLAUDE.local.md), kde je
# kanonický tvar deklarace odrážka: `- **Klasifikace:** Internal`. Sama zmínka jména
# pole - výklad normy, hlavička tabulky, nadpis sekce - deklarace není a nesmí se za ni
# vydávat: kontrola (a) pak hlásí zdroj, ve kterém hodnota fakticky není.
#
# Blok kódu je ukázka, ne fakt. `CLAUDE.md` METY nese v oploceném bloku celou šablonu
# OR-03 hlavičky včetně řádku `**Klasifikace:** META | Internal | Client | Personal` -
# tedy výčet možností, ne klasifikaci té jednotky. Bez tohohle filtru kontrola (a) hlásí
# jako zdroj soubor, ve kterém žádná hodnota není, a skutečný zdroj (hlavička status.md)
# se nikdy nezkusí.
deklaruje_pole() { # <soubor> <název pole> - 0 když soubor nese deklaraci pole
  [ -f "$1" ] || return 1
  awk 'BEGIN{f=0} /^[[:space:]]*(```|~~~)/ {f=!f; next} f==0 {print}' "$1" \
    | grep -qE "^([-*+][[:space:]]+)?\*\*$2[^*]*:\*\*"
}

# Zmínka v obráceném apostrofu je jméno pole, ne jeho použití. Kontroly, které hledají
# ZAKÁZANÝ tvar uvnitř řádku (a proto se na začátek řádku ukotvit nedají - viz (c)),
# si textem prohnaným tímhle filtrem drží totéž rozlišení deklarace vs. zmínka.
bez_zminek() { # <text> - text bez obsahu inline code spanů
  printf '%s\n' "$1" | sed -e 's/`[^`]*`//g'
}

# --- pole Slouží: (OR-03, osa mandátu, 2026-08-09) --------------------------
#
# Osa mandátu (komu jednotka slouží a odkud bere mandát) je nezávislá na ose správy
# USER / META / TENANT / STUDIO per AR-05: jednotka může být vrcholem jedné a listem
# druhé. Bez pole to čtecí vrstva portfolia nedokáže odlišit od chyby dat a mandátovou
# osu zobrazí prázdnou.
#
# Přísnost brány má jeden domov: konstanta SLOUZI_GATE. "warn" znamená, že chybějící
# pole jen svítí, "fail" že shodí bránu. Zpřísnění je jednořádková změna s changesetem
# a spouští ho jediná měřitelná podmínka: NULA jednotek s nepřevzatým changesetem
# 2026-08-09-osa-mandatu-a-hranice-zadani ve frontě, měřeno napříč jednotkami přes
# `validate.sh --baseline <jednotka> --line`. Do té doby by "fail" znamenal trvale
# červenou bránu u všech jednotek naráz - a brána, kterou nikdo nemůže odbavit, se
# přestane číst celá, včetně kontrol, které s tímhle polem nemají nic společného.
#
# Před překlopením konstanty musí padnout ještě jedno rozhodnutí, ať se neobjeví až po
# něm: jednotka nasazená v klientském pracovním prostoru má hlavičku v souboru, který
# vlastní klient, a NSL taxonomie ekosystému do něj nepatří (tatáž hranice jako
# AR-12 revize v3). Buď dostane n/a, nebo se pro ni pole nezavádí. Dnes je to
# bezpředmětné, protože chybějící pole jen varuje, a proto ho klientská šablona nenese.
#
# Hodnota MIMO uzavřený obor je FAIL od prvního dne a nezávisle na konstantě: špatná
# hodnota je horší než žádná, protože se tváří jako změřený fakt. Týmž pravidlem se
# vynucuje i "právě jedna hodnota" - dvě hodnoty na jednom řádku se do oboru netrefí.
SLOUZI_GATE="warn"
SLOUZI_HODNOTY='NorthStar Lab|Dark Factory|žádná'

slouzi_zna() { # <hodnota> - 0 když je v uzavřeném oboru
  _sz_zbytek="$SLOUZI_HODNOTY"
  while [ -n "$_sz_zbytek" ]; do
    _sz_prvni="${_sz_zbytek%%|*}"
    [ "$1" = "$_sz_prvni" ] && return 0
    [ "$_sz_zbytek" = "$_sz_prvni" ] && break
    _sz_zbytek="${_sz_zbytek#*|}"
  done
  return 1
}

check_slouzi() { # <text OR-03 headeru> <značka kontroly, např. "(h)">
  _cs_radek="$(radek_pole "$1" "Slouží")"
  _cs_val="$(hodnota_pole "$1" "Slouží")"
  _cs_zn="$2"
  if [ -z "$_cs_radek" ] || [ -z "$_cs_val" ] || [ "${_cs_val#\{\{}" != "$_cs_val" ]; then
    if [ -z "$_cs_radek" ]; then _cs_co="pole chybí"; else _cs_co="pole je nevyplněné"; fi
    if [ "$SLOUZI_GATE" = "fail" ]; then
      ko "$_cs_zn OR-03 pole Slouží: $_cs_co - doplň hodnotu z oboru: $SLOUZI_HODNOTY"
    else
      warn "$_cs_zn OR-03 pole Slouží: $_cs_co - doplň hodnotu z oboru ($SLOUZI_HODNOTY); do dokončení backfillu jen varování, hodnotu vybírá orchestrátor jednotky"
    fi
  elif slouzi_zna "$_cs_val"; then
    ok "$_cs_zn OR-03 pole Slouží: \"$_cs_val\" je z uzavřeného oboru"
  else
    ko "$_cs_zn OR-03 pole Slouží: hodnota \"$_cs_val\" není v uzavřeném oboru ($SLOUZI_HODNOTY); právě jedna hodnota, volný text je nevalidní zápis"
  fi
}

# ===========================================================================
# REŽIM BASELINE - fronta platformních changesetů (B-065, osa A)
# ===========================================================================
#
# Odpovídá na dvě otázky: "na jaké verzi platformy tahle jednotka stojí" a "co jí uteklo".
# Model fronty je hybrid evidence a stavu (rozhodnutí oponentury Quentina META 3. 8. 2026):
# k seznamu převzatých ID se při každém reportu doplní výsledek testů, takže se pozná
# i regrese - changeset evidovaný jako převzatý, jehož test dnes neprochází.
#
# Do baseline zapisuje JEN tenhle nástroj a JEN po PASS. Ruční editace baseline je
# porušení disciplíny na úrovni ručního přepsání rendered artefaktu.
if [ "$MODE" = "baseline" ]; then
  NL='
'
  SELF_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"
  # Slug se odvozuje z ABSOLUTNÍ cesty. Relativní zápis (`--baseline .`) by jinak dal
  # slug "." a filtr `Týká se: jen: <slug>` by přestal odpovídat - jednotka by tiše
  # vypadla z rozsahu changesetu, který je adresovaný právě jí.
  SLUG="$(basename "$(cd "$PROJ" 2>/dev/null && pwd || printf '%s' "$PROJ")")"

  # --- kde leží META s changesety ---
  META_ROOT=""
  for cand in "${NSL_META_ROOT:-}" "${SELF_DIR%/scaffold}"; do
    [ -n "$cand" ] || continue
    if [ -d "$cand/operations/changesets" ]; then META_ROOT="$cand"; break; fi
  done

  # --- knihovna parseru ---
  LIB=""
  for cand in "$SELF_DIR/lib/changeset.sh" "$META_ROOT/scaffold/lib/changeset.sh"; do
    [ -n "$cand" ] || continue
    if [ -f "$cand" ]; then LIB="$cand"; break; fi
  done

  if [ -z "$META_ROOT" ] || [ -z "$LIB" ]; then
    printf 'BASELINE jednotka=%s stav=nezjisteno lag=0 regrese=0 nezjisteno=1 blokujici=0 vadne=0 platforma=nezjisteno platforma_meta=nezjisteno profil=nezjisteno\n' "$SLUG"
    if [ -z "$META_ROOT" ]; then
      printf 'META s adresářem operations/changesets/ se na tomhle stroji nenašla. Nastav NSL_META_ROOT, nebo spusť validátor z klonu METY.\n' >&2
    else
      printf 'Chybí knihovna scaffold/lib/changeset.sh - bez parseru se fronta spočítat nedá.\n' >&2
    fi
    exit 3
  fi

  # shellcheck source=lib/changeset.sh
  . "$LIB"

  CS_DIR="$META_ROOT/operations/changesets"
  # Verze platformy má jediný domov (scaffold/VERSION v METĚ). Do strojového řádku jde
  # vedle verze zapsané v baseline, protože to jsou dvě různé věci: "co jednotka převzala"
  # a "kde je platforma teď". Bez druhého čísla vypadá starší baseline jako aktuální stav.
  META_PLATFORM="$(head -1 "$META_ROOT/scaffold/VERSION" 2>/dev/null | tr -d '[:space:]')"
  [ -n "$META_PLATFORM" ] || META_PLATFORM="nezjisteno"
  PROFILE="$(cs_unit_profile "$PROJ")"
  KINDS="$(cs_unit_kinds "$PROJ")"
  BASELINE_MD="$(cs_baseline_file "$PROJ")"
  TAKEN_IDS=" $(cs_baseline_ids "$PROJ" | tr '\n' ' ')"
  BASE_PLATFORM="$(cs_baseline_field "$PROJ" 'Platforma')"
  # Nevyplněná šablona ({{VERZE}}) není verze - do strojového řádku patří nezjisteno,
  # jinak by čtecí vrstva portfolia reportovala placeholder jako běžící verzi platformy.
  case "$BASE_PLATFORM" in ''|*'{{'*) BASE_PLATFORM="nezjisteno" ;; esac

  cs_pl_test() { case "$1" in 1) printf 'test' ;; 2|3|4) printf 'testy' ;; *) printf 'testů' ;; esac; }
  cs_pl_neprosel() { case "$1" in 1) printf 'neprošel' ;; 2|3|4) printf 'neprošly' ;; *) printf 'neprošlo' ;; esac; }
  cs_pl_skoncil() { case "$1" in 1) printf 'skončil' ;; 2|3|4) printf 'skončily' ;; *) printf 'skončilo' ;; esac; }

  in_baseline() { case "$TAKEN_IDS" in *" $1 "*) return 0 ;; esac; return 1; }

  # --- projdi changesety -----------------------------------------------------
  N_CS=0; N_MIMO=0; N_PREVZATO=0; N_CEKA=0; N_REGRESE=0; N_NEAPLIK=0
  N_NEZJISTENO=0; N_BLOKUJICI=0; N_VADNE=0
  Q_CEKA=""; Q_REGRESE=""; Q_NEZJ=""; Q_VADNE=""
  SINGLE_ID=""; SINGLE_RES=""; SINGLE_STATE=""; SINGLE_PASS=0; SINGLE_FAIL=0; SINGLE_UNK=0; SINGLE_SKIP=0

  TARGET_ID=""
  if [ -n "$ACCEPT_ID" ] && [ -n "$VERIFY_ID" ]; then
    printf 'Zadej buď --accept, nebo --verify, ne obojí.\n' >&2
    exit 2
  fi
  [ -n "$ACCEPT_ID" ] && TARGET_ID="$ACCEPT_ID"
  [ -n "$VERIFY_ID" ] && TARGET_ID="$VERIFY_ID"

  shopt -s nullglob 2>/dev/null || true
  for f in "$CS_DIR"/*.md; do
    base="$(basename "$f")"
    [ "$base" = "README.md" ] && continue
    CS_ID="${base%.md}"
    N_CS=$((N_CS + 1))

    PROBLEMS="$(cs_header_problems "$f")"
    if [ -n "$PROBLEMS" ]; then
      N_VADNE=$((N_VADNE + 1))
      Q_VADNE="$Q_VADNE  $CS_ID - $PROBLEMS$NL"
      continue
    fi

    if ! cs_scope_matches "$f" "$SLUG" "$KINDS"; then
      N_MIMO=$((N_MIMO + 1))
      continue
    fi

    RES="$(cs_eval_changeset "$PROJ" "$f" "$PROFILE")"
    CNT="$(printf '%s\n' "$RES" | awk -F'\t' 'NF { c[$1]++ } END { printf "%d %d %d %d", c["PASS"], c["FAIL"], c["NEZJISTENO"], c["SKIP"] }')"
    nP="$(printf '%s' "$CNT" | cut -d' ' -f1)"
    nF="$(printf '%s' "$CNT" | cut -d' ' -f2)"
    nU="$(printf '%s' "$CNT" | cut -d' ' -f3)"
    nS="$(printf '%s' "$CNT" | cut -d' ' -f4)"
    nApp=$((nP + nF + nU))

    # kategorie: prevzato / ceka / regrese / neaplikovatelne; nezjisteno je průřezový stav
    if [ "$nApp" -eq 0 ]; then
      STATE="neaplikovatelne"; N_NEAPLIK=$((N_NEAPLIK + 1))
    elif [ "$nF" -gt 0 ]; then
      if in_baseline "$CS_ID"; then
        STATE="regrese"; N_REGRESE=$((N_REGRESE + 1))
      else
        STATE="ceka"; N_CEKA=$((N_CEKA + 1))
      fi
    elif in_baseline "$CS_ID"; then
      STATE="prevzato"; N_PREVZATO=$((N_PREVZATO + 1))
    else
      STATE="ceka"; N_CEKA=$((N_CEKA + 1))
    fi
    if [ "$nU" -gt 0 ] && [ "$STATE" != "neaplikovatelne" ]; then
      N_NEZJISTENO=$((N_NEZJISTENO + 1))
      Q_NEZJ="$Q_NEZJ  $CS_ID ($nU z $nApp $(cs_pl_test "$nU") nezjištěno)$NL"
    fi
    if [ "$STATE" = "ceka" ] && cs_is_blocking "$f"; then
      N_BLOKUJICI=$((N_BLOKUJICI + 1))
    fi

    if [ -n "$TARGET_ID" ] && [ "$CS_ID" = "$TARGET_ID" ]; then
      SINGLE_ID="$CS_ID"; SINGLE_RES="$RES"; SINGLE_STATE="$STATE"
      SINGLE_PASS="$nP"; SINGLE_FAIL="$nF"; SINGLE_UNK="$nU"; SINGLE_SKIP="$nS"
    fi

    if [ "$STATE" = "ceka" ] || [ "$STATE" = "regrese" ]; then
      HUM="$(cs_human_line "$f")"
      AKCE="$(cs_trim "$(cs_field "$f" 'Akce konzumenta')")"
      OSA="$(cs_trim "$(cs_field "$f" 'Osa')")"
      DOSAH="$(cs_trim "$(cs_field "$f" 'Dosah')")"
      ZAV="$(cs_trim "$(cs_field "$f" 'Závažnost')")"
      ITEM="  $CS_ID (osa $OSA, dosah: $DOSAH, $ZAV)$NL"
      [ -n "$HUM" ] && ITEM="$ITEM    $HUM$NL"
      [ -n "$AKCE" ] && ITEM="$ITEM    Akce: $AKCE$NL"
      ITEM="$ITEM    Testy: $nP PASS, $nF FAIL, $nU nezjištěno, $nS mimo profil$NL"
      if [ "$STATE" = "ceka" ]; then Q_CEKA="$Q_CEKA$ITEM"; else Q_REGRESE="$Q_REGRESE$ITEM"; fi
    fi
  done
  shopt -u nullglob 2>/dev/null || true

  # --- stav a návratový kód --------------------------------------------------
  # regrese a blokující changeset = brána (1); nezjištěno = nelze rozhodnout (3);
  # být pozadu je v pull modelu normální stav, ne poplach (0).
  if [ "$N_REGRESE" -gt 0 ]; then
    STAV="regrese"; RC=1
  elif [ "$N_BLOKUJICI" -gt 0 ]; then
    STAV="blokovano"; RC=1
  elif [ "$N_NEZJISTENO" -gt 0 ] || [ "$N_VADNE" -gt 0 ]; then
    STAV="nezjisteno"; RC=3
  elif [ "$N_CEKA" -gt 0 ]; then
    STAV="pozadu"; RC=0
  else
    STAV="aktualni"; RC=0
  fi

  PROFIL_OUT="$(printf '%s' "$PROFILE" | tr ' ' ',')"
  [ -n "$PROFIL_OUT" ] || PROFIL_OUT="zadny"

  printf 'BASELINE jednotka=%s stav=%s lag=%d regrese=%d nezjisteno=%d blokujici=%d vadne=%d platforma=%s platforma_meta=%s profil=%s\n' \
    "$SLUG" "$STAV" "$N_CEKA" "$N_REGRESE" "$N_NEZJISTENO" "$N_BLOKUJICI" "$N_VADNE" "$BASE_PLATFORM" "$META_PLATFORM" "$PROFIL_OUT"

  if [ "$BASELINE_LINE" -eq 1 ]; then
    exit "$RC"
  fi

  # --- jednorázové režimy nad jedním changesetem -----------------------------
  if [ -n "$TARGET_ID" ]; then
    if [ -z "$SINGLE_ID" ]; then
      printf '\nChangeset %s v %s neexistuje, je vadný, nebo se téhle jednotky netýká.\n' "$TARGET_ID" "$CS_DIR" >&2
      exit 2
    fi
    printf '\nChangeset: %s\n' "$SINGLE_ID"
    printf 'Kategorie: %s\n\n' "$SINGLE_STATE"
    printf '%s\n' "$SINGLE_RES" | awk -F'\t' 'NF { printf "  %-11s %-16s %s %s\n", $1, $2, $3, $4 }'
    printf '\nSouhrn testů: %d PASS, %d FAIL, %d NEZJISTENO, %d mimo profil\n' \
      "$SINGLE_PASS" "$SINGLE_FAIL" "$SINGLE_UNK" "$SINGLE_SKIP"

    if [ -n "$VERIFY_ID" ]; then
      exit "$RC"
    fi

    # --- --accept: zápis do baseline, jen po PASS ---------------------------
    if in_baseline "$SINGLE_ID"; then
      printf '\nPřevzetí už je v baseline evidované, nic nezapisuji (idempotentní).\n'
      exit 0
    fi
    if [ "$SINGLE_PASS" -eq 0 ] && [ "$SINGLE_FAIL" -eq 0 ] && [ "$SINGLE_UNK" -eq 0 ]; then
      printf '\nODMÍTNUTO: changeset nemá pro tuhle jednotku ani jeden aplikovatelný test (profil: %s).\n' "$PROFIL_OUT" >&2
      printf 'Neaplikovatelný changeset se do baseline nezapisuje - v evidenci by lhal o převzetí.\n' >&2
      exit 1
    fi
    if [ "$SINGLE_FAIL" -gt 0 ]; then
      printf '\nODMÍTNUTO: %d %s %s. Proveď akci konzumenta a spusť znovu.\n' \
        "$SINGLE_FAIL" "$(cs_pl_test "$SINGLE_FAIL")" "$(cs_pl_neprosel "$SINGLE_FAIL")" >&2
      printf 'Zápis do baseline je vázaný na PASS - jinak by baseline lhala, že jsme synchronní.\n' >&2
      exit 1
    fi
    OVERENI="$SINGLE_PASS $(cs_pl_test "$SINGLE_PASS") PASS"
    if [ "$SINGLE_UNK" -gt 0 ]; then
      if [ "$FORCE" -ne 1 ] || [ -z "$(cs_trim "$FORCE_REASON")" ]; then
        printf '\nODMÍTNUTO: %d %s %s jako NEZJISTENO (nelze rozhodnout).\n' \
          "$SINGLE_UNK" "$(cs_pl_test "$SINGLE_UNK")" "$(cs_pl_skoncil "$SINGLE_UNK")" >&2
        printf 'Legitimní východisko: --force --duvod "<věta>". Zapíše se viditelně do evidence.\n' >&2
        exit 3
      fi
      OVERENI="ověření nezjištěno, převzato na slovo: $(cs_trim "$FORCE_REASON")"
    fi

    TODAY="$(date +%Y-%m-%d)"
    WHO="$(cs_trim "$ACCEPT_WHO")"
    [ -n "$WHO" ] || WHO="neuvedeno"
    META_SHA="$(git_cizi "$META_ROOT" rev-parse --short HEAD 2>/dev/null)"
    [ -n "$META_SHA" ] || META_SHA="nezjištěno"
    GLOBAL_SHA="$(git_cizi "$HOME/.claude" rev-parse --short HEAD 2>/dev/null)"
    [ -n "$GLOBAL_SHA" ] || GLOBAL_SHA="nezjištěno"
    PLAT_VER="$(head -1 "$META_ROOT/scaffold/VERSION" 2>/dev/null | tr -d '[:space:]')"
    [ -n "$PLAT_VER" ] || PLAT_VER="nezjištěno"
    MF="$(cs_manifest_path "$PROJ")"
    if [ -f "$MF" ]; then
      # build manifest drží datum pod klíčem "date", public manifest pod "rendered"
      MF_DATE="$(cs_manifest_value "$MF" date)"
      [ -n "$MF_DATE" ] || MF_DATE="$(cs_manifest_value "$MF" rendered)"
      [ -n "$MF_DATE" ] || MF_DATE="nezjištěno"
      LAST_RENDER="$MF_DATE, platforma $(cs_manifest_value "$MF" platform_version)"
    else
      LAST_RENDER="n/a"
    fi
    NEW_COUNT=$((N_PREVZATO + N_REGRESE + 1))
    ROW="| $SINGLE_ID | $TODAY | $WHO | $OVERENI |"

    if [ ! -f "$BASELINE_MD" ]; then
      mkdir -p "$(dirname "$BASELINE_MD")" || { printf 'Nelze založit %s\n' "$(dirname "$BASELINE_MD")" >&2; exit 1; }
      {
        printf '# Platform baseline - %s\n\n' "$SLUG"
        printf '> Evidence toho, které platformní změny (osa A) tahle jednotka převzala. Zapisuje výhradně `scaffold/validate.sh --baseline <jednotka> --accept <ID>` po PASS testu; ruční editace je porušení disciplíny - evidence pak lže, že jsme synchronní. Formát a kategorie fronty: `operations/changesets/README.md` v METĚ.\n\n'
        printf '**Jednotka:** %s\n' "$SLUG"
        printf '**Platforma:** %s\n' "$PLAT_VER"
        printf '**META commit:** %s (%s)\n' "$META_SHA" "$TODAY"
        printf '**GLOBAL commit:** %s (%s)\n' "$GLOBAL_SHA" "$TODAY"
        printf '**Poslední render:** %s\n' "$LAST_RENDER"
        printf '**Převzato changesetů:** %d\n' "1"
        printf '**Poslední převzetí:** %s, %s\n\n' "$TODAY" "$SINGLE_ID"
        printf '## Převzaté changesety\n\n'
        printf '| ID | Datum převzetí | Kdo | Ověření |\n'
        printf '|---|---|---|---|\n'
        printf '%s\n\n' "$ROW"
        printf '## Rolling log\n\n'
        printf '<!-- Historie převzetí a poznámky per OR-10. Nový zápis nahoru, vždy s datem.\n'
        printf '     Header nahoře drží jen aktuální stav; do baseline zapisuje jen validate.sh --accept. -->\n'
      } > "$BASELINE_MD"
      printf '\nZaloženo: %s\n' "$BASELINE_MD"
      printf 'Zapsáno převzetí: %s (%s)\n' "$SINGLE_ID" "$OVERENI"
      exit 0
    fi

    TMP="$BASELINE_MD.tmp.$$"
    # Stav hlavičky před zápisem - jen pro hlášku o dorovnání. Identita jednotky je
    # odvozená z umístění souboru, takže ji nástroj smí přepsat kdykoli zapisuje;
    # neříká nic o převzetí a nemá tedy jak zalhat o synchronizaci.
    OLD_TITLE="$(head -1 "$BASELINE_MD" 2>/dev/null)"
    OLD_UNIT="$(cs_baseline_field "$PROJ" 'Jednotka')"
    awk -v row="$ROW" -v plat="$PLAT_VER" -v metac="$META_SHA ($TODAY)" \
        -v globc="$GLOBAL_SHA ($TODAY)" -v lrender="$LAST_RENDER" \
        -v ntaken="$NEW_COUNT" -v posl="$TODAY, $SINGLE_ID" -v slug="$SLUG" '
      BEGIN { inserted = 0; intable = 0; sawtable = 0; titledone = 0 }
      # Titulek je stejná identita jako pole Jednotka a léčí se stejně. Bez tohohle
      # pravidla by baseline založená přes `--baseline .` nesla "# Platform baseline - ."
      # navždy: pole by se dorovnalo, titulek ne. Přepisuje se jen první výskyt, aby
      # zmínka v rolling logu zůstala tím, čím je - historickým zápisem.
      titledone == 0 && /^#[[:space:]]+Platform baseline/ {
        print "# Platform baseline - " slug; titledone = 1; next
      }
      # Jednotka se přepisuje taky: baseline založená přes relativní cestu nesla slug "."
      # a evidence pak neříkala, čí je. Sebeléčení při dalším převzetí, ne ruční oprava.
      /^\*\*Jednotka:\*\*/             { print "**Jednotka:** " slug; next }
      /^\*\*Platforma:\*\*/            { print "**Platforma:** " plat; next }
      /^\*\*META commit:\*\*/          { print "**META commit:** " metac; next }
      /^\*\*GLOBAL commit:\*\*/        { print "**GLOBAL commit:** " globc; next }
      /^\*\*Poslední render:\*\*/      { print "**Poslední render:** " lrender; next }
      /^\*\*Převzato changesetů:\*\*/  { print "**Převzato changesetů:** " ntaken; next }
      /^\*\*Poslední převzetí:\*\*/    { print "**Poslední převzetí:** " posl; next }
      /^[[:space:]]*\|/                { intable = 1; sawtable = 1; print; next }
      {
        if (intable == 1 && inserted == 0) { print row; inserted = 1; intable = 0 }
        print
      }
      END {
        if (inserted == 0) {
          if (sawtable == 1) { print row }
          else {
            print ""
            print "## Převzaté changesety"
            print ""
            print "| ID | Datum převzetí | Kdo | Ověření |"
            print "|---|---|---|---|"
            print row
          }
        }
      }' "$BASELINE_MD" > "$TMP" 2>/dev/null

    if [ ! -s "$TMP" ]; then
      rm -f "$TMP"
      printf '\nZápis do baseline selhal, původní soubor je beze změny: %s\n' "$BASELINE_MD" >&2
      exit 1
    fi
    mv "$TMP" "$BASELINE_MD" || { rm -f "$TMP"; printf 'Zápis do baseline selhal.\n' >&2; exit 1; }
    printf '\nZapsáno převzetí: %s (%s)\n' "$SINGLE_ID" "$OVERENI"
    if [ "$OLD_TITLE" != "# Platform baseline - $SLUG" ] || [ "$OLD_UNIT" != "$SLUG" ]; then
      printf 'Hlavička dorovnána na jednotku: %s (dřív titulek "%s", pole "%s")\n' \
        "$SLUG" "$OLD_TITLE" "$OLD_UNIT"
    fi
    printf 'Baseline: %s\n' "$BASELINE_MD"
    exit 0
  fi

  # --- report ----------------------------------------------------------------
  # Když je fronta i regrese nula, výpis zůstane jednořádkový. Startup check, který
  # při každém spuštění vypíše dvacet řádků, se do měsíce přestane číst.
  if [ "$N_CEKA" -eq 0 ] && [ "$N_REGRESE" -eq 0 ] && [ "$N_NEZJISTENO" -eq 0 ] && [ "$N_VADNE" -eq 0 ]; then
    exit "$RC"
  fi

  printf '\nJednotka:  %s\n' "$PROJ"
  if [ -f "$BASELINE_MD" ]; then
    printf 'Baseline:  %s\n' "$BASELINE_MD"
  else
    printf 'Baseline:  chybí (%s) - počítám od nuly; "nikdy nedeklarováno" není totéž co "aktuální"\n' "$BASELINE_MD"
  fi
  printf 'Profil:    %s\n' "${PROFILE:-žádný}"
  printf 'Platforma: %s v baseline, %s v METĚ\n' "$BASE_PLATFORM" "$META_PLATFORM"
  printf 'Changesety v METĚ: %d celkem, %d se týká jednotky, %d mimo rozsah, %d mimo profil\n' \
    "$N_CS" "$((N_CS - N_MIMO - N_VADNE))" "$N_MIMO" "$N_NEAPLIK"

  if [ "$N_REGRESE" -gt 0 ]; then
    printf '\nRegrese (%d) - evidováno jako převzaté, ale test dnes neprochází:\n%s' "$N_REGRESE" "$Q_REGRESE"
  fi
  if [ "$N_CEKA" -gt 0 ]; then
    printf '\nFronta nepřevzatých (%d):\n%s' "$N_CEKA" "$Q_CEKA"
  fi
  if [ "$N_NEZJISTENO" -gt 0 ]; then
    printf '\nNezjištěno (%d) - nelze rozhodnout, nepočítá se jako PASS:\n%s' "$N_NEZJISTENO" "$Q_NEZJ"
  fi
  if [ "$N_VADNE" -gt 0 ]; then
    printf '\nVadné changesety v METĚ (%d) - do fronty nevstupují, patří k opravě u autora:\n%s' "$N_VADNE" "$Q_VADNE"
  fi
  printf '\nPřevzetí se zapisuje: %s --baseline %s --accept <ID> --kdo "<jméno>"\n' "$0" "$PROJ"
  exit "$RC"
fi

# ===========================================================================
# REŽIM TENANT
# ===========================================================================
if [ "$MODE" = "tenant" ]; then
  # CLAUDE.md
  if [ -f "$PROJ/CLAUDE.md" ]; then
    ok "(t1) CLAUDE.md existuje"
  else
    ko "(t1) CLAUDE.md - chybí soubor tenantního kontextu"
  fi
  # team-inbox/ (sjednoceno 2026-07-24, dřív inbox/)
  if [ -d "$PROJ/team-inbox" ]; then
    ok "(t2) team-inbox/ existuje"
  else
    ko "(t2) team-inbox/ - chybí jediný příchozí kanál tenanta (sjednocení 2026-07-24)"
  fi
  # escalations/
  if [ -d "$PROJ/escalations" ]; then
    ok "(t3) escalations/ existuje"
  else
    ko "(t3) escalations/ - chybí adresář eskalací"
  fi
  # portfolio-status.md
  if [ -f "$PROJ/portfolio-status.md" ]; then
    ok "(t4) portfolio-status.md existuje"
  else
    ko "(t4) portfolio-status.md - chybí přehled portfolia STUDIO jednotek"
  fi
  # operations/status.md - OR-03 header samotné jednotky
  #
  # Harness je jednotka jako každá jiná a čtecí vrstva portfolia čte per OR-03
  # právě tenhle soubor. Bez něj hlásí obojí harness ve všech polích jako "nezjištěno",
  # tedy jako by neexistoval - a portfolio-status.md to nezachrání, protože ten se ze
  # status.md headerů generuje. Do 9. 8. 2026 ho tenant šablona nenesla a oba existující
  # harnessy tak vznikly bez něj.
  #
  # Kontroluje se existence I sedm polí: prázdný soubor je pro čtečku totéž co žádný.
  if [ ! -f "$PROJ/operations/status.md" ]; then
    ko "(t5) operations/status.md - chybí OR-03 header harnesse (bez něj je jednotka pro čtecí vrstvu portfolia neviditelná); vzor: hlavička v šabloně jednotky"
  else
    T_HEADER="$(extract_header "$PROJ/operations/status.md")"
    T_MISSING=""
    for field in "Last update" "Klasifikace" "Fáze" "Health" "Aktivní úkoly" "Blokátory" "Next milestone"; do
      # Počítá se deklarace, ne výskyt jména pole - jinak hlavička, která o poli píše
      # v próze a deklaraci nemá, projde jako úplná a čtečka pak hlásí prázdno.
      if [ -z "$(radek_pole "$T_HEADER" "$field")" ]; then
        T_MISSING="$T_MISSING \"$field\""
      fi
    done
    if [ -n "$T_MISSING" ]; then
      ko "(t5) OR-03 header operations/status.md - chybí deklarace pole:$T_MISSING (deklarace je řádek začínající \`**<Pole>:**\`; jméno pole uvnitř jiného řádku se nepočítá)"
    else
      ok "(t5) operations/status.md existuje a nese všech 7 polí OR-03 headeru"
    fi
    # (t6) osa mandátu - harness je jednotka jako každá jiná a mandát má taky
    check_slouzi "$T_HEADER" "(t6)"
  fi

  # Souhrn nese i WARN a n/a, stejně jako studio režim: varování, které se nepromítne
  # do souhrnu, přečte jen ten, kdo si projde celý výpis - a to je přesně ten, kdo ho
  # nepotřebuje.
  printf '\nSouhrn: %d PASS, %d FAIL, %d WARN, %d n/a\n' "$PASS_N" "$FAIL_N" "$WARN_N" "$NA_N"
  if [ "$FAIL_N" -eq 0 ]; then
    printf 'Výsledek: OK - tenant vrstva v pořádku.\n'
    exit 0
  fi
  printf 'Výsledek: SELHÁNÍ - doplň chybějící a spusť znovu.\n'
  exit 1
fi

# ===========================================================================
# REŽIM STUDIO
# ===========================================================================

# --- profil nasazené jednotky (tenantní instance) ---------------------------
#
# Studio režim měl do scaffold 2.9.5 nevyslovený předpoklad: provozní vrstva jednotky
# (CLAUDE.md s Klasifikací, operations/status.md) leží v témže repu jako jednotka sama.
# U tenantní instance nasazené do klientského repa to neplatí ROZHODNUTÍM, ne nedbalostí -
# NSL delivery vrstva do klientského repa nesmí, takže je gitignorovaná a v klonu není.
# Validátor pak nad ní hlásil tři FAILy, které nikdo nemohl odbavit. Trvale červená brána,
# kterou se nesmí brát vážně, je horší než žádná: první, co se naučí i její autor, je
# dívat se jinam.
#
# Oprava nedělá bránu měkčí, dělá ji přesnější. Chybějící soubor je n/a JEN tehdy, když
# ho jednotka sama deklaruje jako soubor mimo repo (`git check-ignore`). Deklaraci nese
# .gitignore, který je trackovaný, takže platí na obou stranách - na dev kopii u NSL
# i v klonu na stroji klienta. Chybějící soubor bez deklarace zůstává FAIL jako dřív:
# zapomenutý status.md se od vědomě vyloučeného pozná právě tímhle.
mimo_repo() { # <relativní cesta v jednotce> - 0 když je cesta deklarovaná jako mimo repo
  git_cizi "$PROJ" check-ignore -q -- "$1" >/dev/null 2>&1
}

# --- (a) CLAUDE.md + pole Klasifikace --------------------------------------
# Klasifikace (META | Internal | Client | Personal) je NSL interní taxonomie. Kanonické
# místo per OR-03 je header operations/status.md; projektový CLAUDE.md ji nese u projektů,
# které NSL vlastní. U klientských repozitářů se uplatňuje split pattern (tenký klientský
# CLAUDE.md + gitignored CLAUDE.local.md s NSL kontextem) - NSL taxonomie tam nepatří do
# souboru vlastněného klientem. Proto se akceptuje kterýkoli ze tří zdrojů.
CLAUDE_MD="$PROJ/CLAUDE.md"
CLAUDE_LOCAL_MD="$PROJ/CLAUDE.local.md"
STATUS_FOR_A="$PROJ/operations/status.md"
#
# Ve všech třech zdrojích se hledá DEKLARACE pole, ne výskyt jeho jména. Výklad normy
# v CLAUDE.md ("Klasifikace projektu je metadata zadání"), hlavička sloupce v tabulce
# jednotek nebo nadpis sekce jméno pole nesou taky - a kontrola pak hlásila zdroj, ve
# kterém hodnota fakticky není. Pořadí zdrojů zůstává, mění se jen ostrost čtení.
KLAS_SRC=""
if deklaruje_pole "$CLAUDE_MD" "Klasifikace"; then
  KLAS_SRC="CLAUDE.md"
fi
if [ -z "$KLAS_SRC" ] && deklaruje_pole "$CLAUDE_LOCAL_MD" "Klasifikace"; then
  KLAS_SRC="CLAUDE.local.md"
fi
if [ -z "$KLAS_SRC" ] && [ -f "$STATUS_FOR_A" ] \
   && [ -n "$(radek_pole "$(extract_header "$STATUS_FOR_A")" "Klasifikace")" ]; then
  KLAS_SRC="operations/status.md (OR-03 header)"
fi

if [ ! -f "$CLAUDE_MD" ]; then
  ko "(a) CLAUDE.md - chybí soubor $CLAUDE_MD"
elif [ -n "$KLAS_SRC" ]; then
  ok "(a) CLAUDE.md existuje; pole Klasifikace nalezeno v: $KLAS_SRC"
elif mimo_repo "CLAUDE.local.md" && mimo_repo "operations/status.md"; then
  na "(a) pole Klasifikace - oba nosiče NSL vrstvy (CLAUDE.local.md, operations/status.md) jsou v .gitignore jednotky, tedy vědomě mimo repo; klientský CLAUDE.md ji nenese a nést nemá"
else
  ko "(a) pole Klasifikace nenalezeno (hledáno v CLAUDE.md, CLAUDE.local.md i OR-03 headeru operations/status.md)"
fi

# --- (b) OR-03 header - 7 polí + (c) OR-10 header bez historie --------------
STATUS_MD="$PROJ/operations/status.md"
if [ ! -f "$STATUS_MD" ] && mimo_repo "operations/status.md"; then
  na "(b) OR-03 header - operations/status.md je v .gitignore jednotky (NSL provozní vrstva mimo klientské repo); stav jednotky se měří na straně NSL, ne v nasazené kopii"
  na "(c) OR-10 header - neposuzuje se, operations/status.md je vědomě mimo repo"
  na "(h) OR-03 pole Slouží: - neposuzuje se, operations/status.md je vědomě mimo repo"
elif [ ! -f "$STATUS_MD" ]; then
  ko "(b) operations/status.md - chybí soubor (OR-03 kontrakt)"
  ko "(c) OR-10 - přeskočeno, chybí operations/status.md"
  ko "(h) OR-03 pole Slouží: - přeskočeno, chybí operations/status.md"
else
  HEADER="$(extract_header "$STATUS_MD")"

  # (b) přítomnost všech 7 polí OR-03
  MISSING=""
  for field in "Last update" "Klasifikace" "Fáze" "Health" "Aktivní úkoly" "Blokátory" "Next milestone"; do
    # Deklarace, ne výskyt jména - viz radek_pole. Hlavička bez pole `Next milestone`,
    # která o něm jen mluví v `Blokátory`, není úplná a nesmí projít jako úplná.
    if [ -z "$(radek_pole "$HEADER" "$field")" ]; then
      MISSING="$MISSING \"$field\""
    fi
  done
  if [ -n "$MISSING" ]; then
    ko "(b) OR-03 header - chybí deklarace pole:$MISSING (deklarace je řádek začínající \`**<Pole>:**\`; jméno pole přilepené doprostřed jiného řádku čtečka nenajde)"
  else
    ok "(b) OR-03 header obsahuje všech 7 polí"
  fi

  # (c) OR-10 - v headeru nesmí být řetězení historie "Předchozí:"
  #
  # Tahle kontrola se schválně NEUKOTVUJE na začátek řádku, na rozdíl od (b) a (h):
  # zakázaný tvar je právě to řetězení UVNITŘ řádku `Last update`, takže ukotvení by
  # kontrolu vyplo. Rozlišení deklarace vs. zmínka drží druhou cestou - text o zmínky
  # v obráceném apostrofu ochudí, aby věta o normě samotné hlavičku neshodila.
  if bez_zminek "$HEADER" | grep -qF 'Předchozí:'; then
    ko "(c) OR-10 - header obsahuje 'Předchozí:' (historie patří do rolling logu POD header)"
  else
    ok "(c) OR-10 - header bez řetězení historie"
  fi

  # (h) OR-03 pole Slouží: - osa mandátu, nezávislá na ose správy
  check_slouzi "$HEADER" "(h)"
fi

# --- (d) OR-06 číslování team-outcomes bez duplicit ------------------------
TO_DIR="$PROJ/team-outcomes"
if [ ! -d "$TO_DIR" ]; then
  ok "(d) team-outcomes/ - adresář není, žádné duplicitní číslo"
else
  DUPES="$(ls -1 "$TO_DIR" 2>/dev/null | grep -E '^[0-9][0-9][0-9]-' | cut -c1-3 | sort | uniq -d)"
  if [ -n "$DUPES" ]; then
    ko "(d) OR-06 team-outcomes/ - duplicitní prefixy: $(printf '%s' "$DUPES" | tr '\n' ' ')"
  else
    ok "(d) OR-06 team-outcomes/ číslování bez duplicit"
  fi
fi

# --- (e) AR-12 identita agentů + (f) overlay pointer + (g) frontmatter/artefakt ---
#
# Model identity souboru v .claude/agents/ (čtyřtřídní model, render-manifest jako
# primární signál). Soubor je právě jedno z:
#   RENDERED - evidovaný v render-manifest.json = build output z platform library.
#              Runtime jméno MUSÍ nést (odkazuje se na něj katalog i launchery), pointer
#              nemá (je flattened). Governed same-name per AR-12. Kontroluje se integrita
#              artefaktu, ne pointer.
#   FORK     - jméno koliduje s kanonickým agentem a NENÍ v manifestu = zakázaný ruční fork.
#   OVERLAY  - tvar <kanonický>-<sufix> a kanonický v knihovně existuje = AR-12 overlay.
#   LOCAL    - tenant-specific agent (class 4) bez kanonického rodiče. Pointer se nevyžaduje.
#
# Zpětná kompatibilita: bez manifestu se RENDERED nevyskytne a chování je jako dřív.
# Oprava nezávislá na render modelu: LOCAL (agent bez kanonického rodiče) už nespadne na (f).
# Gitignore/tracked je sekundární signál - potvrzuje IP hranici, neurčuje identitu.
AGENTS_DIR="$PROJ/.claude/agents"
MANIFEST="$AGENTS_DIR/render-manifest.json"
# Na stroji klienta build manifest neexistuje (je gitignorovaný, nese absolutní cesty do
# NSL prostředí). Trackovaný render-manifest.public.json nese jméno, cestu, hash, model
# a tools - tedy přesně to, co identita artefaktu a drift toolů potřebují. Fallback dělá
# kontroly (e) a (g) použitelné i tam, kde na integritě záleží nejvíc (allowlist per
# stanovisko Ariadne, team-outcomes/025 sekce 2).
if [ ! -f "$MANIFEST" ] && [ -f "$AGENTS_DIR/render-manifest.public.json" ]; then
  MANIFEST="$AGENTS_DIR/render-manifest.public.json"
fi

# Jména evidovaná v manifestu (JSON se parsuje bez externích závislostí - jediný klíč
# "name" v manifestu je v poli agents[]).
MANIFEST_NAMES=""
if [ -f "$MANIFEST" ]; then
  MANIFEST_NAMES=" $(grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' "$MANIFEST" \
    | sed 's/.*"\([^"]*\)"$/\1/' | tr '\n' ' ')"
fi
in_manifest() {
  case "$MANIFEST_NAMES" in *" $1 "*) return 0 ;; esac
  return 1
}

# Deklarace distribuce z manifestu (render.js, klíč distribuce.artefakt_v_gitu).
# "trackovany" = artefakt v tenant repu být má (rozhodnutí tenanta, viz deployTracked
# v jeho policy). Prázdno = manifest z doby před scaffold 2.9.5 nebo tenant bez
# deklarace -> platí dosavadní chování, tedy WARN u trackovaného artefaktu.
ARTEFAKT_V_GITU="$(grep -o '"artefakt_v_gitu"[[:space:]]*:[[:space:]]*"[^"]*"' "$MANIFEST" 2>/dev/null \
  | sed 's/.*"\([^"]*\)"$/\1/' | head -1)"
is_tracked() { git_cizi "$PROJ" ls-files --error-unmatch "$1" >/dev/null 2>&1; }

# tools zapsané v manifestu pro daného agenta.
#
# FAIL-CLOSED KONTRAKT: legitimitu governed same-name artefaktu uděluje manifest. Když
# z něj tools nejdou přečíst, legitimita je NEOVĚŘITELNÁ - a to nesmí znamenat "prošlo".
# Proto funkce rozlišuje tři stavy a nikdy nemíchá "nenalezeno" s "nalezeno prázdné":
#   - prázdný výstup                -> klíč tools pro agenta v manifestu NENALEZEN (neověřitelné)
#   - výstup obsahuje __FOUND__     -> nalezen; další řádky jsou jednotlivé tooly
# Akceptuje obě legitimní varianty tvaru: pole (víceřádkové i inline) a řetězec.
# Nezávislé na formátování JSON: manifest se nejdřív slije do jednoho řádku a pak se
# rozseká na segmenty tak, že každý začíná klíčem "name". Díky tomu funguje stejně na
# pretty-printed i kompaktním (jednořádkovém) manifestu. Nerozpoznaný tvar hodnoty
# NEvypíše __FOUND__ - tj. propadá do fail-closed větve.
manifest_tools() {
  tr '\n' ' ' < "$MANIFEST" | sed 's/"name"[[:space:]]*:/\
&/g' | awk -v want="$1" '
    function emit_list(s,   n, i, arr, t) {
      n = split(s, arr, ",")
      for (i = 1; i <= n; i++) {
        t = arr[i]
        gsub(/"/, "", t); gsub(/\[/, "", t); gsub(/\]/, "", t)
        gsub(/^[[:space:]]+/, "", t); gsub(/[[:space:]]+$/, "", t)
        if (t != "") print t
      }
    }
    NR == 1 { next }                       # preambule před prvním "name"
    {
      nm = $0
      sub(/^"name"[[:space:]]*:[[:space:]]*"/, "", nm)
      sub(/".*$/, "", nm)
      if (nm != want) next
      if ($0 !~ /"tools"[[:space:]]*:/) next
      rest = $0
      sub(/^.*"tools"[[:space:]]*:[[:space:]]*/, "", rest)
      if (rest ~ /^"/) {                   # řetězec: "Read, Write"
        print "__FOUND__"
        sub(/^"/, "", rest); sub(/".*$/, "", rest)
        emit_list(rest)
      } else if (rest ~ /^\[/) {           # pole: ["Read","Write"] i prázdné []
        print "__FOUND__"
        sub(/^\[/, "", rest); sub(/\].*$/, "", rest)
        emit_list(rest)
      }
      # jiný tvar hodnoty -> žádné __FOUND__ -> neověřitelné (fail-closed)
    }
  '
}
frontmatter_tools() {
  extract_frontmatter "$1" | grep '^tools:' | head -1 | sed 's/^tools:[[:space:]]*//' \
    | tr ',' '\n' | sed 's/[[:space:]]//g' | grep -v '^$' | sort | tr '\n' ' '
}

if [ ! -d "$AGENTS_DIR" ]; then
  ok "(e) AR-12 identita agentů - $AGENTS_DIR není"
  ok "(f) AR-12 overlay pointer - $AGENTS_DIR není"
  ok "(g) AR-12 frontmatter / integrita artefaktu - $AGENTS_DIR není"
else
  if [ ! -d "$AGENTS_GLOBAL" ]; then
    printf 'Poznámka: platform library %s neexistuje - identita se odvozuje z manifestu (na klientském stroji je to jediný spolehlivý zdroj).\n' "$AGENTS_GLOBAL"
  fi
  if [ -f "$MANIFEST" ]; then
    if [ -z "$(printf '%s' "$MANIFEST_NAMES" | tr -d ' ')" ]; then
      printf 'Poznámka: %s existuje, ale nelze z něj přečíst žádné jméno agenta - artefakty se posoudí jako neevidované (fail-closed: same-name pak padá na (e)).\n' \
        "$(basename "$MANIFEST")"
    else
      printf 'Poznámka: %s nalezen - evidováno %s rendered deploy artefaktů (AR-12 governed same-name).\n' \
        "$(basename "$MANIFEST")" "$(grep -c '"name"' "$MANIFEST" | tr -d ' ')"
    fi
  fi

  shopt -s nullglob 2>/dev/null || true
  FORKS_FOUND=""
  NOPOINTER=""
  NOTOOLS=""
  BADMODEL=""
  ART_DRIFT=""
  ART_POINTER=""
  ART_UNVERIFIABLE=""
  ART_NETRACK=""
  N_RENDERED=0; N_OVERLAY=0; N_LOCAL=0
  FOUND=0
  for f in "$AGENTS_DIR"/*.md; do
    base="$(basename "$f")"
    [ "$base" = "README.md" ] && continue
    FOUND=1
    name="${base%.md}"
    rel=".claude/agents/$base"
    FM="$(extract_frontmatter "$f")"

    # --- klasifikace ---
    KIND="LOCAL"
    if in_manifest "$name"; then
      KIND="RENDERED"
    elif [ -f "$AGENTS_GLOBAL/$base" ]; then
      KIND="FORK"
    else
      case "$name" in
        *-*)
          parent="${name%-*}"
          [ -f "$AGENTS_GLOBAL/$parent.md" ] && KIND="OVERLAY"
          ;;
      esac
    fi

    case "$KIND" in
      RENDERED)
        N_RENDERED=$((N_RENDERED + 1))
        # Trackování artefaktu v tenant repu je rozhodnutí tenanta, ne univerzální
        # pravidlo: u kokpitu, který má u klienta naběhnout z čerstvého klonu, je
        # artefakt v .gitignore jednotka bez agenta. Posuzuje se proto proti deklaraci
        # z manifestu, ne proti domněnce - a hlásí se OBA směry rozporu.
        case "$ARTEFAKT_V_GITU" in
          trackovany)
            if ! is_tracked "$rel"; then
              ART_NETRACK="$ART_NETRACK $base"
            fi
            ;;
          *)
            if is_tracked "$rel"; then
              warn "(e) deploy artefakt $base je trackovaný v gitu, ale distribuce ho takhle nedeklaruje - NSL IP teče do repa; patří do .gitignore, nebo do policy tenanta deployTracked: true"
            fi
            ;;
        esac
        # artefakt je flattened - pointer na kanonickou definici v něm nemá co dělat
        if grep -qF '~/.claude/agents/' "$f"; then
          ART_POINTER="$ART_POINTER $base"
        fi
        # drift: ruční editace po instalaci se pozná rozdílem tools proti manifestu.
        # FAIL-CLOSED: když tools z manifestu přečíst nejde, legitimita artefaktu je
        # neověřitelná - to je FAIL, ne tiché PASS (poškozený nebo osekaný manifest by
        # jinak drift detekci vypnul a legitimizoval ručně upravený artefakt).
        MT_RAW="$(manifest_tools "$name")"
        if ! printf '%s\n' "$MT_RAW" | grep -q '^__FOUND__$'; then
          ART_UNVERIFIABLE="$ART_UNVERIFIABLE $base"
        else
          MT="$(printf '%s\n' "$MT_RAW" | grep -v '^__FOUND__$' | sort | tr '\n' ' ')"
          FT="$(frontmatter_tools "$f")"
          if [ "$MT" != "$FT" ]; then
            ART_DRIFT="$ART_DRIFT $base"
          fi
        fi
        ;;
      FORK)
        N_LOCAL=$N_LOCAL
        if is_tracked "$rel"; then
          FORKS_FOUND="$FORKS_FOUND $base(trackovaný)"
        else
          FORKS_FOUND="$FORKS_FOUND $base"
        fi
        ;;
      OVERLAY)
        N_OVERLAY=$((N_OVERLAY + 1))
        if ! grep -qF '~/.claude/agents/' "$f"; then
          NOPOINTER="$NOPOINTER $base"
        fi
        ;;
      LOCAL)
        N_LOCAL=$((N_LOCAL + 1))
        ;;
    esac

    # --- sanity frontmatteru (platí pro všechny třídy) ---
    if ! printf '%s\n' "$FM" | grep -q '^tools:'; then
      NOTOOLS="$NOTOOLS $base"
    fi
    if printf '%s\n' "$FM" | grep -q '^model:'; then
      if ! printf '%s\n' "$FM" | grep -qE '^model:[[:space:]]*(fable|opus|sonnet|haiku)[[:space:]]*$'; then
        BADMODEL="$BADMODEL $base"
      fi
    fi
  done
  shopt -u nullglob 2>/dev/null || true

  if [ "$FOUND" -eq 0 ]; then
    ok "(e) AR-12 identita agentů - žádné agent soubory"
    ok "(f) AR-12 overlay pointer - žádné agent soubory"
    ok "(g) AR-12 frontmatter / integrita artefaktu - žádné agent soubory"
  else
    # (e) identita - zakázaný je jen neevidovaný same-name fork
    if [ -n "$FORKS_FOUND" ]; then
      ko "(e) AR-12 - neevidovaný same-name fork kanonického agenta:$FORKS_FOUND (přejmenuj na <name>-<tenant>.md, nebo nasaď jako rendered artefakt s manifestem)"
    else
      if [ "$ARTEFAKT_V_GITU" = "trackovany" ]; then
        ok "(e) AR-12 identita OK (rendered: $N_RENDERED, overlay: $N_OVERLAY, tenant-specific: $N_LOCAL, fork: 0); artefakt je v tenant repu trackovaný podle deklarace distribuce"
      else
        ok "(e) AR-12 identita OK (rendered: $N_RENDERED, overlay: $N_OVERLAY, tenant-specific: $N_LOCAL, fork: 0)"
      fi
    fi
    if [ -n "$ART_NETRACK" ]; then
      warn "(e) distribuce deklaruje trackovaný artefakt, ale v gitu není:$ART_NETRACK - u kokpitu z čerstvého klonu to znamená jednotku bez agenta"
    fi
    # (f) pointer - jen overlaye; rendered je flattened, tenant-specific nemá rodiče
    if [ -n "$NOPOINTER" ]; then
      ko "(f) AR-12 - overlay bez pointeru na ~/.claude/agents/:$NOPOINTER"
    elif [ -n "$ART_POINTER" ]; then
      ko "(f) AR-12 - rendered artefakt obsahuje pointer na kanonickou definici (má být self-contained):$ART_POINTER"
    else
      ok "(f) AR-12 - overlaye mají pointer, rendered artefakty jsou self-contained"
    fi
    # (g) frontmatter sanity + integrita artefaktu proti manifestu
    G_FAIL=0
    if [ -n "$NOTOOLS" ]; then
      ko "(g) AR-12 - agent bez tools ve frontmatteru:$NOTOOLS"; G_FAIL=1
    fi
    if [ -n "$BADMODEL" ]; then
      ko "(g) AR-12 - model mimo alias fable/opus/sonnet/haiku:$BADMODEL"; G_FAIL=1
    fi
    if [ -n "$ART_DRIFT" ]; then
      ko "(g) AR-12 - rendered artefakt se rozchází s manifestem (ruční editace po instalaci?):$ART_DRIFT - přegeneruj přes render, needituj ručně (OR-09)"; G_FAIL=1
    fi
    if [ -n "$ART_UNVERIFIABLE" ]; then
      ko "(g) AR-12 - rendered artefakt NELZE ověřit proti manifestu (chybí/nečitelný záznam tools):$ART_UNVERIFIABLE - legitimitu artefaktu uděluje manifest, neověřitelné = neplatné; přegeneruj přes render"; G_FAIL=1
    fi
    if [ "$G_FAIL" -eq 0 ]; then
      ok "(g) AR-12 - frontmatter v pořádku a rendered artefakty odpovídají manifestu"
    fi
  fi
fi

# --- souhrn ----------------------------------------------------------------
printf '\nSouhrn: %d PASS, %d FAIL, %d WARN, %d n/a\n' "$PASS_N" "$FAIL_N" "$WARN_N" "$NA_N"
if [ "$FAIL_N" -eq 0 ]; then
  printf 'Výsledek: OK - scaffold integrita v pořádku.\n'
  exit 0
fi
printf 'Výsledek: SELHÁNÍ - oprav výše uvedené a spusť znovu.\n'
exit 1
