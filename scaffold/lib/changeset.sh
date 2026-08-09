#!/usr/bin/env bash
#
# changeset.sh - parser changesetů a vyhodnocení bloku verify (osa A propagace, B-065)
#
# Sourced knihovna, nespouští se samostatně:
#   . "<META>/scaffold/lib/changeset.sh"
#
# Kanonický popis formátu: <META>/operations/changesets/README.md
# Mechanismus vlastní Humble (release engineering). Obsah changesetů vlastní autor změny.
#
# Kontrakt, na kterém stojí všechno ostatní:
#   - Blok `verify` je UZAVŘENÝ jazyk. Řetězec z changesetu se NIKDY nepředává shellu
#     k vyhodnocení - slovesa jsou case větev, ne eval. Cesty se kontrolují proti
#     absolutnímu tvaru a proti "..".
#   - Tři výsledky, ne dva: PASS / FAIL / NEZJISTENO. Nezjištěno se nikdy nepočítá
#     jako PASS (fail-closed). Neznámé sloveso, neznámá vrstva, nečitelný soubor,
#     chybějící platform library i vadný regulární výraz končí jako NEZJISTENO.
#   - Čtvrtý výsledek SKIP existuje jen pro řádky mimo profil jednotky (n/a).
#
# POSIX-friendly bash 3.2, macOS BSD grep/sed/awk. Bez GNU rozšíření, bez jq.

# --- výčty jazyka verify ----------------------------------------------------
#
# Dva řetězce, které DEKLARUJÍ uzavřený jazyk. Vyhodnocuje ho case větev v cs_eval_row
# a filtr vrstev v cs_eval_changeset; deklarace slouží branám a kontrole tvaru, aby
# nemusely mít vlastní opsaný seznam (OR-10 - jeden domov faktu). Že se deklarace
# nerozešla s implementací, hlídá scaffold/tests/verify-slovesa.sh.
#
# Nové sloveso se přidává na tři místa a všechna tři jsou povinná: sem, do case větve
# v cs_eval_row a do tabulky v operations/changesets/README.md.
CS_VRSTVY="runtime-pull rendered sablona dokumentace release-kokpitu"
CS_SLOVESA="file_exists no_file grep not_grep lib_file lib_grep manifest_ge manifest_has_agent version_ge no_test"

# --- základní pomocné funkce ----------------------------------------------

cs_trim() {
  printf '%s' "$1" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
}

# Hodnota pole hlavičky ve stylu OR-03: "**Název:** hodnota"
cs_field() { # <soubor> <název pole>
  awk -v want="$2" '
    BEGIN { pat = "^\\*\\*" want ":\\*\\*[[:space:]]*" }
    $0 ~ pat { sub(pat, "", $0); print; exit }
  ' "$1" 2>/dev/null
}

cs_id_from_file() { # <soubor>
  b="$(basename "$1")"
  printf '%s' "${b%.md}"
}

# Řádky bloku ```verify ... ```
cs_verify_lines() { # <soubor>
  awk '/^```verify[[:space:]]*$/ { f=1; next } f && /^```/ { exit } f' "$1" 2>/dev/null
}

cs_has_verify() { # <soubor>
  cs_verify_lines "$1" | grep -q '[^[:space:]]'
}

# První neprázdný odstavec sekce "## Lidská věta" (jedna věta pro člověka).
cs_human_line() { # <soubor>
  awk '
    /^##[[:space:]]+Lidská věta/ { f=1; next }
    f && /^##[[:space:]]/ { exit }
    f && /[^[:space:]]/ { print; exit }
  ' "$1" 2>/dev/null
}

# Kontrola úplnosti hlavičky. Tiskne seznam vad (prázdný výstup = changeset je platný).
cs_header_problems() { # <soubor>
  cs_f="$1"
  cs_bad=""
  if [ "$(cs_trim "$(cs_field "$cs_f" 'ID')")" != "$(cs_id_from_file "$cs_f")" ]; then
    cs_bad="$cs_bad pole-ID!=jméno-souboru"
  fi
  for cs_lbl in 'Osa' 'Vydáno' 'Autor' 'Závažnost' 'Zdroj' 'Týká se' 'Dosah' 'Akce konzumenta'; do
    if [ -z "$(cs_trim "$(cs_field "$cs_f" "$cs_lbl")")" ]; then
      cs_bad="$cs_bad chybí-$(printf '%s' "$cs_lbl" | tr ' ' '-')"
    fi
  done
  cs_has_verify "$cs_f" || cs_bad="$cs_bad chybí-verify-blok"
  cs_trim "$cs_bad"
}

