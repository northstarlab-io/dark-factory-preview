#!/usr/bin/env bash
#
# validate-platform.sh - validátor invariantů PLATFORMNÍ úrovně NSL Dark Factory
#
# Účel:
#   Mechanická kontrola invariantů platformy (platform library ~/.claude + META projekt),
#   doplněk k projektovému validate.sh (ten validuje scaffoldované STUDIO jednotky / tenanty).
#   Chytá třídu chyb, které v minulosti prošly ruční bránou:
#     - hire bez propagace do odvozeného katalogu + agent soubor v gitu untracked
#     - "tools: read, write" lowercase = tichý bug, agent nemohl psát
#     - drift modelu mezi frontmatterem a dokumentovaným rozhodnutím
#
# Použití:
#   ./scaffold/validate-platform.sh                 # z kořene projektu platformy
#   ./scaffold/validate-platform.sh --since <ref>       # přepíše cutoff brány pro METU
#   ./scaffold/validate-platform.sh --since-lib <ref>   # přepíše cutoff brány pro ~/.claude
#   ./scaffold/validate-platform.sh --hook              # režim brány v pre-commit hooku
#
# Dvě prostředí, dvě otázky (rozhodnuto 6. 8. 2026 po prvním dni ostrého provozu):
#
#   RUČNÍ BĚH odpovídá na "je platforma teď v pořádku". Měří pracovní strom, tedy stav
#   stroje, u kterého člověk sedí.
#
#   REŽIM --hook odpovídá na "je v pořádku to, co se právě commituje". Měří PLOCHU
#   COMMITU (scaffold/lib/git-prostredi.sh), ne disk. Důvod je provozní: v repu pracuje
#   víc agentů naráz a brána nad pracovním stromem znamená, že jedna rozpracovaná změna
#   zablokuje commit každému dalšímu, i když se jí jeho commit vůbec netýká. Přesně to
#   se stalo 6. 8. - dva nezávislé commity zablokované cizí rozdělanou prací. Brána,
#   kterou se vyplatí obcházet, je horší než žádná.
#
# Plocha není slabší kritérium, je to jiné - a v jednom směru přísnější. Pracovní strom
# neumí chytit částečný commit, který od sebe oddělí index a obsah, který index popisuje
# (na disku sedí obojí, v commitu je jen půlka). Plocha to chytne. Zbytkový rozdíl
# "disk se od indexu liší kvůli cizí nezacommitované práci" se v hooku hlásí jako
# poznámka s výčtem viníků a nezastavuje commit: cizí pracovní stůl není stav platformy
# a uklidí ho vlastní commit toho, kdo na něm pracuje - jeho plocha ty soubory obsahuje.
#
# Kontroly:
#   (1) Roster parita   - počet ~/.claude/agents/*.md vs. GLOBAL tabulka team/agent-stack.md
#   (2) Git tracking    - každý agent soubor tracked v git repu ~/.claude
#   (3) Model alias     - frontmatter model: je fable|opus|sonnet|haiku (chybí = inherit -> WARN)
#   (4) Tools case      - built-in tooly ve frontmatter tools: správně PascalCase
#   (5) Name slug       - frontmatter name: kebab-case bez diakritiky a mezer
#   (6) OR-06 META      - team-outcomes/ bez duplicitních NNN- prefixů
#   (7) OR-10 header    - header operations/status.md bez řetězení historie "Předchozí:"
#   (8a) Brána changesetů, rozsah commitů - commit s dosahem mimo METU nese trailer
#        "Changeset: <ID>" nebo "Changeset: none (<důvod>)"; fail-closed
#   (8b) Brána changesetů, pracovní strom - advisory (WARN) před commitem
#   (9a) Parita validátor -> šablona - každá cesta, kterou validate.sh v daném režimu
#        vyžaduje, musí existovat v odpovídající šabloně (anti N-02)
#   (9b) Parita manifest <-> šablona - obousměrně: engine cesta bez souboru v šabloně
#        (mrtvá deklarace) i soubor v šabloně bez zařazení do engine/state (díra v seamu);
#        engine položka musí být konkrétní soubor, ne glob ani adresář
#   (9d) Parita norem META -> šablony - výčet identifikátorů OR-NN v šablonách odpovídá
#        výčtu nadpisů "### OR-NN" v META CLAUDE.md (porovnává se výčet, NE znění)
#   (10) Jeden domov verze platformy - scaffold/VERSION je semver a scaffold/manifest.json
#        nese totéž číslo (druhé místo se hlídá mechanicky, ne dobrou vůlí)
#   (11) Index platformy - project-init/platform-index.json a docs/index-platformy.md
#        odpovídají měřené ploše (ruční běh disk, --hook plocha commitu); fail-closed,
#        jakmile má deklarace stav "platny"
#   (12) Parita indexu a čtené plochy kokpitu - poradní (vždy WARN), nikdy nic nepovoluje;
#        umí schéma registru read-purposes/v1 i v2 (v2 nese ve vzorech zástupné symboly)
#   (13) Jeden adresář, jeden zápisový režim - obousměrně: soubor pod ~/.claude/nsl/ nese
#        režimní marker odvozeniny, soubor pod ~/.claude/foundation/ ho nenese
#   (14) OR-02 sken secretů - měřená plocha neobsahuje vzor přístupového údaje bez
#        doložené značky (ruční běh disk, --hook plocha commitu); fail-closed
#   (15) Evidence rozhodnutí o vypuštěných sekcích - každý ukazatel na náhradní text
#        existuje a je verzovaný; fronta nerozhodnutých se měří renderem, ne tady
#   (16) Dodatek k vydanému changesetu je evidovaný - obousměrně: pole "Dodatek:"
#        v hlavičce má sekci "## Dodatky" s původním zněním a naopak
#   (17a) Tvar verify bloků - každý řádek jde vyhodnotit (známá vrstva, známé sloveso,
#        cesta i vzor); fail-closed, protože nevyhodnotitelný řádek vrací NEZJISTENO navždy
#   (17b) Splnitelnost knihovních testů - lib_grep/lib_file hledá to, co v platform library
#        opravdu je; FAIL v měřené ploše (autor je u toho), WARN u vydaných (opraví dodatek)
#   (18) Mapa verzí neopisuje živá čísla - docs/mapa-verzi.md ukazuje na zdroj a příkaz;
#        historické číslo se píše s "v" (v2.0.0), živé tam nesmí být vůbec
#
# Výstup: per kontrola PASS/WARN/FAIL + detail. Exit 0 jen bez FAIL, jinak exit 1.
# Skript NIC neopravuje - jen reportuje.
#
# Origin: upgrade platformy v2 (2026-07-19), ICOR sweep nález - mechanizace
# Panošovy frontmatter acceptance validace (feedback memory 2026-06-04).
# Kontrola (8) doplněna 2026-08-03 per B-065 P1 krok 6, návrh
# team-outcomes/024-f3-b065-changeset-baseline-navrh-2026-08-03.md sekce 8.
# Kontrola (9a) a (9d) doplněna 2026-08-03 per B-065 P1 krok 8, tentýž návrh sekce 9.2.
# Kontrola (9b) doplněna 2026-08-05 (scaffold 2.3.0) spolu se zařazením runbooku výmazu
# do seamu - vznikla jako brána nad kontraktem "cesta v šabloně = cesta v jednotce".
# Proti původnímu záměru P3 posuzuje šablonu, ne referenční jednotku: šablona je zdroj,
# jednotka jeho kopie, a kontrolovat kopii dřív než zdroj by chytalo následek.
# Kontrola (9c) šablona proti knihovně je pořád v P3 - vědomě není, ne opomenutí.
#
# POSIX-friendly bash, kompatibilní s macOS (BSD grep/sed/awk). Závislosti: git + coreutils.

set -u

# --- argumenty -------------------------------------------------------------
SINCE_META=""
SINCE_LIB=""
REZIM_HOOK=0
while [ $# -gt 0 ]; do
  case "$1" in
    --hook)
      REZIM_HOOK=1
      shift
      ;;
    --since)
      SINCE_META="${2:-}"
      [ -n "$SINCE_META" ] || { printf 'Chyba: --since vyžaduje git ref.\n' >&2; exit 2; }
      shift 2
      ;;
    --since-lib)
      SINCE_LIB="${2:-}"
      [ -n "$SINCE_LIB" ] || { printf 'Chyba: --since-lib vyžaduje git ref.\n' >&2; exit 2; }
      shift 2
      ;;
    -h|--help)
      # celý úvodní komentářový blok, ať se nápověda neusekne po doplnění kontroly
      awk 'NR>1 && /^#/ { sub(/^# ?/, ""); print; next } NR>1 { exit }' "$0"
      exit 0
      ;;
    *)
      printf 'Chyba: neznámý argument "%s" (viz --help).\n' "$1" >&2
      exit 2
      ;;
  esac
done

PASS_N=0
WARN_N=0
FAIL_N=0

ok()   { PASS_N=$((PASS_N + 1)); printf 'PASS  %s\n' "$1"; }
wa()   { WARN_N=$((WARN_N + 1)); printf 'WARN  %s\n' "$1"; }
ko()   { FAIL_N=$((FAIL_N + 1)); printf 'FAIL  %s\n' "$1"; }
# odsazený detail (víceřádkový vstup na stdin)
detail() { sed 's/^/      - /'; }

AGENTS_DIR="$HOME/.claude/agents"
CLAUDE_REPO="$HOME/.claude"
ROSTER="team/agent-stack.md"
STATUS_MD="operations/status.md"
TO_DIR="team-outcomes"
CHANGESETS_DIR="operations/changesets"
CHANGESETS_README="$CHANGESETS_DIR/README.md"
VALIDATE_SH="scaffold/validate.sh"
TPL_TENANT="scaffold/tenant-template"
TPL_STUDIO="scaffold/studio-template"
VERSION_FILE="scaffold/VERSION"
MANIFEST_JSON="scaffold/manifest.json"
SEAM_LIB="scaffold/lib/seam.sh"
GEN_INDEX="scaffold/gen-platform-index.sh"
INDEX_CONFIG="scaffold/platform-index-config.json"
PLATFORM_INDEX="project-init/platform-index.json"
PLATFORM_INDEX_MD="docs/index-platformy.md"
SKEN_TOOL="scaffold/tools/sken-secretu.sh"

# Šablony MIMO seam vědomě: scaffold/studio-template-klient a scaffold/workspace/template
# patří workspace vrstvě tenanta, o které manifest mlčí (viz scaffold/workspace/README.md
# sekce "Engine a state seam") - upgrade platformy do repa tenanta nekopíruje, tu hranici
# drží whitelist kokpitu. Kontrola (9b) je proto neposuzuje.

# Cesty, jejichž nepřítomnost validate.sh toleruje (nesmí padat na (9a)):
#   CLAUDE.local.md              - alternativní zdroj Klasifikace u klientského split patternu
#   .claude/agents[/manifest]    - rendered artefakty vznikají renderem, ne šablonou
OPTIONAL_PROJ_PATHS="CLAUDE.local.md .claude/agents .claude/agents/render-manifest.json"

# Hlídané cesty brány (8) - dosah mimo METU. Per návrh 024 sekce 8.1.
# docs/** je vědomě MIMO: manuály jsou artefakt METY, ne jednotky; šumící brána se vypne.
WATCH_META='^scaffold/|^CLAUDE\.md$|^project-init/02-architektura-vrstev\.md$|^project-init/04-ai-safe-vault\.md$'
# ^nsl/ = domov odvozenin firemního obsahu (destilát Foundation, rozsudek Ariadne
# team-outcomes/046). Vzor přistává SCHVÁLNĚ dřív, než vznikne první soubor: opačné
# pořadí znamená obsah mimo hlídané cesty, tedy přesně ten mezistav, kvůli kterému
# rozsudek vznikl.
WATCH_LIB='^agents/[^/]+\.md$|^skills/|^commands/|^hooks/|^foundation/|^nsl/'

# kanonické názvy built-in toolů (PascalCase)
CANON_TOOLS="Read Write Edit Glob Grep Bash WebSearch WebFetch Agent ToolSearch TaskCreate TaskUpdate TaskList"

# --- guard: spuštění z kořene META projektu --------------------------------
if [ ! -f "CLAUDE.md" ] || [ ! -d "operations" ] || [ ! -d "team" ]; then
  printf 'Chyba: spusť z kořene projektu platformy - nenalezeno CLAUDE.md / operations/ / team/.\n' >&2
  printf 'Ve vyděleném balíčku tenhle validátor neběží, chybí mu korpus, nad kterým měří;\n' >&2
  printf 'je tu ke čtení a pro --help.\n' >&2
  exit 2
fi

printf 'Validace platformní úrovně NSL Dark Factory\n'
printf 'GLOBAL vrstva: %s\n' "$AGENTS_DIR"
printf 'META projekt:  %s\n\n' "$(pwd)"

# --- pomocné funkce --------------------------------------------------------

# Extrahuje YAML frontmatter agent souboru: řádky mezi úvodním "---" (řádek 1)
# a dalším "---". Soubor bez frontmatteru vrátí prázdno.
extract_frontmatter() {
  awk '
    NR==1 { if ($0 ~ /^---[[:space:]]*$/) { infm=1; next } else { exit } }
    /^---[[:space:]]*$/ { exit }
    infm { print }
  ' "$1"
}

