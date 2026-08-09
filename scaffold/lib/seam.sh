#!/usr/bin/env bash
#
# seam.sh - čtení a vyhodnocení engine/state seamu (scaffold/manifest.json)
#
# Sourced knihovna, nespouští se samostatně:
#   . "<META>/scaffold/lib/seam.sh"
#
# Kanonický popis seamu: scaffold/manifest.json (komentáře v souboru) a
# docs/TECHNIKA.md sekce "Engine/state seam princip".
# Mechanismus vlastní Humble (release engineering). Obsah šablon vlastní jejich autoři.
#
# Kontrakt, na kterém stojí všechno ostatní:
#   - CESTA V ŠABLONĚ = CESTA V JEDNOTCE. Manifest klasifikuje cesty JEDNOTKY;
#     zdroj kopie je táž relativní cesta v odpovídající šabloně (engine -> studio-template,
#     engine_tenant -> tenant-template). Žádná mapovací tabulka zdroj->cíl neexistuje
#     a vědomě existovat nemá: manifest je klasifikace (co smí upgrade přepsat),
#     ne kopírovací skript. Kdo potřebuje jiný cíl než zdroj, přesune soubor v šabloně.
#   - Engine položka je KONKRÉTNÍ SOUBOR, ne glob ani adresář. Upgrade přepisuje
#     jmenované soubory; glob v engine seznamu by znamenal "přepiš, co najdeš".
#   - State položka je vzor: přesná cesta, adresářový prefix (končí "/") nebo glob ("*").
#     Konkrétní engine soubor uvnitř state adresáře má přednost (team-inbox/README.md).
#   - Fail-closed: soubor v šabloně, který není ani engine, ani state, je nález.
#     Nezařazená cesta se při upgradu nedotýká a flagne se - to je bezpečné, ale
#     jen dokud o ní někdo ví. Tichá nezařazená cesta je díra v seamu.
#
# POSIX-friendly bash 3.2, macOS BSD grep/sed/awk. Bez GNU rozšíření, bez jq.

# --- čtení manifestu --------------------------------------------------------

# Položky JSON pole daného klíče, jedna na řádek.
# JSON se nejdřív slije do jednoho řádku, takže výsledek nezávisí na formátování
# (pretty-printed i kompaktní manifest čte stejně). Uvozovky v klíči jsou součástí
# vzoru, takže "engine" se nikdy netrefí do "engine_tenant".
seam_paths() { # <manifest> <klíč pole>
  [ -f "$1" ] || return 0
  tr '\n' ' ' < "$1" | awk -v key="$2" '
    {
      pat = "\"" key "\"[ \t]*:[ \t]*\\["
      if (!match($0, pat)) exit 0
      rest = substr($0, RSTART + RLENGTH)
      end = index(rest, "]")
      if (end > 0) rest = substr(rest, 1, end - 1)
      while (match(rest, /"[^"]*"/)) {
        item = substr(rest, RSTART + 1, RLENGTH - 2)
        if (item != "") print item
        rest = substr(rest, RSTART + RLENGTH)
      }
    }'
}

# --- vyhodnocení ------------------------------------------------------------
#
# POZOR na dvě pasti při iteraci seznamu (obojí chycené testem, ne úvahou):
#   1. Nekvotovaný "$seznam" v `for` se rozpadá podle IFS - proto IFS=newline.
#   2. Nekvotovaný "$seznam" v `for` prochází i EXPANZÍ CEST. Položka team-inbox/*
#      se ve spuštění z kořene METY (kde team-inbox/ existuje) rozpadla na skutečné
#      soubory a vzor tím zmizel. Proto se kolem každé iterace vypíná globbing
#      (set -f) a původní stav se vrací zpátky - vnořené volání ho nesmí shodit.

# Vypne expanzi cest a zapamatuje si předchozí stav do seam_glob_was.
seam_noglob_on() {
  case "$-" in *f*) seam_glob_was=off ;; *) seam_glob_was=on ;; esac
  set -f
}

# Vrátí expanzi cest do stavu před seam_noglob_on.
seam_noglob_off() {
  [ "${seam_glob_was:-on}" = "off" ] || set +f
}

# 0 když cesta odpovídá některé položce seznamu (přesná shoda / adresářový prefix / glob).
seam_path_matches() { # <cesta> <seznam po řádcích>
  seam_p="$1"
  seam_ifs_old="$IFS"
  seam_hit=1
  seam_noglob_on
  seam_glob_pm="$seam_glob_was"
  IFS='
'
  for seam_e in $2; do
    [ -n "$seam_e" ] || continue
    case "$seam_e" in
      */)
        case "$seam_p" in "$seam_e"*) seam_hit=0 ;; esac
        ;;
      *\**)
        # shellcheck disable=SC2254
        case "$seam_p" in $seam_e) seam_hit=0 ;; esac
        ;;
      *)
        [ "$seam_p" = "$seam_e" ] && seam_hit=0
        ;;
    esac
    [ "$seam_hit" -eq 0 ] && break
  done
  IFS="$seam_ifs_old"
  seam_glob_was="$seam_glob_pm"
  seam_noglob_off
  return "$seam_hit"
}

# Engine položky, které nejsou konkrétním souborem (glob nebo adresář).
# Tiskne vadné položky, jednu na řádek.
seam_engine_shape_problems() { # <engine seznam po řádcích>
  seam_ifs_old="$IFS"
  seam_noglob_on
  seam_glob_sp="$seam_glob_was"
  IFS='
'
  for seam_e in $1; do
    [ -n "$seam_e" ] || continue
    case "$seam_e" in
      */|*\**) printf '%s\n' "$seam_e" ;;
    esac
  done
  IFS="$seam_ifs_old"
  seam_glob_was="$seam_glob_sp"
  seam_noglob_off
}

# Engine cesty deklarované v manifestu, které v šabloně neexistují (mrtvá deklarace).
seam_dead_paths() { # <šablona> <engine seznam po řádcích>
  seam_tpl="${1%/}"
  seam_ifs_old="$IFS"
  seam_noglob_on
  seam_glob_dp="$seam_glob_was"
  IFS='
'
  for seam_e in $2; do
    [ -n "$seam_e" ] || continue
    [ -e "$seam_tpl/$seam_e" ] || printf '%s\n' "$seam_e"
  done
  IFS="$seam_ifs_old"
  seam_glob_was="$seam_glob_dp"
  seam_noglob_off
}

# Soubory v šabloně, které nejsou ani engine, ani state (nezařazené cesty).
# .DS_Store se vědomě ignoruje: generuje ho Finder, není to rozhodnutí o seamu
# a bránu by shodil na věci, kterou nikdo nezapsal.
seam_unclassified() { # <šablona> <engine seznam> <state seznam>
  seam_tpl="${1%/}"
  [ -d "$seam_tpl" ] || return 0
  find "$seam_tpl" -type f 2>/dev/null | sed "s|^${seam_tpl}/||" | sort | while IFS= read -r seam_f; do
    [ -n "$seam_f" ] || continue
    case "$seam_f" in .DS_Store|*/.DS_Store) continue ;; esac
    seam_path_matches "$seam_f" "$2" && continue
    seam_path_matches "$seam_f" "$3" && continue
    printf '%s\n' "$seam_f"
  done
}