cs_is_blocking() { # <soubor> - 0 když je changeset blokující
  case "$(cs_trim "$(cs_field "$1" 'Závažnost')")" in
    blokující|blokujici) return 0 ;;
  esac
  return 1
}

# --- profil jednotky a rozsah changesetu -----------------------------------
#
# Profil se detekuje ZA BĚHU a nikdy se nezapisuje do baseline - zapsaný profil
# stárne a lže. Neaplikovatelná vrstva se přeskočí (SKIP), nespadne.

# Manifest rendered artefaktů jednotky.
# Na straně NSL je to build manifest (gitignorovaný, plný diagnostiky), na stroji
# klienta jen public manifest trackovaný v tenant repu (allowlist per stanovisko
# Ariadne, `team-outcomes/025` sekce 2). Tiskne cestu k tomu, který existuje;
# neexistuje-li ani jeden, tiskne cestu k build manifestu (volající si ji otestuje).
cs_manifest_path() { # <kořen jednotky>
  cs_u="${1%/}"
  if [ -f "$cs_u/.claude/agents/render-manifest.json" ]; then
    printf '%s' "$cs_u/.claude/agents/render-manifest.json"
  elif [ -f "$cs_u/.claude/agents/render-manifest.public.json" ]; then
    printf '%s' "$cs_u/.claude/agents/render-manifest.public.json"
  else
    printf '%s' "$cs_u/.claude/agents/render-manifest.json"
  fi
}

# PRAVIDLO (oprava ve scaffold 2.1.0): signál profilu musí být vlastnost JEDNOTKY,
# ne vlastnost stroje. Do 2.0.0 se runtime-pull poznával podle existence
# $HOME/.claude/agents. Na stroji NSL platí ta podmínka vždycky, takže se vrstva
# runtime-pull přilepila i k jednotkám, které kanonické definice za běhu nečtou
# (rendered kokpit, META sama), a jejich testy pak procházely proti knihovně, kterou
# konzument nikdy neuvidí. Falešné PASS je horší než FAIL: evidence tvrdí, že jednotka
# změnu má.
#
# Rozlišení stojí na tom, ODKUD jednotka bere definice agentů:
#   rendered     = má vlastní sadu artefaktů evidovanou manifestem (build na straně NSL,
#                  public na stroji klienta). Self-contained, knihovnu nepotřebuje.
#   runtime-pull = je to Claude projekt (má CLAUDE.md) a vlastní rendered sadu nemá,
#                  takže definice, skills a foundation čte z platform library za běhu.
# Obojí zároveň nedává smysl: buď konzument artefakt drží, nebo ho čte z knihovny.
#
# Chybějící knihovna na stroji profil NEMĚNÍ - runtime-pull jednotka zůstane
# runtime-pull a její testy skončí jako NEZJISTENO. "Nelze ověřit" a "netýká se mě"
# jsou dva různé stavy a nesmí splynout.
cs_unit_profile() { # <kořen jednotky> -> podmnožina pěti vrstev, oddělená mezerou
  cs_u="${1%/}"
  cs_p=""
  if [ -f "$(cs_manifest_path "$cs_u")" ]; then
    cs_p="$cs_p rendered"
  elif [ -f "$cs_u/CLAUDE.md" ]; then
    cs_p="$cs_p runtime-pull"
  fi
  if [ -d "$cs_u/operations" ] || [ -f "$cs_u/portfolio-status.md" ]; then
    cs_p="$cs_p sablona"
  fi
  if [ -f "$cs_u/cockpit/VERSION" ] || [ -d "$cs_u/instance" ]; then
    cs_p="$cs_p release-kokpitu"
  fi
  # Vrstva dokumentace patří VÝROBCI, ne konzumentovi: dokumentace platformy se do jednotek
  # nepropaguje, mění se v METĚ. Do 6. 8. 2026 ji ale cs_unit_profile nedávala do profilu
  # nikomu, takže cs_eval_changeset vyhodnotila každý dokumentační řádek jako SKIP - vrstvu
  # nesla polovina changesetů (9 z 19) a ani jeden její test se nikdy nespustil. Deklarace
  # bez vynucení je horší než žádná: tvrdí kontrolu, kterou nikdo neprovádí.
  #
  # Signál je vlastnost JEDNOTKY (má adresář changesetů, tedy je to výrobce), ne vlastnost
  # stroje - tutéž chybu si mechanismus prošel u runtime-pull ve scaffold 2.1.0 a nesmí se
  # zopakovat. Prakticky to znamená METU: jednotka, která changesety vyrábí, si taky ověří,
  # že dokumentaci k nim opravdu upravila.
  if [ -d "$cs_u/operations/changesets" ]; then
    cs_p="$cs_p dokumentace"
  fi
  cs_trim "$cs_p"
}