# --- brána G3: vykonej jen to, co je v gitu ---------------------------------
#
# Dokud validátor spouští člověk, je sourcování a spouštění souborů z pracovního stromu
# neškodné. S pre-commit hookem se z toho stává vlastnost "umístit soubor do stromu
# způsobí spuštění shell kódu při příštím commitu, s právy Stanislava" (nález R2,
# posudek Ariadne team-outcomes/041 sekce 5.1). Tahle funkce mění vlastnost na
# "vykoná se jen to, co je v gitu". Platí pro KAŽDÉ sourcování i spuštění relativní
# cestou v tomhle skriptu, ne jen pro seam.
tracked_in_git() { # <cesta> - 0 když je soubor verzovaný
  git ls-files --error-unmatch "$1" >/dev/null 2>&1
}

# --- hranice repa: zděděné prostředí gitu ----------------------------------
#
# Bez tohohle sourcování se validátor nespustí, a je to schválně. Dotaz do cizího repa
# se zděděným GIT_INDEX_FILE nevrací chybu, vrací PRÁZDNO - a prázdný seznam se dá
# splést s "nic tam není". Kontrola (2) tak 6. 8. hlásila všechny definice agentů jako untracked
# při každém částečném commitu. Detail a reprodukce v hlavičce knihovny.
LIB_GIT="scaffold/lib/git-prostredi.sh"
if [ ! -f "$LIB_GIT" ]; then
  printf 'Chyba: chybí %s - bez ní neumím oddělit dotaz do vlastního a do cizího repa.\n' "$LIB_GIT" >&2
  exit 2
elif ! tracked_in_git "$LIB_GIT"; then
  printf 'Chyba: %s není verzovaný v gitu, NESOURCUJI ho (brána G3).\n' "$LIB_GIT" >&2
  exit 2
fi
# shellcheck source=lib/git-prostredi.sh
. "./$LIB_GIT"

# Extrahuje OR-03/OR-10 header status.md: vše před PRVNÍM z "---" nebo H2 "## ".
# (Stejná logika jako v projektovém validate.sh - obě hranice kvůli starším souborům.)
extract_header() {
  awk 'BEGIN{h=1} /^---[[:space:]]*$/{h=0} /^##[[:space:]]/{h=0} h==1{print}' "$1"
}

# --- minimální čtení JSON (kontrola 12) ------------------------------------
#
# Jen tolik, kolik potřebuje parita se čtecím registrem kokpitu: pole objektů podle klíče,
# skalár a pole řetězců uvnitř objektu. Bez jq a bez Node, aby validátor běžel všude.
# Escapovaná uvozovka se nečeká - registr ji per kontrakt read-purposes/v1 nemá.
json_objects_of() { # <soubor> <klíč pole> -> jeden objekt na řádek
  awk -v key="$2" '
    { t = t " " $0 }
    END {
      k = "\"" key "\""
      i = index(t, k)
      if (i == 0) exit
      s = substr(t, i + length(k))
      j = index(s, "[")
      if (j == 0) exit
      s = substr(s, j + 1)
      depth = 0; instr = 0; obj = ""
      n = length(s)
      for (p = 1; p <= n; p++) {
        c = substr(s, p, 1)
        if (instr) { obj = obj c; if (c == "\"") instr = 0; continue }
        if (c == "\"") { instr = 1; obj = obj c; continue }
        if (c == "{") { depth++; if (depth == 1) { obj = ""; continue } }
        else if (c == "}") { depth--; if (depth == 0) { print obj; obj = ""; continue } }
        else if (c == "]" && depth == 0) { break }
        if (depth >= 1) obj = obj c
      }
    }' "$1" 2>/dev/null
}

obj_scalar() { # <text objektu> <klíč> -> hodnota
  printf '%s' "$1" | awk -v key="$2" '
    {
      k = "\"" key "\""
      i = index($0, k)
      if (i == 0) exit
      s = substr($0, i + length(k))
      j = index(s, ":")
      if (j == 0) exit
      s = substr(s, j + 1)
      sub(/^[[:space:]]+/, "", s)
      if (substr(s, 1, 1) == "\"") {
        s = substr(s, 2); e = index(s, "\"")
        if (e == 0) exit
        print substr(s, 1, e - 1)
      } else if (match(s, /^[^,}\]]+/)) {
        v = substr(s, RSTART, RLENGTH); gsub(/[[:space:]]/, "", v); print v
      }
    }'
}

obj_strings() { # <text objektu> <klíč pole řetězců> -> jeden řetězec na řádek
  printf '%s' "$1" | awk -v key="$2" '
    {
      k = "\"" key "\""
      i = index($0, k)
      if (i == 0) exit
      s = substr($0, i + length(k))
      j = index(s, "[")
      if (j == 0) exit
      s = substr(s, j + 1)
      e = index(s, "]")
      if (e == 0) exit
      s = substr(s, 1, e - 1)
      n = split(s, part, ",")
      for (p = 1; p <= n; p++) {
        c = part[p]; gsub(/[[:space:]"]/, "", c)
        if (c != "") print c
      }
    }'
}

# --- pomocné funkce brány changesetů (8) -----------------------------------

# Minimální platnost changesetu jako POKRYTÍ (ne plná validace - ta patří do
# scaffold/lib/changeset.sh): soubor existuje, pole ID sedí na jméno souboru,
# je v něm blok verify. Prázdný changeset by z brány udělal razítko.
# Na stdout důvod neplatnosti, návratový kód 0 = platný.
changeset_ok() {
  cso_id="$1"
  cso_file="$CHANGESETS_DIR/${cso_id}.md"
  if [ ! -f "$cso_file" ]; then
    printf 'changeset "%s" neexistuje v %s/' "$cso_id" "$CHANGESETS_DIR"; return 1
  fi
  if ! grep -qF "**ID:** ${cso_id}" "$cso_file"; then
    printf 'changeset "%s": pole ID neodpovídá jménu souboru' "$cso_id"; return 1
  fi
  if ! grep -q '^```verify' "$cso_file"; then
    printf 'changeset "%s": chybí blok verify (neplatný changeset se jako pokrytí neuzná)' "$cso_id"; return 1
  fi
  return 0
}

# Je commit pokrytý? Na stdout důvod nepokrytí, návratový kód 0 = pokryto.
# $1 repo, $2 sha, $3 je_meta (1/0). V METĚ se jako pokrytí uzná i commit,
# který sahá na soubor changesetu; v knihovně (jiný repo) jen trailer.
commit_cover_reason() {
  ccr_repo="$1"; ccr_sha="$2"; ccr_is_meta="$3"
  if [ "$ccr_is_meta" -eq 1 ]; then
    if git_v_repu "$ccr_repo" show --name-only --format= "$ccr_sha" 2>/dev/null \
       | grep -qE '^operations/changesets/[^/]+\.md$'; then
      return 0
    fi
  fi
  ccr_trailer="$(git_v_repu "$ccr_repo" show -s --format=%B "$ccr_sha" 2>/dev/null \
    | sed -n 's/^Changeset:[[:space:]]*//p' | tail -1 | sed 's/[[:space:]]*$//')"
  if [ -z "$ccr_trailer" ]; then
    printf 'bez traileru "Changeset:"'; return 1
  fi
  case "$ccr_trailer" in
    "none ("*")")
      ccr_reason="${ccr_trailer#none (}"
      ccr_reason="${ccr_reason%)}"
      ccr_reason="$(printf '%s' "$ccr_reason" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
      if [ -z "$ccr_reason" ]; then
        printf 'trailer "Changeset: none ()" s prázdným důvodem (důvod je povinný)'; return 1
      fi
      return 0
      ;;
    none|none*)
      printf 'trailer "Changeset: %s" není ve tvaru "none (<důvod>)"' "$ccr_trailer"; return 1
      ;;
    *)
      changeset_ok "$ccr_trailer" || return 1
      return 0
      ;;
  esac
}

# Evidovaná výjimka brány: commit, který pokrytí nemá a mít ho už nemůže (historie se
# nepřepisuje, OR-10), ale jehož obsah je zpětně formalizovaný changesetem.
#
# Proč tohle a ne druhý posun kotvy: kotva je jeden bod a každý její posun promine celý
# rozsah před sebou. Po 5. 8. by druhý posun během dvou dnů udělal z kotvy de facto
# mechanismus výjimek - jenže neviditelný, protože po posunu už není co počítat. Jmenovitá
# výjimka je užší (jeden commit), spočitatelná a vidí ji každý běh brány.
# Tvar řádku v README: | META | `<sha>` | <důvod> | `<changeset nebo ->` |
gate_exception_reason() { # <label> <short sha> - 0 když je výjimka evidovaná a platná
  ger_label="$1"; ger_sha="$2"
  [ -f "$CHANGESETS_README" ] || return 1
  ger_row="$(awk -F'|' -v lbl="$ger_label" -v sha="$ger_sha" '
    /^[[:space:]]*\|/ {
      l = $2; c = $3; d = $4; f = $5
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", l)
      gsub(/[[:space:]`]/, "", c)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", d)
      gsub(/[[:space:]`]/, "", f)
      if (l == lbl && c != "" && index(sha, c) == 1) { print d "\t" f; exit }
    }' "$CHANGESETS_README")"
  [ -n "$ger_row" ] || return 1
  ger_duvod="${ger_row%%	*}"
  ger_form="${ger_row##*	}"
  [ -n "$ger_duvod" ] || return 1
  if [ -n "$ger_form" ] && [ "$ger_form" != "-" ]; then
    changeset_ok "$ger_form" >/dev/null || return 1
  fi
  printf '%s' "$ger_duvod"
  return 0
}

# Projde rozsah <cutoff>..HEAD a vypíše nepokryté commity sahající na hlídané cesty.
# Poslední řádek výstupu je "#stats <posouzeno> <nepokryto>".
# Návratový kód: 0 vše pokryto, 1 nalezen nepokrytý commit, 2 nelze posoudit (fail-closed).
gate_scan_range() {
  gsr_repo="$1"; gsr_label="$2"; gsr_cutoff="$3"; gsr_watch="$4"; gsr_is_meta="$5"
  if ! git_v_repu "$gsr_repo" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    printf '%s: %s není git repo, rozsah commitů nelze posoudit\n' "$gsr_label" "$gsr_repo"
    return 2
  fi
  if ! git_v_repu "$gsr_repo" rev-parse --verify --quiet "${gsr_cutoff}^{commit}" >/dev/null 2>&1; then
    printf '%s: cutoff "%s" v repu neexistuje - zkontroluj pole "Brána platí od" v %s\n' \
      "$gsr_label" "$gsr_cutoff" "$CHANGESETS_README"
    return 2
  fi
  gsr_n=0
  gsr_bad=0
  gsr_exc=0
  for gsr_sha in $(git_v_repu "$gsr_repo" rev-list "${gsr_cutoff}..HEAD" 2>/dev/null); do
    git_v_repu "$gsr_repo" show --name-only --format= "$gsr_sha" 2>/dev/null \
      | grep -Eq "$gsr_watch" || continue
    gsr_n=$((gsr_n + 1))
    gsr_reason="$(commit_cover_reason "$gsr_repo" "$gsr_sha" "$gsr_is_meta")" && continue
    gsr_short="$(git_v_repu "$gsr_repo" rev-parse --short "$gsr_sha")"
    if gsr_exc_duvod="$(gate_exception_reason "$gsr_label" "$gsr_short")"; then
      gsr_exc=$((gsr_exc + 1))
      printf '#vyjimka %s %s - %s\n' "$gsr_label" "$gsr_short" "$gsr_exc_duvod"
      continue
    fi
    gsr_bad=$((gsr_bad + 1))
    printf '%s %s "%s" - %s\n' \
      "$gsr_label" \
      "$gsr_short" \
      "$(git_v_repu "$gsr_repo" show -s --format=%s "$gsr_sha" | cut -c1-60)" \
      "$gsr_reason"
  done
  printf '#stats %d %d %d\n' "$gsr_n" "$gsr_bad" "$gsr_exc"
  [ "$gsr_bad" -eq 0 ] || return 1
  return 0
}

# Rozpracované, staged i neevidované soubory pod hlídanými cestami daného repa.
gate_worktree_paths() {
  gwp_repo="$1"; gwp_watch="$2"; gwp_label="$3"
  git_v_repu "$gwp_repo" status --porcelain -uall 2>/dev/null \
    | sed 's/^...//; s/^.* -> //; s/^"//; s/"$//' \
    | grep -E "$gwp_watch" \
    | sed "s|^|${gwp_label} |"
}

# --- pomocné funkce parity META <-> šablony (9) -----------------------------

# (9a) Cesty "$PROJ/<x>", které validate.sh používá v jedné režimové sekci.
# Sekce = od banneru "# REŽIM <NÁZEV>" po další takový banner. Seznam se NEopisuje
# ručně: kdyby žil na dvou místech, rozejde se (OR-10) a kontrola přestane platit.
# Režim BASELINE se vědomě neposuzuje: jednotka bez baseline je legitimní stav
# ("baseline chybí, počítám od nuly"), takže by z toho byl šum, ne nález.
proj_paths_in_mode() {
  awk -v want="$1" '
    /^# REŽIM / { mode = $0; sub(/^# REŽIM[[:space:]]*/, "", mode); sub(/[[:space:]].*$/, "", mode) }
    mode != want { next }
    {
      s = $0
      while (match(s, /"\$PROJ\/[^"]*"/)) {
        p = substr(s, RSTART + 7, RLENGTH - 8)
        if (p != "") print p
        s = substr(s, RSTART + RLENGTH)
      }
    }
  ' "$VALIDATE_SH" | sort -u
}

is_optional_proj_path() {
  for iop in $OPTIONAL_PROJ_PATHS; do
    [ "$1" = "$iop" ] && return 0
  done
  return 1
}

# (9d) Identifikátory norem deklarované v šabloně.
# Uznávaný deklarační tvar (jiný se nepočítá, aby zmínka v próze neplnila výčet):
#   - odrážka s tučným identifikátorem:  - **OR-01 ...
#   - řádek tabulky:                     | OR-01 | ...  /  | **OR-01** | ...
# Placeholder {{OR-NN}} v nenaplněné šabloně se záměrně nematchne.
template_or_ids() {
  awk '
    /^[[:space:]]*[-*][[:space:]]+\*\*OR-[0-9]/ || /^\|[[:space:]]*\**OR-[0-9]/ {
      if (match($0, /OR-[0-9]+/)) print substr($0, RSTART, RLENGTH)
    }
  ' "$@" 2>/dev/null | sort -u
}

# Nadpisy "### OR-NN" v META CLAUDE.md - kotva výčtu (B-064 je nesmí zrušit).
meta_or_ids() {
  grep -E '^### OR-[0-9]+' CLAUDE.md 2>/dev/null \
    | sed -E 's/^### (OR-[0-9]+).*/\1/' | sort -u
}

# Prvky prvního seznamu chybějící ve druhém (oba po řádcích).
ids_missing_in() {
  imi_out=""
  for imi_id in $1; do
    printf '%s\n' "$2" | grep -qx "$imi_id" || imi_out="$imi_out $imi_id"
  done
  printf '%s' "$imi_out"
}

# --- soupis agent souborů --------------------------------------------------
if [ ! -d "$AGENTS_DIR" ]; then
  ko "(1-5) $AGENTS_DIR neexistuje - GLOBAL vrstva agentů nenalezena, kontroly 1-5 nelze provést"
  AGENT_COUNT=0
  HAVE_AGENTS=0
else
  AGENT_COUNT="$(find "$AGENTS_DIR" -maxdepth 1 -name '*.md' -type f | wc -l | tr -d ' ')"
  HAVE_AGENTS=1
fi

# ===========================================================================
# (1) Roster parita - počet souborů vs. GLOBAL tabulka rosteru
# ===========================================================================
if [ "$HAVE_AGENTS" -eq 1 ]; then
  if [ ! -f "$ROSTER" ]; then
    wa "(1) roster parita - $ROSTER neexistuje (vygeneruj generátorem odvozeného katalogu)"
  elif ! grep -q '^## GLOBAL stack' "$ROSTER"; then
    wa "(1) roster parita - v $ROSTER nenalezena sekce '## GLOBAL stack', počítání nelze provést"
  else
    # agentní řádky = řádky "| **name** | ..." uvnitř sekce GLOBAL stack
    # (hlavička a oddělovač tabulky pattern nematchnou; per-project tabulka je v jiné sekci)
    ROSTER_N="$(awk '
      /^## GLOBAL stack/ { s=1; next }
      /^## /             { s=0 }
      s && /^\| \*\*/    { n++ }
      END { print n+0 }
    ' "$ROSTER")"
    if [ "$ROSTER_N" -eq "$AGENT_COUNT" ]; then
      ok "(1) roster parita - $AGENT_COUNT souborů v $AGENTS_DIR = $ROSTER_N řádků GLOBAL tabulky"
    else
      ko "(1) roster parita - $AGENT_COUNT souborů v $AGENTS_DIR vs. $ROSTER_N řádků GLOBAL tabulky v $ROSTER (regeneruj odvozený katalog nebo dohledej chybějící hire/retire propagaci)"
    fi
  fi
fi

# ===========================================================================
# (2) Git tracking - každý agent soubor tracked v repu ~/.claude
# ===========================================================================
if [ "$HAVE_AGENTS" -eq 1 ]; then
  # git_cizi, ne git -C: se zděděným GIT_INDEX_FILE (částečný commit v METĚ) vrací
  # "ls-files agents/" v cizím repu prázdno a všechny definice agentů vypadají jako untracked.
  if ! git_cizi "$CLAUDE_REPO" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    ko "(2) git tracking - $CLAUDE_REPO není git repo, tracking agentů nelze ověřit"
  else
    TRACKED="$(git_cizi "$CLAUDE_REPO" ls-files agents/)"
    UNTRACKED=""
    for f in "$AGENTS_DIR"/*.md; do
      [ -f "$f" ] || continue
      base="$(basename "$f")"
      if ! printf '%s\n' "$TRACKED" | grep -qxF "agents/$base"; then
        UNTRACKED="${UNTRACKED}agents/${base}
"
      fi
    done
    if [ -z "$UNTRACKED" ]; then
      ok "(2) git tracking - všech $AGENT_COUNT agent souborů tracked v $CLAUDE_REPO"
    else
      ko "(2) git tracking - untracked agent soubory v $CLAUDE_REPO (commitni je):"
      printf '%s' "$UNTRACKED" | detail
    fi
  fi
fi

# ===========================================================================
# (3) Model alias + (4) Tools case + (5) Name slug - frontmatter per agent
# ===========================================================================
if [ "$HAVE_AGENTS" -eq 1 ]; then
  MODEL_FAILS=""
  MODEL_WARNS=""
  TOOLS_FAILS=""
  NAME_FAILS=""

  for f in "$AGENTS_DIR"/*.md; do
    [ -f "$f" ] || continue
    base="$(basename "$f" .md)"
    FM="$(extract_frontmatter "$f")"

    # --- (3) model alias ---
    model="$(printf '%s\n' "$FM" | sed -n 's/^model:[[:space:]]*//p' | head -1 | sed 's/[[:space:]]*$//')"
    if [ -z "$model" ]; then
      MODEL_WARNS="${MODEL_WARNS}${base}: model chybí (inherit z parent session)
"
    else
      case "$model" in
        fable|opus|sonnet|haiku) : ;;
        *)
          MODEL_FAILS="${MODEL_FAILS}${base}: model '${model}' není alias fable|opus|sonnet|haiku (pinnutá verze zakázána)
"
          ;;
      esac
    fi

    # --- (4) tools case ---
    tools_line="$(printf '%s\n' "$FM" | sed -n 's/^tools:[[:space:]]*//p' | head -1)"
    if [ -n "$tools_line" ]; then
      bad="$(printf '%s\n' "$tools_line" | awk -v canon="$CANON_TOOLS" '
        BEGIN { n = split(canon, C, " "); for (i = 1; i <= n; i++) L[tolower(C[i])] = C[i] }
        {
          m = split($0, T, ",")
          for (i = 1; i <= m; i++) {
            t = T[i]
            gsub(/^[[:space:]]+/, "", t); gsub(/[[:space:]]+$/, "", t)
            if (t == "" || t ~ /^mcp__/) continue
            lt = tolower(t)
            if (lt in L && t != L[lt]) {
              if (out != "") out = out "; "
              out = out t " -> správně " L[lt]
            }
          }
        }
        END { if (out != "") print out }
      ')"
      if [ -n "$bad" ]; then
        TOOLS_FAILS="${TOOLS_FAILS}${base}: ${bad}
"
      fi
    fi

    # --- (5) name slug ---
    name="$(printf '%s\n' "$FM" | sed -n 's/^name:[[:space:]]*//p' | head -1 | sed 's/[[:space:]]*$//')"
    if [ -z "$name" ]; then
      NAME_FAILS="${NAME_FAILS}${base}: pole name chybí ve frontmatteru
"
    elif ! printf '%s' "$name" | LC_ALL=C grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$'; then
      NAME_FAILS="${NAME_FAILS}${base}: name '${name}' není kebab-case slug (jen a-z, 0-9, pomlčky; bez diakritiky a mezer)
"
    fi
  done

  # --- (3) vyhodnocení ---
  if [ -n "$MODEL_FAILS" ]; then
    ko "(3) model alias - neplatné hodnoty model: ve frontmatteru:"
    printf '%s' "$MODEL_FAILS" | detail
  elif [ -n "$MODEL_WARNS" ]; then
    wa "(3) model alias - žádná neplatná hodnota, ale agenti bez pole model (inherit):"
    printf '%s' "$MODEL_WARNS" | detail
  else
    ok "(3) model alias - všech $AGENT_COUNT agentů má model fable|opus|sonnet|haiku"
  fi

  # --- (4) vyhodnocení ---
  if [ -n "$TOOLS_FAILS" ]; then
    ko "(4) tools case - built-in tooly s chybnou velikostí písmen (tichý bug, tool se nenamapuje):"
    printf '%s' "$TOOLS_FAILS" | detail
  else
    ok "(4) tools case - built-in tooly ve frontmatter tools: korektně PascalCase"
  fi

  # --- (5) vyhodnocení ---
  if [ -n "$NAME_FAILS" ]; then
    ko "(5) name slug - neplatná pole name: ve frontmatteru:"
    printf '%s' "$NAME_FAILS" | detail
  else
    ok "(5) name slug - všech $AGENT_COUNT agentů má name kebab-case bez diakritiky"
  fi
fi

# ===========================================================================
# (6) OR-06 META - team-outcomes/ bez duplicitních NNN- prefixů
# ===========================================================================
if [ ! -d "$TO_DIR" ]; then
  wa "(6) OR-06 - adresář $TO_DIR/ neexistuje, kontrola číslování přeskočena"
else
  DUPES="$(ls -1 "$TO_DIR" 2>/dev/null | grep -E '^[0-9]{3}-' | cut -c1-3 | sort | uniq -d)"
  if [ -n "$DUPES" ]; then
    ko "(6) OR-06 - duplicitní NNN- prefixy v $TO_DIR/: $(printf '%s' "$DUPES" | tr '\n' ' ')"
  else
    NUMBERED="$(ls -1 "$TO_DIR" 2>/dev/null | grep -cE '^[0-9]{3}-')"
    ok "(6) OR-06 - $NUMBERED číslovaných souborů v $TO_DIR/ bez duplicitních prefixů"
  fi
fi

# ===========================================================================
# (7) OR-10 - header operations/status.md bez řetězení historie
# ===========================================================================
if [ ! -f "$STATUS_MD" ]; then
  ko "(7) OR-10 - $STATUS_MD neexistuje (OR-03 kontrakt vyžaduje status.md s headerem)"
else
  HEADER="$(extract_header "$STATUS_MD")"
  if printf '%s\n' "$HEADER" | grep -qF 'Předchozí:'; then
    ko "(7) OR-10 - header $STATUS_MD obsahuje 'Předchozí:' (historie patří do rolling logu POD header)"
  else
    ok "(7) OR-10 - header $STATUS_MD bez řetězení historie"
  fi
fi

# ===========================================================================
# (8) Brána changesetů - dosah mimo METU musí být deklarovaný changesetem
#     (8a) rozsah commitů od cutoffu, fail-closed
#     (8b) pracovní strom, advisory (WARN) - chytá autora před commitem
# ===========================================================================
if [ ! -f "$CHANGESETS_README" ]; then
  ko "(8a) brána changesetů - chybí $CHANGESETS_README, bránu nelze konfigurovat (fail-closed: nezjištěno se nepočítá jako PASS)"
else
  CUT_LINE="$(grep -m1 'Brána platí od' "$CHANGESETS_README" 2>/dev/null || true)"
  CUT_META="$(printf '%s\n' "$CUT_LINE" | sed -n 's/.*META `\([0-9a-f]\{7,40\}\)`.*/\1/p')"
  CUT_LIB="$(printf '%s\n' "$CUT_LINE" | sed -n 's/.*GLOBAL `\([0-9a-f]\{7,40\}\)`.*/\1/p')"
  [ -n "$SINCE_META" ] && CUT_META="$SINCE_META"
  [ -n "$SINCE_LIB" ] && CUT_LIB="$SINCE_LIB"

  if [ -z "$CUT_META" ] || [ -z "$CUT_LIB" ]; then
    ko "(8a) brána changesetů - v $CHANGESETS_README nejde přečíst pole 'Brána platí od' (očekáván tvar: META \`<sha>\` / GLOBAL \`<sha>\`)"
  else
    OUT_META="$(gate_scan_range "." "META" "$CUT_META" "$WATCH_META" 1)"; RC_META=$?
    OUT_LIB="$(gate_scan_range "$CLAUDE_REPO" "GLOBAL" "$CUT_LIB" "$WATCH_LIB" 0)"; RC_LIB=$?

    GATE_DETAIL="$(printf '%s\n%s\n' "$OUT_META" "$OUT_LIB" | grep -v '^#stats ' | grep -v '^#vyjimka ' | grep -v '^$' || true)"
    GATE_EXC="$(printf '%s\n%s\n' "$OUT_META" "$OUT_LIB" | grep '^#vyjimka ' | sed 's/^#vyjimka //' || true)"
    GATE_EVAL="$(printf '%s\n%s\n' "$OUT_META" "$OUT_LIB" | sed -n 's/^#stats \([0-9]*\) .*/\1/p' \
      | awk '{ s += $1 } END { print s+0 }')"
    GATE_EXC_N="$(printf '%s\n%s\n' "$OUT_META" "$OUT_LIB" | sed -n 's/^#stats [0-9]* [0-9]* \([0-9]*\)$/\1/p' \
      | awk '{ s += $1 } END { print s+0 }')"

    if [ "$RC_META" -eq 2 ] || [ "$RC_LIB" -eq 2 ]; then
      ko "(8a) brána changesetů - rozsah commitů nelze posoudit (fail-closed):"
      printf '%s\n' "$GATE_DETAIL" | detail
    elif [ "$RC_META" -eq 1 ] || [ "$RC_LIB" -eq 1 ]; then
      ko "(8a) brána changesetů - commity s dosahem mimo METU bez pokrytí (doplň changeset, nebo trailer 'Changeset: <ID>' / 'Changeset: none (<důvod>)'):"
      printf '%s\n' "$GATE_DETAIL" | detail
    elif [ "$GATE_EVAL" -eq 0 ]; then
      ok "(8a) brána changesetů - od cutoffu (META $CUT_META / GLOBAL $CUT_LIB) žádný commit s dosahem mimo METU; historie před cutoffem se neposuzuje (forward-only)"
    elif [ "$GATE_EXC_N" -gt 0 ]; then
      ok "(8a) brána changesetů - $GATE_EVAL commitů s dosahem mimo METU od cutoffu (META $CUT_META / GLOBAL $CUT_LIB), pokryté; z toho $GATE_EXC_N evidovanou výjimkou:"
      printf '%s\n' "$GATE_EXC" | detail
    else
      ok "(8a) brána changesetů - $GATE_EVAL commitů s dosahem mimo METU od cutoffu (META $CUT_META / GLOBAL $CUT_LIB), všechny pokryté"
    fi
  fi

  # --- (8b) pracovní strom, advisory ---------------------------------------
  WT_DIRTY="$( { gate_worktree_paths "." "$WATCH_META" "META"; \
                 gate_worktree_paths "$CLAUDE_REPO" "$WATCH_LIB" "GLOBAL"; } 2>/dev/null | grep -v '^$' || true)"
  if [ -z "$WT_DIRTY" ]; then
    ok "(8b) pracovní strom - žádné rozpracované změny pod hlídanými cestami"
  else
    WT_N="$(printf '%s\n' "$WT_DIRTY" | wc -l | tr -d ' ')"
    if git status --porcelain -uall 2>/dev/null | sed 's/^...//; s/^.* -> //' \
       | grep -qE "^${CHANGESETS_DIR}/[^/]+\.md$"; then
      ok "(8b) pracovní strom - $WT_N rozpracovaných souborů pod hlídanými cestami a v METĚ je rozpracovaný changeset (pokrytí se ověří až u commitu kontrolou 8a)"
    else
      wa "(8b) pracovní strom - $WT_N rozpracovaných souborů pod hlídanými cestami a žádný rozpracovaný changeset v METĚ (advisory, commit zastaví až 8a):"
      printf '%s\n' "$WT_DIRTY" | head -20 | detail
      [ "$WT_N" -gt 20 ] && printf '        ... a dalších %d\n' "$((WT_N - 20))"
    fi
  fi