# Druh jednotky pro pole "Týká se" (jednotka smí být víc druhů zároveň).
cs_unit_kinds() { # <kořen jednotky>
  cs_u="${1%/}"
  cs_k=""
  if [ -f "$cs_u/operations/status.md" ] || [ -d "$cs_u/team-outcomes" ]; then
    cs_k="$cs_k studio"
  fi
  if [ -f "$cs_u/portfolio-status.md" ] || [ -d "$cs_u/escalations" ]; then
    cs_k="$cs_k tenant-harness"
  fi
  if [ -f "$(cs_manifest_path "$cs_u")" ] || [ -d "$cs_u/cockpit" ] || [ -d "$cs_u/instance" ]; then
    cs_k="$cs_k rendered-cockpit"
  fi
  cs_trim "$cs_k"
}

# Týká se tenhle changeset dané jednotky? 0 = ano.
cs_scope_matches() { # <soubor> <slug jednotky> <druhy jednotky>
  cs_scope="$(cs_trim "$(cs_field "$1" 'Týká se')")"
  case "$cs_scope" in
    ''|vse|vše) return 0 ;;
    jen:*)
      cs_list="$(printf '%s' "${cs_scope#jen:}" | tr -d '[:space:]')"
      case ",$cs_list," in *",$2,"*) return 0 ;; esac
      return 1
      ;;
    *)
      for cs_w in $(printf '%s' "$cs_scope" | tr ',' ' '); do
        case " $3 " in *" $cs_w "*) return 0 ;; esac
      done
      return 1
      ;;
  esac
}

# --- vyhodnocení jednoho řádku verify --------------------------------------