fi

# ===========================================================================
# (9) Obousměrná parita META <-> šablony (anti N-02)
#
# N-02 byl drift směrem od reality k platformě: tenant zrušil složku inbox/, META
# držela zaniklý stav pět dní. Kontroly 1-8 hlídají směr platforma -> jednotka;
# tenhle blok hlídá, že platforma sama sobě nelže.
#   (9a) validátor -> šablona: co validate.sh vyžaduje, musí být v šabloně
#   (9d) META CLAUDE.md -> šablony: výčet norem sedí (porovnává se VÝČET, ne znění)
# ===========================================================================

# --- (9a) cesty vyžadované validátorem existují v šabloně -------------------
if [ ! -f "$VALIDATE_SH" ]; then
  ko "(9a) parita validátor/šablona - chybí $VALIDATE_SH, kontrolu nelze provést"
else
  PARITY_MISS=""
  PARITY_N=0
  for pair in "TENANT:$TPL_TENANT" "STUDIO:$TPL_STUDIO"; do
    pmode="${pair%%:*}"
    ptpl="${pair#*:}"
    if [ ! -d "$ptpl" ]; then
      PARITY_MISS="${PARITY_MISS}${pmode}: šablona $ptpl neexistuje
"
      continue
    fi
    for p in $(proj_paths_in_mode "$pmode"); do
      is_optional_proj_path "$p" && continue
      PARITY_N=$((PARITY_N + 1))
      if [ ! -e "$ptpl/$p" ]; then
        PARITY_MISS="${PARITY_MISS}${pmode}: validate.sh vyžaduje \"$p\", v $ptpl/ to není
"
      fi
    done
  done
  if [ -n "$PARITY_MISS" ]; then
    ko "(9a) parita validátor/šablona - validátor vyžaduje cestu, kterou šablona nemá (přesně třída chyby N-02):"
    printf '%s' "$PARITY_MISS" | detail
  else
    ok "(9a) parita validátor/šablona - všech $PARITY_N vyžadovaných cest (tenant + studio) existuje v odpovídající šabloně"
  fi
fi

# --- (9b) parita manifest <-> šablona ---------------------------------------
#
# Kontrakt: manifest klasifikuje cesty JEDNOTKY, zdroj kopie je táž relativní cesta
# v odpovídající šabloně. Kontrola drží obě strany:
#   směr 1 - engine cesta, kterou šablona nemá = mrtvá deklarace (upgrade by kopíroval
#            neexistující soubor; přesně třída nálezu VERSION + manifest.json do 2.2.2),
#   směr 2 - soubor v šabloně bez zařazení = díra v seamu. Fail-closed politika ho sice
#            nechá být, ale jen dokud o něm někdo ví; tichá nezařazená cesta je nález.
# Engine položka navíc musí být konkrétní soubor - glob v engine znamená "přepiš, co najdeš".
if [ ! -f "$SEAM_LIB" ]; then
  ko "(9b) parita manifest/šablona - chybí $SEAM_LIB, kontrolu nelze provést"
elif [ ! -f "$MANIFEST_JSON" ]; then
  ko "(9b) parita manifest/šablona - chybí $MANIFEST_JSON, kontrolu nelze provést"
elif ! tracked_in_git "$SEAM_LIB"; then
  ko "(9b) parita manifest/šablona - $SEAM_LIB není verzovaný v gitu, NESOURCUJU ho (brána G3): netrackovaný soubor, který se má vykonat, je vždycky nález"
else
  # shellcheck source=lib/seam.sh
  . "$SEAM_LIB"
  SEAM_FAIL=""
  SEAM_N=0
  for seam_trio in "studio:$TPL_STUDIO:engine:state" "tenant:$TPL_TENANT:engine_tenant:state_tenant"; do
    slabel="${seam_trio%%:*}"
    srest="${seam_trio#*:}"
    stpl="${srest%%:*}"
    srest="${srest#*:}"
    skey_e="${srest%%:*}"
    skey_s="${srest#*:}"
    if [ ! -d "$stpl" ]; then
      SEAM_FAIL="${SEAM_FAIL}${slabel}: šablona $stpl neexistuje
"
      continue
    fi
    SEAM_E="$(seam_paths "$MANIFEST_JSON" "$skey_e")"
    SEAM_S="$(seam_paths "$MANIFEST_JSON" "$skey_s")"
    if [ -z "$SEAM_E" ]; then
      SEAM_FAIL="${SEAM_FAIL}${slabel}: seznam \"$skey_e\" v $MANIFEST_JSON je prázdný nebo nečitelný
"
      continue
    fi
    SEAM_N=$((SEAM_N + $(printf '%s\n' "$SEAM_E" | grep -c .)))
    SHAPE="$(seam_engine_shape_problems "$SEAM_E")"
    if [ -n "$SHAPE" ]; then
      SEAM_FAIL="${SEAM_FAIL}${slabel}: \"$skey_e\" obsahuje glob nebo adresář (engine je vždy konkrétní soubor): $(printf '%s' "$SHAPE" | tr '\n' ' ')
"
    fi
    DEAD="$(seam_dead_paths "$stpl" "$SEAM_E")"
    if [ -n "$DEAD" ]; then
      SEAM_FAIL="${SEAM_FAIL}${slabel}: \"$skey_e\" deklaruje cestu, kterou $stpl/ nemá: $(printf '%s' "$DEAD" | tr '\n' ' ')
"
    fi
    UNCL="$(seam_unclassified "$stpl" "$SEAM_E" "$SEAM_S")"
    if [ -n "$UNCL" ]; then
      SEAM_FAIL="${SEAM_FAIL}${slabel}: $stpl/ nese soubor nezařazený do \"$skey_e\" ani \"$skey_s\": $(printf '%s' "$UNCL" | tr '\n' ' ')
"
    fi
  done
  if [ -n "$SEAM_FAIL" ]; then
    ko "(9b) parita manifest/šablona - seam se rozchází se šablonou:"
    printf '%s' "$SEAM_FAIL" | detail
  else
    ok "(9b) parita manifest/šablona - $SEAM_N engine cest má soubor v šabloně a každý soubor obou šablon je zařazen"
  fi
fi

# --- (9d) výčet norem META vs. šablony -------------------------------------
META_ORS="$(meta_or_ids)"
if [ -z "$META_ORS" ]; then
  ko "(9d) parita norem - v CLAUDE.md nenalezen žádný nadpis '### OR-NN' (kotva výčtu; bez ní je kontrola slepá - viz koordinace s B-064)"
else
  META_OR_N="$(printf '%s\n' "$META_ORS" | grep -c .)"
  NORM_FAIL=""
  NORM_NOTE=""
  for pair in "tenant:$TPL_TENANT" "studio:$TPL_STUDIO"; do
    nlabel="${pair%%:*}"
    ntpl="${pair#*:}"
    NSRC=""
    [ -f "$ntpl/CLAUDE.md" ] && NSRC="$NSRC $ntpl/CLAUDE.md"
    [ -f "$ntpl/operations/00-normy.md" ] && NSRC="$NSRC $ntpl/operations/00-normy.md"
    if [ -z "$NSRC" ]; then
      NORM_FAIL="${NORM_FAIL}${nlabel}: v $ntpl/ není ani CLAUDE.md, ani operations/00-normy.md - výčet norem nemá kde být
"
      continue
    fi
    # shellcheck disable=SC2086
    TPL_ORS="$(template_or_ids $NSRC)"
    # engine lokace existuje, ale výtah v ní ještě není naplněný (placeholder)
    if [ -f "$ntpl/operations/00-normy.md" ] \
       && [ -z "$(template_or_ids "$ntpl/operations/00-normy.md")" ]; then
      NORM_NOTE="${NORM_NOTE}${nlabel}: operations/00-normy.md existuje, ale výčet v něm zatím není naplněný - parita se počítá proti CLAUDE.md
"
    fi
    MISS="$(ids_missing_in "$META_ORS" "$TPL_ORS")"
    EXTRA="$(ids_missing_in "$TPL_ORS" "$META_ORS")"
    if [ -n "$MISS" ]; then
      NORM_FAIL="${NORM_FAIL}${nlabel}: v šabloně chybí norma z METY:${MISS}
"
    fi
    if [ -n "$EXTRA" ]; then
      NORM_FAIL="${NORM_FAIL}${nlabel}: šablona deklaruje normu, kterou META nezná:${EXTRA}
"
    fi
  done
  [ -n "$NORM_NOTE" ] && printf '%s' "$NORM_NOTE" | sed 's/^/Poznámka: /'
  if [ -n "$NORM_FAIL" ]; then
    ko "(9d) parita norem - výčet OR v šablonách se rozchází s METOU ($META_OR_N norem); porovnává se výčet identifikátorů, ne znění - znění norem vlastní Quentin META:"
    printf '%s' "$NORM_FAIL" | detail
  else
    ok "(9d) parita norem - obě šablony deklarují stejný výčet $META_OR_N norem jako META CLAUDE.md"
  fi
fi

# --- (10) jeden domov verze platformy --------------------------------------
#
# scaffold/VERSION je jediný zdroj pravdy o čísle verze platformy (osa A); ostatní místa
# ho čtou za běhu (validate.sh do baseline, render.js do manifestu). Jedno druhé místo
# přesto existuje a existovat musí: manifest.json je statický JSON, který jiný soubor
# přečíst neumí. Ruční synchronizace čísla ve dvou souborech selže při prvním spěchu,
# takže shodu hlídá tahle kontrola.
if [ ! -f "$VERSION_FILE" ]; then
  ko "(10) verze platformy - chybí $VERSION_FILE, jediný zdroj pravdy o čísle"
else
  PLAT_V="$(head -1 "$VERSION_FILE" | tr -d '[:space:]')"
  MANIFEST_V="$(grep -o '"scaffold_version"[[:space:]]*:[[:space:]]*"[^"]*"' "$MANIFEST_JSON" 2>/dev/null \
    | head -1 | sed 's/.*"\([^"]*\)"$/\1/')"
  if ! printf '%s' "$PLAT_V" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    ko "(10) verze platformy - $VERSION_FILE neobsahuje semver (nalezeno: \"$PLAT_V\")"
  elif [ ! -f "$MANIFEST_JSON" ]; then
    ko "(10) verze platformy - chybí $MANIFEST_JSON, shodu čísla nelze ověřit"
  elif [ -z "$MANIFEST_V" ]; then
    ko "(10) verze platformy - v $MANIFEST_JSON není pole scaffold_version, shodu nelze ověřit"
  elif [ "$MANIFEST_V" != "$PLAT_V" ]; then
    ko "(10) verze platformy - $VERSION_FILE má $PLAT_V, $MANIFEST_JSON má $MANIFEST_V; bump jde oběma místy naráz a vždy s changesetem"
  else
    ok "(10) verze platformy - $PLAT_V shodně v $VERSION_FILE i $MANIFEST_JSON"
  fi
fi

# --- (11) index platformy sedí s měřenou plochou ----------------------------
#
# Druhá třída změn vedle changesetů: změna kanonického domova, kterou nikdo nepřebírá,
# ale čte ji čtecí vrstva. Changeset se za ni nevyžaduje (šumící brána se vypne), index
# ano - stojí jeden příkaz. Vlastní artefakty generátoru se neměří, viz jeho hlavička.
#
# CO SE MĚŘÍ: v ručním běhu pracovní strom, v režimu --hook plocha commitu (viz úvod
# skriptu). Verdikt má jednoho adresáta - toho, kdo právě commituje - a ten může
# odpovídat jen za obsah svého commitu, ne za rozdělanou práci ostatních v repu.
#
# Váha se řídí polem stav_deklarace: dokud obsah deklarace není označený jako platný,
# je rozdíl WARN. Vlastník obsahu (Quentin META) bránu zapne jedním slovem v deklaraci -
# a do té doby se kontrola nechová jako závazná nad textem, který je pořád návrh.

# Měřené domovy METY, které má někdo rozpracované. Čte se hotový index na disku (jedna
# rychlá pasáž), ne druhý běh generátoru: je to popisek k verdiktu, ne verdikt.
#
# Co "rozpracované" znamená, se mezi režimy liší, a splynout to nesmí:
#   - v hooku vůči PLOŠE: co je v commitu, není rozpracované, i když se to liší od HEAD
#     ("git diff" bez --cached, tedy druhý sloupec porcelain výstupu, plus neevidované),
#   - v ručním běhu vůči HEAD: staged i nestaged, protože obojí je důvod, proč index
#     měří obsah, který zatím nikdo nemá.
merene_domovy() {
  [ -f "$PLATFORM_INDEX" ] || return 1
  awk '
    /^      "cesta": / { c = $0; sub(/.*"cesta": "/, "", c); sub(/".*/, "", c) }
    /^      "koren": "META"/ { m = 1 }
    /^      "kardinalita": "singleton"/ { s = 1 }
    /^    \}/ { if (m && s && c != "") print c; c = ""; m = 0; s = 0 }
  ' "$PLATFORM_INDEX"
}

merene_rozpracovane() { # <hook|strom>
  mr_merene="$(merene_domovy)" || return 0
  [ -n "$mr_merene" ] || return 0
  if [ "$1" = "hook" ]; then
    { git diff --name-only 2>/dev/null
      git ls-files --others --exclude-standard 2>/dev/null; }
  else
    git status --porcelain -uall 2>/dev/null | sed 's/^...//; s/^.* -> //; s/^"//; s/"$//'
  fi | grep -xF "$mr_merene" 2>/dev/null | LC_ALL=C sort -u
}

if [ ! -f "$GEN_INDEX" ]; then
  ko "(11) index platformy - chybí $GEN_INDEX, shodu indexu s měřenou plochou nelze ověřit (fail-closed)"
elif [ ! -f "$INDEX_CONFIG" ]; then
  ko "(11) index platformy - chybí $INDEX_CONFIG, deklarace domovů neexistuje"
elif ! tracked_in_git "$GEN_INDEX"; then
  ko "(11) index platformy - $GEN_INDEX není verzovaný v gitu, NESPOUŠTÍM ho (brána G3)"
else
  IDX_STAV="$(grep -m1 '"stav"' "$INDEX_CONFIG" | sed 's/.*"stav"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')"
  [ -n "$IDX_STAV" ] || IDX_STAV="nezjisteno"
  if [ "$REZIM_HOOK" -eq 1 ]; then
    IDX_PLOCHA="plocha commitu"
    IDX_NAPRAVA="bash $GEN_INDEX . --plocha -- <cesty, které commituješ>, pak obě cesty přidej do commitu"
    IDX_OUT="$(bash "$GEN_INDEX" . --plocha --check --quiet 2>&1)"; IDX_RC=$?
  else
    IDX_PLOCHA="disk"
    IDX_NAPRAVA="bash $GEN_INDEX ."
    IDX_OUT="$(bash "$GEN_INDEX" . --check --quiet 2>&1)"; IDX_RC=$?
  fi
  if [ "$IDX_RC" -eq 0 ]; then
    ok "(11) index platformy - $PLATFORM_INDEX i $PLATFORM_INDEX_MD odpovídají, měřeno proti: $IDX_PLOCHA (stav deklarace: $IDX_STAV)"
  elif [ "$IDX_RC" -eq 2 ]; then
    ko "(11) index platformy - generátor odmítl vstup (chyba použití), index nelze posoudit:"
    printf '%s\n' "$IDX_OUT" | head -6 | detail
  elif printf '%s\n' "$IDX_OUT" | grep -q '^CHYBA:'; then
    # Generátor doběhl s chybou, ne s rozdílem (nešla materializovat plocha, chybí
    # otisk, deklarace je vadná). "Nepodařilo se zjistit" je vlastní stav a nesmí se
    # slít s "liší se": rozdíl by se při nepotvrzené deklaraci degradoval na WARN,
    # takže by neznámý výsledek prošel jako skoro v pořádku.
    ko "(11) index platformy - index NELZE posoudit, generátor skončil chybou (fail-closed; měřeno proti: $IDX_PLOCHA):"
    printf '%s\n' "$IDX_OUT" | grep '^CHYBA:' | head -3 | detail
  elif [ "$IDX_STAV" = "platny" ]; then
    ko "(11) index platformy - index neodpovídá, měřeno proti: $IDX_PLOCHA; náprava: $IDX_NAPRAVA"
    printf '%s\n' "$IDX_OUT" | grep -E '^(ROZDÍL|CHYBA)' | head -4 | detail
  else
    wa "(11) index platformy - index neodpovídá ($IDX_PLOCHA), ale deklarace má stav \"$IDX_STAV\" (ne \"platny\"), takže hlásím a nezastavuji; náprava: $IDX_NAPRAVA"
    printf '%s\n' "$IDX_OUT" | grep -E '^(ROZDÍL|CHYBA)' | head -4 | detail
  fi

  # Atribuce rozdílu. Bez ní řeší autor cizí chybu: "index nesedí" vypadá stejně, ať ho
  # rozhodil vlastní commit, nebo soubor, kterého se autor ani nedotkl.
  if [ "$REZIM_HOOK" -eq 1 ]; then IDX_CIZI="$(merene_rozpracovane hook || true)"
  else IDX_CIZI="$(merene_rozpracovane strom || true)"; fi
  if [ -n "$IDX_CIZI" ]; then
    IDX_CIZI_N="$(printf '%s\n' "$IDX_CIZI" | wc -l | tr -d ' ')"
    if [ "$REZIM_HOOK" -eq 1 ]; then
      # V hooku je "rozpracované" míněno vůči ploše commitu: co je v commitu, to se tu
      # neobjeví. Zbytek je cizí pracovní stůl - hlásí se, commit nezastavuje.
      printf 'Poznámka: měřených domovů mimo tenhle commit má někdo rozpracovaných %d (index s diskem sedět nebude, dokud je nezacommituje; tvého commitu se to netýká):\n' "$IDX_CIZI_N"
      printf '%s\n' "$IDX_CIZI" | head -10 | detail
    else
      printf 'Poznámka: %d měřených domovů je rozpracovaných v pracovním stromu - dokud se nezacommitují, index z nich měří stav, který nikdo nemá:\n' "$IDX_CIZI_N"
      printf '%s\n' "$IDX_CIZI" | head -10 | detail
    fi
  fi
fi

# --- (12) parita indexu a čtené plochy kokpitu ------------------------------
#
# Index vybírá, allowlist autorizuje - nikdy naopak (invariant Ariadne, 040 sekce 4.3).
# Tahle kontrola proto NIC nepovoluje: jen porovnává, co index tvrdí o čitelnosti domova,
# s tím, co o sobě čtecí vrstva kokpitu exportuje v contracts/read-purposes.json.
#
# Verdikt je poradní i technicky: shell vyhodnocuje vzory nad TEXTOVOU cestou bez realpath,
# kokpit klasifikuje až po rozbalení symlinku (041 sekce 4.3). Proto WARN, nikdy FAIL -
# a proto se výsledek nikdy nesmí použít k povolení čtení.
#
# Váhy per 041 sekce 4.4: N1 bez účelu (vlastník session kokpitu), N2 rozsah vyloučen
# (vlastník Stanislav, jiný text - hlášení, které jde umlčet přidáním hodnoty do pole,
# se do měsíce umlčí). N3 (účel bez konzumenta) sem nepatří, řeší ho kokpit při startu.
COCKPIT_ROOT="${NSL_COCKPIT_ROOT:-}"
READ_PURPOSES="$COCKPIT_ROOT/contracts/read-purposes.json"
if [ ! -f "$GEN_INDEX" ] || [ ! -f "$INDEX_CONFIG" ]; then
  : # (11) už selhala, druhé hlášení téhož by bylo jen šum
elif [ ! -f "$READ_PURPOSES" ]; then
  wa "(12) parita indexu a čtené plochy - $READ_PURPOSES neexistuje, paritu nelze posoudit (nezjištěno se nepočítá jako v pořádku); export čtecího registru je na straně kokpitu, schéma read-purposes/v1 i v2 per team-outcomes/041 sekce 4.2"
else
  RP_SCHEMA="$(grep -m1 '"schema"' "$READ_PURPOSES" | sed 's/.*"schema"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')"
  case "$RP_SCHEMA" in
    read-purposes/v1|read-purposes/v2) RP_ZNAME=1 ;;
    *) RP_ZNAME=0 ;;
  esac
  if [ "$RP_ZNAME" -eq 0 ]; then
    wa "(12) parita indexu a čtené plochy - $READ_PURPOSES má schema \"$RP_SCHEMA\", umím read-purposes/v1 a read-purposes/v2"
  else
    META_ABS="$(pwd)"

    # --- zástupné symboly ve vzorech (schéma v2) ----------------------------
    #
    # Od v2 nesou vzory účelů i hodnoty klasifikačních pravidel místo domovské cesty
    # zástupný symbol, aby byl export vlastnost KÓDU, ne stroje: v každém klonu vznikne
    # bajt po bajtu stejný soubor. Kontrola je proto musí rozvinout DŘÍV, než vzor půjde
    # do grep -E. Bez toho netrefí kotvený vzor nic a každý čitelný domov METY vypadne
    # jako "bez účelu" - falešný poplach o dvaceti položkách.
    #
    # {KOKPIT} rozvinout nejde a nemá kde: kořen běžící instance kokpitu zná jen ta
    # instance a hádat ho podle jména adresáře by znamenalo vyrobit si druhý zdroj pravdy.
    # Nahrazuje se cestou, která na disku nikdy neexistuje, takže ta větev vzoru nikdy
    # nic netrefí a zbytek vzoru (alternace s ostatními kořeny) zůstane funkční. Prázdná
    # náhrada je zakázaná: z "^{KOKPIT}/..." by udělala "^/...", tedy vzor trefující
    # cesty od kořene disku.
    RP_KOKPIT_MIMO='/nsl-koren-instance-kokpitu-mimo-merenou-plochu'
    # Kořen projektů je parametr prostředí, ne konstanta v kódu: stroj, na kterém
    # nástroj běží, nemá být zapsaný ve verzovaném souboru.
    RP_PROJEKTY="${NSL_PROJEKTY_ROOT:-$HOME/${NSL_PROJEKTY_DIR:-Projects}}"
    rp_rozvin() { # <text se symboly> -> text s rozvinutými symboly
      printf '%s' "$1" \
        | sed "s|{META}|$META_ABS|g; s|{LIB}|$HOME/.claude|g; s|{PROJEKTY}|$RP_PROJEKTY|g; s|{KOKPIT}|$RP_KOKPIT_MIMO|g"
    }
    # Symbol, který po rozvinutí zůstal, je NEZJIŠTĚNO, ne nález: co neumím vyhodnotit,
    # z toho nesmím udělat závěr o domově. Interval "{2,3}" v ERE se nezamění - zástupné
    # symboly začínají písmenem.
    rp_neznamy_symbol() { case "$1" in *'{'[A-Za-z]*) return 0 ;; esac; return 1; }
    # Vzor, který grep -E nepřeloží, je taky nezjištěno (rc > 1 = chyba překladu).
    rp_vzor_pouzitelny() {
      printf 'x\n' | grep -Eq -- "$1" >/dev/null 2>&1
      [ "$?" -le 1 ]
    }
    # JSON escape -> holý regulární výraz. Nejdřív "\\" na jeden zpětný lomítko, teprve
    # pak "\/" na lomítko; opačné pořadí by z "\\." nechalo dvě lomítka a vzor by pak
    # hledal doslovný zpětný lomeno v cestě, tedy netrefil by nikdy nic. Přesně to
    # dělal registr účelu `roster` (`agent-stack\\.md`) a domov vypadal jako bez účelu.
    # Escapovaná uvozovka se nečeká - registr ji per kontrakt nemá.
    rp_odescapuj() { printf '%s' "$1" | sed 's|\\\\|\\|g; s|\\/|/|g'; }

    N1_LIST=""; N2_LIST=""; PAR_N=0; PAR_SKIP=0
    # vzory účelů: id<TAB>rozvinutý ERE vzor<TAB>rozsahy oddělené mezerou
    # Nevyhodnotitelné pravidlo dostane prázdný vzor a spočítá se níž jako nezjištěno.
    RP_RULES="$(json_objects_of "$READ_PURPOSES" cteni | while IFS= read -r rp_obj; do
      rp_id="$(obj_scalar "$rp_obj" id)"
      rp_vzor="$(obj_scalar "$rp_obj" vzor)"
      rp_roz="$(obj_strings "$rp_obj" rozsahy | tr '\n' ' ')"
      [ -n "$rp_vzor" ] || continue
      rp_vzor="$(rp_rozvin "$(rp_odescapuj "$rp_vzor")")"
      if rp_neznamy_symbol "$rp_vzor" || ! rp_vzor_pouzitelny "$rp_vzor"; then
        printf '%s\t\t%s\n' "$rp_id" "$rp_roz"
      else
        printf '%s\t%s\t%s\n' "$rp_id" "$rp_vzor" "$rp_roz"
      fi
    done)"
    # klasifikační pravidla: pořadí rozhoduje, první shoda vyhrává (kontrakt C4)
    # Pravidlo s nerozvinutelným symbolem dostane typ "neznamy" - neklasifikuje a počítá
    # se do nezjištěno, protože jinak by rozsah tiše určilo až pravidlo za ním.
    RP_CLASS="$(json_objects_of "$READ_PURPOSES" pravidla | while IFS= read -r rp_obj; do
      rp_typ="$(obj_scalar "$rp_obj" typ)"
      rp_hod="$(rp_rozvin "$(obj_scalar "$rp_obj" hodnota)")"
      rp_neznamy_symbol "$rp_hod" && rp_typ="neznamy"
      printf '%s\t%s\t%s\n' "$rp_typ" "$rp_hod" "$(obj_scalar "$rp_obj" rozsah)"
    done)"
    RP_NEZJ="$(printf '%s\n' "$RP_RULES" | awk -F'\t' 'NF && $2 == "" { print "účel " $1 }'
               printf '%s\n' "$RP_CLASS" | awk -F'\t' 'NF && $1 == "neznamy" { print "klasifikační pravidlo na " $2 }')"
    RP_NEZJ_N="$(printf '%s' "$RP_NEZJ" | grep -c '[^[:space:]]' || true)"
    RP_KOKPIT_N="$(grep -c '{KOKPIT}' "$READ_PURPOSES" 2>/dev/null || true)"
    RP_KOKPIT_TXT=""
    [ "$RP_KOKPIT_N" -gt 0 ] && RP_KOKPIT_TXT=", $RP_KOKPIT_N řádků registru se symbolem {KOKPIT} mimo měřenou plochu"
  fi

  # Paritu počítám jen tehdy, když registru rozumím celému. Kus, který neumím rozvinout,
  # by se jinak projevil jako domov "bez účelu", tedy jako nález o cizím souboru.
  if [ "${RP_ZNAME:-0}" -eq 1 ] && [ "${RP_NEZJ_N:-0}" -gt 0 ]; then
    wa "(12) parita indexu a čtené plochy - $RP_NEZJ_N položek registru neumím vyhodnotit (neznámý zástupný symbol nebo vzor, který grep -E nepřeloží); paritu proto NEposuzuji, nezjištěno se nepočítá ani jako v pořádku, ani jako nález:"
    printf '%s\n' "$RP_NEZJ" | detail
  elif [ "${RP_ZNAME:-0}" -eq 1 ]; then
    while IFS="$(printf '\t')" read -r ix_id ix_koren ix_cesta ix_kokpit ix_stav ix_kard ix_oblast; do
      [ "$ix_kokpit" = "true" ] || continue
      # Zástupný symbol ve vzoru cesty (<name>, <slug>) se nahradí ukázkovou hodnotou:
      # doslovné "<agent>" by proti regulárnímu výrazu nedávalo smysl a účel by vypadal
      # jako chybějící. Verdikt je stejně poradní, takže přiblížení je poctivější než ticho.
      ix_test="$(printf '%s' "$ix_cesta" | sed 's/<[^>]*>/vzor/g')"
      case "$ix_koren" in
        META) ix_abs="$META_ABS/$ix_test" ;;
        LIB)  ix_abs="$HOME/.claude/$ix_test" ;;
        *) PAR_SKIP=$((PAR_SKIP + 1)); continue ;;   # per instance nebo mimo disk: konkrétní cesta neexistuje
      esac
      PAR_N=$((PAR_N + 1))
      ix_hit=""; ix_scope=""
      OLD_IFS="$IFS"; IFS='