cs_path_ok() { # cesta musí být relativní a bez ".."
  case "$1" in ''|/*|*..*) return 1 ;; esac
  return 0
}

# 0 když a >= b, 1 když a < b, 2 když některá strana není semver
cs_semver_ge() { # <a> <b>
  awk -v a="$1" -v b="$2" '
    BEGIN {
      if (a !~ /^[0-9]+(\.[0-9]+)*$/ || b !~ /^[0-9]+(\.[0-9]+)*$/) exit 2
      na = split(a, x, "."); nb = split(b, y, ".")
      n = (na > nb) ? na : nb
      for (i = 1; i <= n; i++) {
        xi = (i <= na) ? x[i] + 0 : 0
        yi = (i <= nb) ? y[i] + 0 : 0
        if (xi > yi) exit 0
        if (xi < yi) exit 1
      }
      exit 0
    }'
}

# Hodnota jednoduchého string klíče z render-manifest.json (bez jq).
cs_manifest_value() { # <manifest> <klíč>
  grep -o "\"$2\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" "$1" 2>/dev/null \
    | head -1 | sed 's/.*"\([^"]*\)"$/\1/'
}

# Vyhodnotí jedno sloveso. Tiskne PASS / FAIL / NEZJISTENO.
cs_eval_row() { # <kořen jednotky> <vrstva> <sloveso> <cesta> <vzor>
  cs_u="${1%/}"; cs_layer="$2"; cs_verb="$3"; cs_p="${4:-}"; cs_pat="${5:-}"
  cs_lib="$HOME/.claude"

  # Deklarovaný výčet rozhoduje dřív než case větve. Sloveso, které v CS_SLOVESA není,
  # se nevyhodnocuje, i kdyby pro něj větev existovala - jinak by se dalo jazyk rozšířit
  # potichu, mimo tabulku v README a mimo bránu (17) ve validate-platform.sh.
  case " $CS_SLOVESA " in
    *" $cs_verb "*) : ;;
    *) printf 'NEZJISTENO\n'; return 0 ;;
  esac

  case "$cs_verb" in
    file_exists)
      cs_path_ok "$cs_p" || { printf 'NEZJISTENO\n'; return 0; }
      if [ -f "$cs_u/$cs_p" ]; then printf 'PASS\n'; else printf 'FAIL\n'; fi
      ;;

    no_file)
      # Protějšek file_exists pro změny, které soubor z jednotky ODEBÍRAJÍ.
      # Do 2.3.0 uměl uzavřený jazyk vyjádřit jen odstranění vzoru uvnitř souboru
      # (not_grep), ne odstranění celého souboru - taková akce konzumenta pak neměla
      # test a v evidenci vypadala jako hotová, aniž ji kdo ověřil.
      # Adresář se nepočítá za splněno: cesta má být pryč, ne přeměněná na složku.
      cs_path_ok "$cs_p" || { printf 'NEZJISTENO\n'; return 0; }
      if [ -e "$cs_u/$cs_p" ]; then printf 'FAIL\n'; else printf 'PASS\n'; fi
      ;;

    grep|not_grep)
      cs_path_ok "$cs_p" || { printf 'NEZJISTENO\n'; return 0; }
      [ -n "$cs_pat" ] || { printf 'NEZJISTENO\n'; return 0; }
      if [ ! -e "$cs_u/$cs_p" ]; then
        # chybějící soubor NENÍ nečitelný soubor: u grep je to legitimní "ještě nepřevzato",
        # u not_grep je vzor prokazatelně nepřítomný
        if [ "$cs_verb" = "not_grep" ]; then printf 'PASS\n'; else printf 'FAIL\n'; fi
        return 0
      fi
      [ -r "$cs_u/$cs_p" ] || { printf 'NEZJISTENO\n'; return 0; }
      grep -Eq -- "$cs_pat" "$cs_u/$cs_p" 2>/dev/null
      case "$?" in
        0) if [ "$cs_verb" = "grep" ]; then printf 'PASS\n'; else printf 'FAIL\n'; fi ;;
        1) if [ "$cs_verb" = "grep" ]; then printf 'FAIL\n'; else printf 'PASS\n'; fi ;;
        *) printf 'NEZJISTENO\n' ;;   # vadný regulární výraz nebo chyba čtení
      esac
      ;;

    lib_file)
      [ -d "$cs_lib" ] || { printf 'NEZJISTENO\n'; return 0; }
      cs_path_ok "$cs_p" || { printf 'NEZJISTENO\n'; return 0; }
      if [ -f "$cs_lib/$cs_p" ]; then printf 'PASS\n'; else printf 'FAIL\n'; fi
      ;;

    lib_grep)
      [ -d "$cs_lib" ] || { printf 'NEZJISTENO\n'; return 0; }
      cs_path_ok "$cs_p" || { printf 'NEZJISTENO\n'; return 0; }
      [ -n "$cs_pat" ] || { printf 'NEZJISTENO\n'; return 0; }
      [ -e "$cs_lib/$cs_p" ] || { printf 'FAIL\n'; return 0; }
      [ -r "$cs_lib/$cs_p" ] || { printf 'NEZJISTENO\n'; return 0; }
      grep -Eq -- "$cs_pat" "$cs_lib/$cs_p" 2>/dev/null
      case "$?" in
        0) printf 'PASS\n' ;;
        1) printf 'FAIL\n' ;;
        *) printf 'NEZJISTENO\n' ;;
      esac
      ;;

    manifest_ge)
      cs_mf="$(cs_manifest_path "$cs_u")"
      { [ -f "$cs_mf" ] && [ -r "$cs_mf" ]; } || { printf 'NEZJISTENO\n'; return 0; }
      case "$cs_p" in
        platform_version)
          cs_val="$(cs_manifest_value "$cs_mf" platform_version)"
          [ -n "$cs_val" ] || { printf 'NEZJISTENO\n'; return 0; }
          cs_semver_ge "$cs_val" "$cs_pat"
          case "$?" in
            0) printf 'PASS\n' ;;
            1) printf 'FAIL\n' ;;
            *) printf 'NEZJISTENO\n' ;;
          esac
          ;;
        date)
          cs_val="$(cs_manifest_value "$cs_mf" date)"
          # public manifest nese datum renderu pod klíčem "rendered" (build pod "date")
          [ -n "$cs_val" ] || cs_val="$(cs_manifest_value "$cs_mf" rendered)"
          [ -n "$cs_val" ] || { printf 'NEZJISTENO\n'; return 0; }
          if awk -v a="$cs_val" -v b="$cs_pat" 'BEGIN { exit !((a "") >= (b "")) }'; then
            printf 'PASS\n'
          else
            printf 'FAIL\n'
          fi
          ;;
        *) printf 'NEZJISTENO\n' ;;   # neznámý klíč = neověřitelné, ne prošlo
      esac
      ;;

    manifest_has_agent)
      cs_mf="$(cs_manifest_path "$cs_u")"
      { [ -f "$cs_mf" ] && [ -r "$cs_mf" ]; } || { printf 'NEZJISTENO\n'; return 0; }
      [ -n "$cs_p" ] || { printf 'NEZJISTENO\n'; return 0; }
      if grep -q "\"name\"[[:space:]]*:[[:space:]]*\"$cs_p\"" "$cs_mf" 2>/dev/null; then
        printf 'PASS\n'
      else
        printf 'FAIL\n'
      fi
      ;;

    version_ge)
      cs_path_ok "$cs_p" || { printf 'NEZJISTENO\n'; return 0; }
      [ -e "$cs_u/$cs_p" ] || { printf 'FAIL\n'; return 0; }
      [ -r "$cs_u/$cs_p" ] || { printf 'NEZJISTENO\n'; return 0; }
      cs_val="$(head -1 "$cs_u/$cs_p" | tr -d '[:space:]')"
      cs_val="${cs_val#v}"
      cs_semver_ge "$cs_val" "${cs_pat#v}"
      case "$?" in
        0) printf 'PASS\n' ;;
        1) printf 'FAIL\n' ;;
        *) printf 'NEZJISTENO\n' ;;
      esac
      ;;

    no_test)
      # vědomě bez testu, povoleno jen pro vrstvu dokumentace
      if [ "$cs_layer" = "dokumentace" ]; then printf 'PASS\n'; else printf 'NEZJISTENO\n'; fi
      ;;

    *)
      printf 'NEZJISTENO\n'   # neznámé sloveso není chyba parseru ani PASS
      ;;
  esac
  return 0
}

# --- tvar řádku verify (brána u autora, ne u konzumenta) --------------------
#
# cs_eval_row odpovídá na otázku "prošlo to u téhle jednotky". Tahle funkce odpovídá na
# dřívější a jinou: "může ten řádek vůbec někdy dát PASS nebo FAIL, ať ho pustí kdokoli".
# Rozdíl není akademický - řádek s neznámým slovesem nebo s vadným regulárním výrazem
# vrací NEZJISTENO navždy a všude, takže se changeset nedá přijmout a nikdo se to nedozví,
# dokud ho někdo nepustí proti reálné jednotce. Dvakrát ve třech dnech (7. 8. nezaescapované
# závorky, 8. 8. vymyšlené sloveso `meta_grep`) to znamenalo opravu dodatkem k vydanému
# changesetu, tedy nejdražší možnou cestu.
#
# Tiskne popis vady, nebo prázdno, když je řádek vyhodnotitelný.

# 0 když je řetězec použitelný jako rozšířený regulární výraz (grep -E ho přeloží).
cs_ere_ok() { # <vzor>
  printf 'x\n' | grep -Eq -- "$1" >/dev/null 2>&1
  [ "$?" -le 1 ]
}

cs_row_problem() { # <vrstva> <sloveso> <cesta> <vzor>
  cs_rl="${1:-}"; cs_rv="${2:-}"; cs_rc="${3:-}"; cs_rr="${4:-}"

  case " $CS_VRSTVY " in
    *" $cs_rl "*) : ;;
    *) printf 'neznámá vrstva "%s" (známé: %s)' "$cs_rl" "$CS_VRSTVY"; return 0 ;;
  esac
  case " $CS_SLOVESA " in
    *" $cs_rv "*) : ;;
    *) printf 'neznámé sloveso "%s" (známá: %s)' "$cs_rv" "$CS_SLOVESA"; return 0 ;;
  esac

  case "$cs_rv" in
    file_exists|no_file|version_ge|grep|not_grep)
      [ -n "$cs_rc" ] || { printf '%s bez cesty' "$cs_rv"; return 0; }
      cs_path_ok "$cs_rc" || { printf '%s s cestou "%s" - cesta musí být relativní ke kořeni jednotky a bez ".."' "$cs_rv" "$cs_rc"; return 0; }
      ;;
    lib_file|lib_grep)
      [ -n "$cs_rc" ] || { printf '%s bez cesty' "$cs_rv"; return 0; }
      cs_path_ok "$cs_rc" || { printf '%s s cestou "%s" - cesta musí být relativní k platform library a bez ".."' "$cs_rv" "$cs_rc"; return 0; }
      ;;
  esac

  case "$cs_rv" in
    grep|not_grep|lib_grep)
      [ -n "$cs_rr" ] || { printf '%s bez vzoru' "$cs_rv"; return 0; }
      cs_ere_ok "$cs_rr" || { printf '%s se vzorem, který grep -E nepřeloží: %s (závorky a hranaté závorky v textu se escapují)' "$cs_rv" "$cs_rr"; return 0; }
      ;;
    version_ge)
      case "${cs_rr#v}" in
        ''|*[!0-9.]*) printf 'version_ge bez semver hodnoty (dostal jsem "%s")' "$cs_rr"; return 0 ;;
      esac
      ;;
    manifest_ge)
      case "$cs_rc" in
        platform_version)
          case "${cs_rr#v}" in
            ''|*[!0-9.]*) printf 'manifest_ge platform_version bez semver hodnoty (dostal jsem "%s")' "$cs_rr"; return 0 ;;
          esac
          ;;
        date)
          case "$cs_rr" in
            [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]*) : ;;
            *) printf 'manifest_ge date bez data ve tvaru YYYY-MM-DD (dostal jsem "%s")' "$cs_rr"; return 0 ;;
          esac
          ;;
        *) printf 'manifest_ge se známým klíčem platform_version nebo date, ne "%s"' "$cs_rc"; return 0 ;;
      esac
      ;;
    manifest_has_agent)
      [ -n "$cs_rc" ] || { printf 'manifest_has_agent bez jména agenta'; return 0; }
      ;;
    no_test)
      # Vědomé "bez testu" patří výrobci. Na kterékoli jiné vrstvě je to řádek, který
      # u konzumenta skončí navždy jako NEZJISTENO - tedy deklarace bez vynucení.
      [ "$cs_rl" = "dokumentace" ] || { printf 'no_test je povolené jen na vrstvě dokumentace, ne na "%s"' "$cs_rl"; return 0; }
      ;;
  esac
  return 0
}

# Vyhodnotí celý blok verify jednoho changesetu proti jednotce.
# Tiskne jeden řádek na test: "<VÝSLEDEK>\t<vrstva>\t<sloveso>\t<argumenty>".
# Řádky mimo profil jednotky dostanou SKIP, neznámá vrstva NEZJISTENO (fail-closed).
cs_eval_changeset() { # <kořen jednotky> <soubor changesetu> <profil jednotky>
  cs_unit="$1"; cs_file="$2"; cs_prof="$3"
  cs_verify_lines "$cs_file" | while IFS= read -r cs_line; do
    case "$cs_line" in
      ''|'#'*) continue ;;
    esac
    printf '%s' "$cs_line" | grep -q '[^[:space:]]' || continue
    read -r cs_l cs_v cs_c cs_r <<EOF
$cs_line
EOF
    cs_c="${cs_c:-}"; cs_r="${cs_r:-}"
    case " $CS_VRSTVY " in
      *" $cs_l "*) ;;
      *) printf 'NEZJISTENO\t%s\t%s\t%s %s\n' "$cs_l" "${cs_v:-?}" "$cs_c" "$cs_r"; continue ;;
    esac
    case " $cs_prof " in
      *" $cs_l "*) ;;
      *) printf 'SKIP\t%s\t%s\t%s %s\n' "$cs_l" "${cs_v:-?}" "$cs_c" "$cs_r"; continue ;;
    esac
    cs_res="$(cs_eval_row "$cs_unit" "$cs_l" "$cs_v" "$cs_c" "$cs_r")"
    printf '%s\t%s\t%s\t%s %s\n' "$cs_res" "$cs_l" "$cs_v" "$cs_c" "$cs_r"
  done
}

# --- baseline jednotky ------------------------------------------------------

cs_baseline_file() { # <kořen jednotky>
  printf '%s' "${1%/}/operations/platform-baseline.md"
}

# ID evidovaná jako převzatá (první sloupec tabulky, tvar YYYY-MM-DD-...)
cs_baseline_ids() { # <kořen jednotky>
  cs_bf="$(cs_baseline_file "$1")"
  [ -f "$cs_bf" ] || return 0
  awk -F'|' '
    /^[[:space:]]*\|/ {
      v = $2
      gsub(/^[[:space:]]+/, "", v); gsub(/[[:space:]]+$/, "", v)
      if (v ~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-/) print v
    }' "$cs_bf"
}

cs_baseline_field() { # <kořen jednotky> <název pole>
  cs_bf="$(cs_baseline_file "$1")"
  [ -f "$cs_bf" ] || return 0
  cs_trim "$(cs_field "$cs_bf" "$2")"
}