'
      for rule in $RP_RULES; do
        r_id="${rule%%	*}"; r_rest="${rule#*	}"
        r_vzor="${r_rest%%	*}"; r_roz="${r_rest#*	}"
        if printf '%s' "$ix_abs" | grep -Eq -- "$r_vzor" 2>/dev/null; then
          ix_hit="$r_id"; ix_scope="$r_roz"; break
        fi
      done
      IFS="$OLD_IFS"
      if [ -z "$ix_hit" ]; then
        N1_LIST="$N1_LIST{$ix_koren}/$ix_cesta
"
        continue
      fi
      # rozsah cesty per klasifikační pravidla, první shoda rozhoduje
      ix_class=""
      OLD_IFS="$IFS"; IFS='
'
      for crule in $RP_CLASS; do
        c_typ="${crule%%	*}"; c_rest="${crule#*	}"
        c_hod="${c_rest%%	*}"; c_roz="${c_rest#*	}"
        # hodnota je rozvinutá už při stavbě seznamu, tady se jen porovnává
        case "$c_typ" in
          segment) case "/$ix_abs/" in *"/$c_hod/"*) ix_class="$c_roz" ;; esac ;;
          prefix)  case "$ix_abs" in "$c_hod"*) ix_class="$c_roz" ;; esac ;;
          vychozi) ix_class="$c_roz" ;;
        esac
        [ -n "$ix_class" ] && break
      done
      IFS="$OLD_IFS"
      case " $ix_scope " in
        *" $ix_class "*) : ;;
        *) N2_LIST="$N2_LIST{$ix_koren}/$ix_cesta - účel $ix_hit nepouští rozsah \"$ix_class\"
" ;;
      esac
    done <<EOF
$(bash "$GEN_INDEX" . --list 2>/dev/null)
EOF
    N1_N="$(printf '%s' "$N1_LIST" | grep -c '[^[:space:]]' || true)"
    N2_N="$(printf '%s' "$N2_LIST" | grep -c '[^[:space:]]' || true)"
    if [ "$N1_N" -eq 0 ] && [ "$N2_N" -eq 0 ]; then
      ok "(12) parita indexu a čtené plochy - všech $PAR_N čitelných domovů má účel v $RP_SCHEMA ($PAR_SKIP per instance neposuzováno$RP_KOKPIT_TXT; verdikt je poradní, autorizuje allowlist)"
    else
      [ "$N1_N" -eq 0 ] || {
        wa "(12) parita indexu a čtené plochy - $N1_N domovů s cte_kokpit=true netrefí žádný účel v $RP_SCHEMA (N1, řeší session kokpitu: doplnit účel, nebo v deklaraci nastavit cte_kokpit=false):"
        printf '%s' "$N1_LIST" | detail
      }
      [ "$N2_N" -eq 0 ] || {
        wa "(12) parita indexu a čtené plochy - $N2_N domovů má účel, ale jejich rozsah účel nepouští (N2, ROZHODNUTÍ STANISLAVA jmenovitě - neodbavuj přidáním hodnoty do pole rozsahy):"
        printf '%s' "$N2_LIST" | detail
      }
    fi
  fi
fi

# ===========================================================================
# (13) Jeden adresář, jeden zápisový režim (rozsudek Ariadne, team-outcomes/046 H5)
#
# Knihovna drží dvě třídy obsahu, které se liší SMĚREM zdroje pravdy:
#   {LIB}/foundation/  platformní metodika, typ 1, zdroj pravdy je disk, píše ji člověk
#   {LIB}/nsl/         odvozeniny firemního obsahu, typ 2, zdroj pravdy je Notion,
#                      píše je nástroj (dnes /foundation-sync)
#
# Kontrola je OBOUSTRANNÁ schválně: tím klasifikaci nese OBSAH souboru a cesta je jen
# tvrzení, které se proti obsahu ověřuje. Rozpor je nález, ne důvod jedno přepsat druhým -
# stejná logika, jakou má platform-index-config.json u vztahu rozsah_ocekavany ke scopeOf().
# Bez téhle kontroly je věta "typ 2 nepatří do foundation/" jen dohoda v dokumentu.
#
# Režimní marker (kontrakt pro /foundation-sync, Karpathy) - obě řádky v prvních 20
# řádcích souboru, přesně v tomhle tvaru:
#   **Zdroj pravdy:** Notion ...
#   **Zapisuje:** nástroj ...
# Za nimi smí pokračovat libovolný text (pilíř, ID stránky, jméno skillu, věta o zákazu
# ruční editace). Kontroluje se jen hlavička, ne celý soubor: citace markeru v próze
# uprostřed metodického textu není chyba klasifikace.
# ===========================================================================
NSL_DIR="$CLAUDE_REPO/nsl"
FOUNDATION_DIR="$CLAUDE_REPO/foundation"
MARKER_ZDROJ='^\*\*Zdroj pravdy:\*\*[[:space:]]*Notion'
MARKER_ZAPIS='^\*\*Zapisuje:\*\*[[:space:]]*nástroj'

ma_marker() { # <soubor> <vzor> - 0 když je marker v hlavičce
  head -20 "$1" 2>/dev/null | grep -qE "$2"
}

REZIM_FAIL=""
NSL_N=0
if [ -d "$NSL_DIR" ]; then
  for f in $(find "$NSL_DIR" -type f 2>/dev/null | LC_ALL=C sort); do
    NSL_N=$((NSL_N + 1))
    base="nsl/${f#"$NSL_DIR"/}"
    case "$f" in
      *.md) : ;;
      *)
        REZIM_FAIL="${REZIM_FAIL}${base}: není markdown, režimní marker nemá kam napsat - odvozenina bez deklarovaného režimu do knihovny nepatří
"
        continue
        ;;
    esac
    chybi=""
    ma_marker "$f" "$MARKER_ZDROJ" || chybi="**Zdroj pravdy:** Notion"
    if ! ma_marker "$f" "$MARKER_ZAPIS"; then
      [ -n "$chybi" ] && chybi="$chybi a "
      chybi="${chybi}**Zapisuje:** nástroj"
    fi
    if [ -n "$chybi" ]; then
      REZIM_FAIL="${REZIM_FAIL}${base}: v hlavičce chybí $chybi (marker odvozeniny je povinný, jinak soubor tvrdí cestou něco, co obsahem nedokládá)
"
    fi
  done
fi

FOUND_N=0
if [ -d "$FOUNDATION_DIR" ]; then
  for f in "$FOUNDATION_DIR"/*.md; do
    [ -f "$f" ] || continue
    FOUND_N=$((FOUND_N + 1))
    if ma_marker "$f" "$MARKER_ZDROJ" || ma_marker "$f" "$MARKER_ZAPIS"; then
      REZIM_FAIL="${REZIM_FAIL}foundation/$(basename "$f"): nese režimní marker odvozeniny, ale leží v adresáři platformní metodiky (zdroj pravdy disk, píše člověk) - patří pod nsl/
"
    fi
  done
fi

if [ -n "$REZIM_FAIL" ]; then
  ko "(13) režim odvozenin - obsah souboru si odporuje s adresářem, ve kterém leží:"
  printf '%s' "$REZIM_FAIL" | detail
elif [ "$NSL_N" -eq 0 ]; then
  ok "(13) režim odvozenin - $FOUND_N souborů ve foundation/ bez markeru odvozeniny; nsl/ zatím nemá obsah (kontrola i hlídaná cesta stojí dřív než první soubor, což je záměr)"
else
  ok "(13) režim odvozenin - $NSL_N souborů v nsl/ nese marker odvozeniny, $FOUND_N souborů ve foundation/ ho nenese"
fi

# ===========================================================================
# (14) OR-02 sken secretů nad měřenou plochou
#
# Mechanická brzda k OR-02. Bez ní stojí pravidlo "secret nikdy v gitu" na tom, že si
# ho každý v pravou chvíli vzpomene - a jediné selhání téhle vzpomínky je nevratné,
# protože commit se nemaže, přepisuje se historie a hodnota se rotuje.
#
# CO SE MĚŘÍ: stejná dvojice jako u (11). Ruční běh měří disk ("je platforma teď
# v pořádku"), režim --hook měří PLOCHU COMMITU ("je v pořádku to, co se právě
# commituje"). Cizí rozdělaná práce tedy commit nezastaví; zastaví ho vlastní obsah.
#
# VÁHA: FAIL, a to od prvního dne. Sken nad METOU je dnes ČISTO (5 doložených falešných
# poplachů označeno 7. 8. 2026), takže brána startuje zelená - a jen zelená brána smí
# být tvrdá. Kdyby startovala červená, první, co by kdokoli udělal, je --no-verify.
#
# ŠUM SE ŘEŠÍ VZOREM, NE ZNAČKOU. Doložený falešný poplach se umlčí komentářem
# `sken-secretu:povoleno` na tomtéž řádku (je vidět v diffu a dá se na něj ptát).
# Ale když stejnou třídu shody vyrábí vzor sám - jako vzor "sk-klic" bez hranice slova,
# který chytal task-, risk- a opendesk- (osm shod nad portfoliem, nula pravých nálezů) -
# je náprava oprava vzoru, ne osm značek. Značka na chybu vzoru je dluh, který se rozseje.
#
# CONTAINMENT: nástroj hlásí lokaci a jméno vzoru, nikdy hodnotu. Validátor jeho výstup
# nepřepisuje ani nerozšiřuje - propouští jen řádky s "vzor=", aby se ani omylem
# nedostalo do logu brány nic dalšího.
#
# Nástroj má kanonický domov v METĚ (scaffold/tools/); do 7. 8. 2026 žil v repu
# tenantního kokpitu, což bránilo METĚ opřít o něj vlastní bránu bez závislosti na
# cizím repu. K tenantovi odchází vydáním, ne naopak.
# ===========================================================================
SKEN_TMP=""
sken_uklid() { [ -n "$SKEN_TMP" ] && rm -rf "$SKEN_TMP" "$SKEN_TMP.index"; }
trap sken_uklid EXIT INT TERM

if [ ! -f "$SKEN_TOOL" ]; then
  ko "(14) sken secretů - chybí $SKEN_TOOL, plochu nelze prohlédnout (fail-closed: nezjištěno se nepočítá jako PASS)"
elif ! tracked_in_git "$SKEN_TOOL"; then
  ko "(14) sken secretů - $SKEN_TOOL není verzovaný v gitu, NESPOUŠTÍM ho (brána G3)"
else
  SKEN_CIL=""
  SKEN_POPIS=""
  SKEN_PREPOCET=1

  if [ "$REZIM_HOOK" -eq 1 ]; then
    # Plocha commitu, ne disk. Materializuje se celá (je to jedno checkout-index),
    # ale skenuje se jen podmnožina, kterou commit mění - zbytek plochy je HEAD,
    # tedy obsah, který touhle branou už jednou prošel.
    SKEN_TMP="${TMPDIR:-/tmp}/sken-plocha.$$"
    SKEN_ZMENY="$(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null)"
    if [ -z "$SKEN_ZMENY" ]; then
      ok "(14) sken secretů - plocha commitu nemění žádný soubor ke skenu (jen mazání nebo prázdný commit)"
      SKEN_PREPOCET=0
    elif ! plocha_materializuj "." "$SKEN_TMP/plocha"; then
      ko "(14) sken secretů - plochu commitu se nepodařilo materializovat, obsah commitu NELZE prohlédnout (fail-closed)"
      SKEN_PREPOCET=0
    else
      mkdir -p "$SKEN_TMP/podmnozina"
      SKEN_N=0
      printf '%s\n' "$SKEN_ZMENY" | while IFS= read -r sz; do
        [ -n "$sz" ] || continue
        [ -f "$SKEN_TMP/plocha/$sz" ] || continue
        mkdir -p "$SKEN_TMP/podmnozina/$(dirname "$sz")"
        cp "$SKEN_TMP/plocha/$sz" "$SKEN_TMP/podmnozina/$sz"
      done
      SKEN_N="$(printf '%s\n' "$SKEN_ZMENY" | grep -c . | tr -d ' ')"
      SKEN_CIL="$SKEN_TMP/podmnozina"
      SKEN_POPIS="plocha commitu ($SKEN_N $([ "$SKEN_N" -eq 1 ] && echo soubor || echo souborů))"
    fi
  else
    SKEN_CIL="."
    SKEN_POPIS="disk (pracovní strom METY)"
  fi

  if [ "$SKEN_PREPOCET" -eq 1 ]; then
    SKEN_OUT="$(bash "$SKEN_TOOL" "$SKEN_CIL" --quiet 2>&1)"; SKEN_RC=$?
    # Jen řádky s "vzor=" - lokace a jméno vzoru. Nic jiného z výstupu neprochází.
    SKEN_NALEZY="$(printf '%s\n' "$SKEN_OUT" | grep 'vzor=' | sed 's/^[[:space:]]*//' || true)"
    if [ "$SKEN_RC" -eq 0 ]; then
      ok "(14) sken secretů - žádný vzor přístupového údaje bez značky, měřeno proti: $SKEN_POPIS"
    elif [ "$SKEN_RC" -eq 1 ]; then
      SKEN_POCET="$(printf '%s\n' "$SKEN_NALEZY" | grep -c . | tr -d ' ')"
      ko "(14) sken secretů - $SKEN_POCET shod vzoru přístupového údaje, měřeno proti: $SKEN_POPIS. Ověř každý řádek u zdroje: pravý údaj se rotuje a maže z historie (runbook výmazu), doložený falešný poplach se umlčí komentářem 'sken-secretu:povoleno' na témže řádku, a shodu, kterou vyrábí vzor sám, opravíš ve vzoru, ne značkou:"
      printf '%s\n' "$SKEN_NALEZY" | head -20 | detail
      [ "$SKEN_POCET" -gt 20 ] && printf '        ... a dalších %d\n' "$((SKEN_POCET - 20))"
    else
      ko "(14) sken secretů - nástroj skončil chybou použití (návratový kód $SKEN_RC), plochu NELZE prohlédnout (fail-closed):"
      printf '%s\n' "$SKEN_OUT" | head -4 | detail
    fi
  fi
fi
sken_uklid
SKEN_TMP=""

# ===========================================================================
# (15) Evidence rozhodnutí o vypuštěných sekcích ukazuje na existující texty
#
# Sekční profil (section-profiles.json) říká, co k tenantovi smí. Evidence
# (section-replacements.json) říká druhou polovinu: co po vypuštěné sekci zbylo -
# náhradní obecný text, nebo zapsané rozhodnutí, že náhrada není potřeba.
#
# CO SE MĚŘÍ TADY A CO V RENDERU (dělba je záměr, ne opomenutí): render zná vypuštěné
# sekce, takže v něm žije všechno, co se srovnává s nimi (nerozhodnutá výpustka,
# rozhodnutí ukazující na sekci, která se nevypouští, struktura záznamů). Tahle kontrola
# je ta levná statická půlka - ukazatel na náhradní text. Bez ní se rozbitý ukazatel
# pozná až při renderu, tedy typicky v nejhorší možný okamžik: těsně před nasazením
# u klienta. Proto commit time, ne deploy time.
#
# Fronta nerozhodnutých výpustek se tu ZÁMĚRNĚ nevynucuje. Dnes je jich 55 a brána,
# která spadne na všem, se do měsíce vypne. Fail-closed je v renderu a zapíná se
# stavem evidence "uplna", až fronta doběhne.
REPL_JSON="scaffold/render/section-replacements.json"
REPL_DIR="scaffold/render"
if [ ! -f "$REPL_JSON" ]; then
  wa "(15) evidence výpustek - $REPL_JSON neexistuje, ukazatele na náhradní texty nelze posoudit"
else
  R_NALEZY=""
  # ukazatele na náhradní texty: soubor musí existovat a být verzovaný (nový soubor
  # ve stejném commitu index obsahuje, takže staged add projde)
  while IFS= read -r r_snip; do
    [ -n "$r_snip" ] || continue
    if [ ! -f "$REPL_DIR/$r_snip" ]; then
      R_NALEZY="$R_NALEZY$r_snip - soubor s náhradním textem neexistuje ($REPL_DIR/$r_snip)
"
    elif ! git ls-files --error-unmatch "$REPL_DIR/$r_snip" >/dev/null 2>&1; then
      R_NALEZY="$R_NALEZY$r_snip - náhradní text není verzovaný v gitu (u tenanta by chyběl bez varování)
"
    fi
  done <<EOF
$(grep -o '"snippet"[[:space:]]*:[[:space:]]*"[^"]*"' "$REPL_JSON" | sed 's/.*"\([^"]*\)"$/\1/')
EOF
  # výčtové hodnoty (mimo blok vyctove_hodnoty, který je sám sebou dokumentací)
  while IFS= read -r r_verd; do
    [ -n "$r_verd" ] || continue
    case "$r_verd" in
      nahrazuje|bez-nahrady) : ;;
      *) R_NALEZY="$R_NALEZY verdikt \"$r_verd\" není z výčtu (nahrazuje / bez-nahrady)
" ;;
    esac
  done <<EOF
$(grep -o '"verdikt"[[:space:]]*:[[:space:]]*"[^"]*"' "$REPL_JSON" | sed 's/.*"\([^"]*\)"$/\1/')
EOF
  while IFS= read -r r_stav; do
    [ -n "$r_stav" ] || continue
    case "$r_stav" in
      castecna|uplna) : ;;
      *) R_NALEZY="$R_NALEZY stav \"$r_stav\" není z výčtu (castecna / uplna)
" ;;
    esac
  done <<EOF
$(grep -o '"stav"[[:space:]]*:[[:space:]]*"[^"]*"' "$REPL_JSON" | sed 's/.*"\([^"]*\)"$/\1/')
EOF
  # tenant config se sekčním profilem, ale bez zapojené evidence
  R_NEZAPOJENO=""
  for r_cfg in scaffold/render/tenants/*.json; do
    [ -f "$r_cfg" ] || continue
    grep -q '"renderProfile"' "$r_cfg" || continue
    grep -q '"sectionReplacements"' "$r_cfg" || R_NEZAPOJENO="$R_NEZAPOJENO$r_cfg
"
  done
  R_N="$(printf '%s' "$R_NALEZY" | grep -c '[^[:space:]]' || true)"
  # počítá se jen skalární tvar `"klíč": "hodnota"` - výčet povolených hodnot
  # (vyctove_hodnoty) je pole a není to rozhodnutí
  R_SNIP_N="$(grep -c '"snippet"[[:space:]]*:[[:space:]]*"' "$REPL_JSON" || true)"
  R_ROZH_N="$(grep -c '"verdikt"[[:space:]]*:[[:space:]]*"' "$REPL_JSON" || true)"
  if [ "$R_N" -gt 0 ]; then
    ko "(15) evidence výpustek - $R_N vadný ukazatel/hodnota v $REPL_JSON:"
    printf '%s' "$R_NALEZY" | detail
  else
    ok "(15) evidence výpustek - $R_ROZH_N rozhodnutí, $R_SNIP_N ukazatelů na náhradní text, všechny existují a jsou verzované (fronta nerozhodnutých se měří renderem, ne tady)"
  fi
  if [ -n "$R_NEZAPOJENO" ]; then
    wa "(15) evidence výpustek - tenant config má sekční profil, ale nemá klíč sectionReplacements (o vypuštěných sekcích se pak neví, jestli po nich má zůstat náhrada):"
    printf '%s' "$R_NEZAPOJENO" | detail
  fi
fi

# ===========================================================================
# (16) Dodatek k vydanému changesetu je evidovaný
#
# Changeset má dvě poloviny s jiným režimem: záznam (co se stalo) je historie a je
# neměnný jako vydaný tag, instrukce frontě (co má konzument udělat) je živá a smí se
# opravit, když ji svět přežil. Bez stopy by ale oprava instrukce byla k nerozeznání
# od tichého přepsání záznamu - a přesně to je třída zásahu, kterou OR-10 zakazuje.
#
# Kontrakt je proto obousměrný a levný: pole "**Dodatek:**" v hlavičce (signál pro toho,
# kdo čte frontu) a sekce "## Dodatky" s původním zněním doslova (stopa pro toho, kdo
# se ptá, co tam stálo dřív). Jedno bez druhého je vada, ne styl - pole bez sekce je
# tvrzení bez důkazu, sekce bez pole je změna, kterou čtenář fronty neuvidí.
#
# Co se dodatkem smí a nesmí měnit, drží README changesetů. Tahle kontrola posuzuje
# jen tvar; obsah rozhodnutí posoudit neumí a nemá to předstírat.
if [ ! -d "$CHANGESETS_DIR" ]; then
  wa "(16) dodatky changesetů - $CHANGESETS_DIR neexistuje, evidenci dodatků nelze posoudit"
else
  D_NALEZY=""
  D_POLE=0
  D_SEKCE=0
  for d_f in "$CHANGESETS_DIR"/*.md; do
    [ -f "$d_f" ] || continue
    [ "$(basename "$d_f")" = "README.md" ] && continue
    d_ma_pole=0
    d_ma_sekci=0
    grep -q '^\*\*Dodatek:\*\*[[:space:]]*[^[:space:]]' "$d_f" && d_ma_pole=1
    grep -q '^##[[:space:]]\+Dodatky[[:space:]]*$' "$d_f" && d_ma_sekci=1
    if [ "$d_ma_pole" -eq 1 ] && [ "$d_ma_sekci" -eq 0 ]; then
      D_NALEZY="$D_NALEZY$d_f - pole \"Dodatek:\" bez sekce \"## Dodatky\" (chybí původní znění)
"
    elif [ "$d_ma_pole" -eq 0 ] && [ "$d_ma_sekci" -eq 1 ]; then
      D_NALEZY="$D_NALEZY$d_f - sekce \"## Dodatky\" bez pole \"Dodatek:\" v hlavičce (čtenář fronty změnu neuvidí)
"
    fi
    [ "$d_ma_pole" -eq 1 ] && D_POLE=$((D_POLE + 1))
    [ "$d_ma_sekci" -eq 1 ] && D_SEKCE=$((D_SEKCE + 1))
  done
  D_N="$(printf '%s' "$D_NALEZY" | grep -c '[^[:space:]]' || true)"
  if [ "$D_N" -gt 0 ]; then
    ko "(16) dodatky changesetů - $D_N changeset s neúplnou evidencí dodatku:"
    printf '%s' "$D_NALEZY" | detail
  else
    ok "(16) dodatky changesetů - $D_POLE changesetů s dodatkem, u všech je pole i sekce s původním zněním"
  fi
fi

# ===========================================================================
# (17) Verify blok changesetu je vyhodnotitelný
#
# Uzavřený jazyk bloku `verify` je fail-closed: neznámé sloveso, neznámá vrstva, chybějící
# argument i vzor, který grep -E nepřeloží, končí jako NEZJISTENO. To je správně u
# konzumenta (nevím není totéž co prošlo), ale u AUTORA je to díra: takový řádek vrací
# NEZJISTENO všude a navždy, changeset se nedá přijmout, a nikdo se to nedozví, dokud ho
# někdo nepustí proti reálné jednotce. Dvakrát ve třech dnech to znamenalo opravu dodatkem
# k vydanému changesetu, tedy nejdražší možnou cestu:
#   7. 8. - nezaescapované závorky ve vzoru, regulární výraz nesplnitelný z konstrukce
#   8. 8. - sloveso `meta_grep`, které jazyk nezná
#
# Dvě části, dvě otázky:
#   (17a) TVAR - může ten řádek vůbec někdy dát PASS nebo FAIL? Fail-closed nad celým
#         adresářem: vada v kterémkoli changesetu je vada evidence, ne cizí problém.
#   (17b) SPLNITELNOST knihovních testů - hledá `lib_grep` řetězec, který v platform
#         library vůbec je? Knihovna je jedna a je to táž strana, kde změna vznikla,
#         takže FAIL tady neznamená "konzument ještě nepřevzal", ale "test je vedle".
#         Váha se liší podle toho, čí je to práce: co tenhle commit zakládá nebo mění,
#         je FAIL (oprava je levná a autor je u toho), zbytek je WARN a opravuje se
#         dodatkem k changesetu - přesně případ z 9. 8., kdy pozdější changeset
#         přejmenoval formulaci, kterou starší verify řádek hledal, a dvě jednotky
#         od té chvíle hlásily regresi, přestože knihovna byla věcně v pořádku.
#
# Jazyk se sem NEopisuje. Výčty i posouzení tvaru řádku drží scaffold/lib/changeset.sh
# (CS_VRSTVY, CS_SLOVESA, cs_row_problem) - druhý seznam by se rozešel s prvním (OR-10).
CS_LIB="scaffold/lib/changeset.sh"
V17_TMP=""
if [ ! -d "$CHANGESETS_DIR" ]; then
  wa "(17) verify bloky changesetů - $CHANGESETS_DIR neexistuje, tvar bloků nelze posoudit"
elif [ ! -f "$CS_LIB" ]; then
  ko "(17) verify bloky changesetů - chybí $CS_LIB, uzavřený jazyk nemá kde být deklarovaný (fail-closed)"
elif ! tracked_in_git "$CS_LIB"; then
  ko "(17) verify bloky changesetů - $CS_LIB není verzovaný v gitu, NESOURCUJU ho (brána G3)"
else
  # shellcheck source=lib/changeset.sh
  . "./$CS_LIB"

  # Měřená plocha stejně jako u (11) a (14): v hooku to, co se commituje, jinak disk.
  # Bez toho by brána posuzovala jiný text, než jaký do repa opravdu půjde.
  V17_ROOT="."
  V17_PLOCHA="disk (pracovní strom METY)"
  if [ "$REZIM_HOOK" -eq 1 ]; then
    V17_TMP="${TMPDIR:-/tmp}/verify-plocha.$$"
    if plocha_materializuj "." "$V17_TMP/plocha"; then
      V17_ROOT="$V17_TMP/plocha"
      V17_PLOCHA="plocha commitu"
    else
      V17_ROOT="."
      V17_PLOCHA="disk (plochu commitu se nepodařilo materializovat)"
    fi
  fi

  # Changesety, které měřená plocha zakládá nebo mění - u nich je oprava nejlevnější.
  if [ "$REZIM_HOOK" -eq 1 ]; then
    V17_MOJE="$(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null \
      | grep -E '^operations/changesets/[^/]+\.md$' || true)"
  else
    V17_MOJE="$(git status --porcelain -uall 2>/dev/null \
      | sed 's/^...//; s/^.* -> //; s/^"//; s/"$//' \
      | grep -E '^operations/changesets/[^/]+\.md$' || true)"
  fi
  v17_je_moje() { # <ID changesetu>
    case "$(printf '%s\n' "$V17_MOJE")" in *"operations/changesets/$1.md"*) return 0 ;; esac
    return 1
  }

  # Rozbor jednoho changesetu. Vlastní funkce, ne kód uvnitř $( ) - bash 3.2 na macOS
  # neumí spolehlivě rozparsovat "case" a heredoc uvnitř command substitution.
  # Tiskne po řádcích: "R" za každý řádek verify, "V<TAB>popis vady", "L<TAB>výsledek<TAB>argumenty".
  v17_rozbor() { # <soubor changesetu>
    cs_verify_lines "$1" | while IFS= read -r v17_line; do
      [ -n "$v17_line" ] || continue
      case "$v17_line" in '#'*) continue ;; esac
      printf '%s' "$v17_line" | grep -q '[^[:space:]]' || continue
      read -r v17_l v17_v v17_c v17_r <<EOF
$v17_line
EOF
      printf 'R\n'
      v17_p="$(cs_row_problem "$v17_l" "${v17_v:-}" "${v17_c:-}" "${v17_r:-}")"
      if [ -n "$v17_p" ]; then
        printf 'V\t%s\n' "$v17_p"
        continue
      fi
      case "${v17_v:-}" in
        lib_file|lib_grep)
          printf 'L\t%s\t%s %s %s\n' "$(cs_eval_row . "$v17_l" "$v17_v" "${v17_c:-}" "${v17_r:-}")" \
            "$v17_v" "${v17_c:-}" "${v17_r:-}"
          ;;
      esac
    done
  }

  V17_VADY=""; V17_LIB_MOJE=""; V17_LIB_CIZI=""; V17_NEZJ=0
  V17_CS=0; V17_RADKU=0; V17_LIB=0
  for v17_f in "$V17_ROOT/$CHANGESETS_DIR"/*.md; do
    [ -f "$v17_f" ] || continue
    v17_b="$(basename "$v17_f")"
    [ "$v17_b" = "README.md" ] && continue
    v17_id="${v17_b%.md}"
    V17_CS=$((V17_CS + 1))
    # Řádky se čtou přes parser knihovny, ne vlastním awk - jinak by brána posuzovala
    # jiný text, než jaký se opravdu vyhodnocuje.
    V17_OUT="$(v17_rozbor "$v17_f")"
    V17_RADKU=$((V17_RADKU + $(printf '%s\n' "$V17_OUT" | grep -c '^R$' || true)))
    while IFS= read -r v17_row; do
      case "$v17_row" in
        V*)
          V17_VADY="$V17_VADY$v17_id: ${v17_row#V	}
" ;;
        L*)
          v17_rest="${v17_row#L	}"
          v17_res="${v17_rest%%	*}"
          v17_arg="${v17_rest#*	}"
          V17_LIB=$((V17_LIB + 1))
          case "$v17_res" in
            PASS) : ;;
            NEZJISTENO) V17_NEZJ=$((V17_NEZJ + 1)) ;;
            *)
              if v17_je_moje "$v17_id"; then
                V17_LIB_MOJE="$V17_LIB_MOJE$v17_id: $v17_arg
"
              else
                V17_LIB_CIZI="$V17_LIB_CIZI$v17_id: $v17_arg
"
              fi
              ;;
          esac
          ;;
      esac
    done <<EOF
$V17_OUT
EOF
  done

  V17_VADY_N="$(printf '%s' "$V17_VADY" | grep -c '[^[:space:]]' || true)"
  if [ "$V17_VADY_N" -gt 0 ]; then
    ko "(17a) tvar verify bloků - $V17_VADY_N řádků nejde vyhodnotit (fail-closed: takový řádek vrací NEZJISTENO všude a navždy, changeset nejde přijmout); měřeno proti: $V17_PLOCHA:"
    printf '%s' "$V17_VADY" | detail
  else
    ok "(17a) tvar verify bloků - $V17_CS changesetů, $V17_RADKU řádků, všechny vyhodnotitelné (vrstva, sloveso, cesta i vzor); měřeno proti: $V17_PLOCHA"
  fi

  V17_MOJE_N="$(printf '%s' "$V17_LIB_MOJE" | grep -c '[^[:space:]]' || true)"
  V17_CIZI_N="$(printf '%s' "$V17_LIB_CIZI" | grep -c '[^[:space:]]' || true)"
  if [ "$V17_MOJE_N" -gt 0 ]; then
    ko "(17b) splnitelnost knihovních testů - $V17_MOJE_N řádků v changesetech, které měřená plocha zakládá nebo mění, dnes proti platform library neprochází (hledaný text v knihovně není - buď se změna ještě neudělala, nebo je vzor vedle):"
    printf '%s' "$V17_LIB_MOJE" | detail
  fi
  if [ "$V17_CIZI_N" -gt 0 ]; then
    wa "(17b) splnitelnost knihovních testů - $V17_CIZI_N řádků ve vydaných changesetech dnes neprochází (regrese v knihovně, nebo formulace, kterou pozdější změna přejmenovala; oprava je dodatek k changesetu, ne úprava knihovny):"
    printf '%s' "$V17_LIB_CIZI" | detail
  fi
  if [ "$V17_NEZJ" -gt 0 ]; then
    wa "(17b) splnitelnost knihovních testů - $V17_NEZJ řádků nelze posoudit (platform library $CLAUDE_REPO na tomhle stroji chybí nebo nejde číst); nezjištěno se nepočítá jako v pořádku"
  fi
  if [ "$V17_MOJE_N" -eq 0 ] && [ "$V17_CIZI_N" -eq 0 ] && [ "$V17_NEZJ" -eq 0 ]; then
    ok "(17b) splnitelnost knihovních testů - všech $V17_LIB řádků lib_grep/lib_file prochází proti platform library"
  fi

  [ -n "$V17_TMP" ] && rm -rf "$V17_TMP" "$V17_TMP.index"
fi

# ===========================================================================
# (18) Mapa verzí neopisuje živá čísla
#
# docs/mapa-verzi.md odpovídá na otázku "kde číslo bydlí a jak se šíří", ne "jaké to
# číslo je". Naměřená bolest: dokument vznikl 7. 8. 2026 s ručně psanými čísly a 9. 8.
# tvrdil o platformě číslo o tři vydání pozadu. Druhý domov čísla driftuje i v dokumentu,
# který před driftem čísel varuje - proto tady stojí cesta ke zdroji a příkaz.
#
# Rozlišení, které kontrola dělá, je typografické, a proto strojově čitelné:
#   - "2.13.0" bez předpony je ŽIVÝ údaj a je to nález (má se nahradit odkazem na zdroj)
#   - "v2.0.0" s předponou je HISTORICKÝ doklad nebo horizont odstranění a je v pořádku
# Adresy typu 127.0.0.1 se před posouzením odstraní - jinak by kontrola štvala hned
# první větou o portu kokpitu.
#
# Vědomě jen nad tímhle jedním souborem. Ostatní manuály v docs/ nesou (měřeno 9. 8. 2026)
# 31 výskytů čísel a všechny jsou kotvy do minulosti typu "od platformy 2.6.0"; plošné
# pravidlo by je hlásilo falešně a vnucovalo pravopisnou konvenci autorům cizích textů.
V18_SOUBORY="docs/mapa-verzi.md"
V18_NALEZY=""
V18_NEZJ=""
V18_POSUZENO=0
for v18_f in $V18_SOUBORY; do
  v18_txt=""
  if [ "$REZIM_HOOK" -eq 1 ]; then
    # v hooku se posuzuje to, co se commituje, ne rozdělaný disk (stejně jako (11)/(14)/(17))
    v18_txt="$(git show ":$v18_f" 2>/dev/null)" || v18_txt=""
  elif [ -f "$v18_f" ]; then
    v18_txt="$(cat "$v18_f" 2>/dev/null)" || v18_txt=""
  fi
  if [ -z "$v18_txt" ]; then
    V18_NEZJ="$V18_NEZJ$v18_f
"
    continue
  fi
  V18_POSUZENO=$((V18_POSUZENO + 1))
  v18_hits="$(printf '%s\n' "$v18_txt" \
    | sed -E 's/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+//g' \
    | grep -nE '(^|[^0-9A-Za-z.])[0-9]+\.[0-9]+\.[0-9]+' || true)"
  if [ -n "$v18_hits" ]; then
    V18_NALEZY="$V18_NALEZY$(printf '%s\n' "$v18_hits" | sed "s|^|$v18_f:|")
"
  fi
done

V18_N="$(printf '%s' "$V18_NALEZY" | grep -c '[^[:space:]]' || true)"
V18_NEZJ_N="$(printf '%s' "$V18_NEZJ" | grep -c '[^[:space:]]' || true)"
if [ "$V18_N" -gt 0 ]; then
  ko "(18) mapa verzí - $V18_N řádků s číslem verze psaným rukou; dnešní číslo do mapy nepatří (ukaž na cestu ke zdroji a na příkaz, kterým si ho čtenář přečte), historický doklad a horizont odstranění se píše s předponou \"v\" (v2.0.0):"
  printf '%s' "$V18_NALEZY" | detail
fi
if [ "$V18_NEZJ_N" -gt 0 ]; then
  wa "(18) mapa verzí - $V18_NEZJ_N souborů nelze přečíst, ruční čísla v nich NEposuzuji (nezjištěno se nepočítá jako v pořádku):"
  printf '%s' "$V18_NEZJ" | detail
fi
if [ "$V18_N" -eq 0 ] && [ "$V18_NEZJ_N" -eq 0 ]; then
  ok "(18) mapa verzí - $V18_POSUZENO souborů bez ručně psaného živého čísla (historické doklady s předponou \"v\" jsou v pořádku)"
fi

# --- souhrn ----------------------------------------------------------------
printf '\nSouhrn: %d PASS, %d WARN, %d FAIL\n' "$PASS_N" "$WARN_N" "$FAIL_N"
if [ "$FAIL_N" -eq 0 ]; then
  printf 'Výsledek: OK - platformní invarianty v pořádku.\n'
  exit 0
fi
printf 'Výsledek: SELHÁNÍ - viz FAIL výše. Skript nic neopravuje, náprava ručně / přes orchestrátora.\n'
exit 1
