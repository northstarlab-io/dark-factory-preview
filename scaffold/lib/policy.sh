#!/usr/bin/env bash
#
# policy.sh - čtení tenantní policy (scaffold/render/tenants/<tenant>.json)
#
# Sourced knihovna, nespouští se samostatně:
#   . "<META>/scaffold/lib/policy.sh"
#
# Proč vlastní soubor: policy čtou dva nástroje - zaloz-jednotku.sh (nastavení nové
# jednotky) a obnov-nastaveni.sh (obnova nastavení existující). Dvě kopie téhož parseru
# se rozejdou a je to parser, na kterém stojí oprávnění session u klienta. Jeden fakt,
# jeden domov (OR-10).
#
# POSIX-friendly bash 3.2, macOS BSD nástroje. Bez jq a bez Node - scaffold musí běžet
# i tam, kde ani jedno není.

# Policy načtená do jednoho řádku. Všechny ostatní funkce berou tenhle text, ne cestu -
# soubor se čte jednou.
pol_text() { # <cesta k policy>
  tr '\n' ' ' < "$1"
}

# Položky pole <klíč> po řádcích. Bere PRVNÍ výskyt klíče v textu.
pol_seznam() { # <text policy> <klíč>
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
        c = part[p]
        gsub(/[[:space:]]/, "", c); gsub(/"/, "", c)
        if (c != "") print c
      }
    }'
}

# Blok "grant" ohraničený párováním složených závorek.
#
# Ohraničení je bezpečnostní vlastnost, ne úhlednost: nezúžený blok by u agenta, který
# grant nemá, sáhl po prvním poli, které se v konfiguraci za jeho jménem vyskytne
# (typicky agents[]), a tiše povolil něco, co policy nepovolila.
pol_grant_blok() { # <text policy>
  printf '%s' "$1" | awk '
    {
      i = index($0, "\"grant\"")
      if (i == 0) exit
      s = substr($0, i)
      j = index(s, "{")
      if (j == 0) exit
      s = substr(s, j)
      depth = 0
      out = ""
      for (k = 1; k <= length(s); k++) {
        c = substr(s, k, 1)
        out = out c
        if (c == "{") depth++
        else if (c == "}") { depth--; if (depth == 0) break }
      }
      print out
    }'
}

# Granty jednoho profilu (prázdno = profil grant nemá).
pol_grant() { # <text policy> <profil>
  pol_seznam "$(pol_grant_blok "$1")" "$2"
}

# Existuje profil v bloku grant? 0 = ano. Rozlišuje "profil nemá granty" od "profil
# v policy vůbec není" - druhé je překlep a nesmí projít jako prázdný allowlist.
pol_ma_profil() { # <text policy> <profil>
  printf '%s' "$(pol_grant_blok "$1")" | grep -q "\"$2\"[[:space:]]*:"
}

# Jména profilů v bloku grant, po řádcích.
pol_profily() { # <text policy>
  printf '%s' "$(pol_grant_blok "$1")" | sed 's/"\([a-z0-9-]*\)"[[:space:]]*:[[:space:]]*\[/\
@@\1@@/g' | sed -n 's/^@@\(.*\)@@.*/\1/p'
}

# Tenant-wide deny (sjednocení toho, co nedostane žádná jednotka).
pol_deny() { # <text policy>
  pol_seznam "$1" deny
}

# Tenant-wide deny pro settings.json JEDNOTKY: jako pol_deny, ale bez jmen MCP serverů,
# které tenant nezná z žádného grantu.
#
# Proč: deny má dva konzumenty s různou rolí. Pro render je evidence odebrání z kanonických
# definic - a kanonické definice nesou i jména interních konektorů NSL vrstvy. Ta do
# klientského repa nepatří (identifikátor cizího konektoru = únik, incident 6. 8. 2026)
# a u klienta jsou mrtvou konfigurací, protože server tam neexistuje (strict-mcp-config).
# Kritérium: MCP server, který nemá v policy jediný grant, je server, který tenant nezná.
# Vestavěná jména procházejí vždy. Směr selhání u hypotetického serveru bez grantu, ale
# s výskytem u jednotky: nástroj se místo bloku dotáže člověka v session, což je režim,
# který tenantní policy pro nerozhodnutá jména záměrně používá (G3, 9. 8. 2026).
# Pozn.: jméno serveru se čte vzorem bez podtržítek (pol_mcp_servery) - oba tenantní
# servery to splňují; server s podtržítkem ve jméně by se nepoznal a jeho zákaz by se
# nepropsal. I to selže směrem dotazu, ne tichého povolení bez ptaní.
pol_deny_jednotky() { # <text policy>
  _pdj_servery="$(pol_grant_blok "$1" | tr ',' '\n' | tr -d '"[]{} ' | pol_mcp_servery)"
  pol_deny "$1" | while IFS= read -r _pdj_j; do
    case "$_pdj_j" in
      mcp__*)
        _pdj_ok=0
        # čte se po řádcích, ne word-splittingem - chování nezávisí na shellu volajícího
        while IFS= read -r _pdj_s; do
          [ -n "$_pdj_s" ] || continue
          case "$_pdj_j" in "mcp__${_pdj_s}__"*) _pdj_ok=1; break ;; esac
        done <<PDJEOF
$_pdj_servery
PDJEOF
        [ "$_pdj_ok" -eq 1 ] && printf '%s\n' "$_pdj_j"
        ;;
      *) printf '%s\n' "$_pdj_j" ;;
    esac
  done
  return 0
}

# Doplněk deny per profil jednotky (blok unitDeny). Prázdno, když se nepoužívá.
#
# Proč vedle tenant-wide deny: tenant-wide deny je SJEDNOCENÍ zákazů a je proto disjunktní
# se všemi granty - jinak by nastavení jednotky mělo v deny to, co má ve vlastním allow.
# Zákaz platný jen pro jednu jednotku (typicky delegace nebo cizí konektor u automatu,
# který běží bez člověka v session) se tím vyjádřit nedá. Do doplnění tohohle klíče žil
# takový zákaz jen ručně dopsaný v settings.json instance, kde ho žádný nástroj neviděl
# a obnova nastavení by ho smazala (nález Ariadne, inventura 7. 8. 2026).
pol_unit_deny_blok() { # <text policy>
  printf '%s' "$1" | awk '
    {
      i = index($0, "\"unitDeny\"")
      if (i == 0) exit
      s = substr($0, i)
      j = index(s, "{")
      if (j == 0) exit
      s = substr(s, j)
      depth = 0
      out = ""
      for (k = 1; k <= length(s); k++) {
        c = substr(s, k, 1)
        out = out c
        if (c == "{") depth++
        else if (c == "}") { depth--; if (depth == 0) break }
      }
      print out
    }'
}

pol_unit_deny() { # <text policy> <profil>
  pol_seznam "$(pol_unit_deny_blok "$1")" "$2"
}

# Model pro jednotky (unitSettings.model).
pol_model() { # <text policy>
  printf '%s' "$1" | sed -n 's/.*"unitSettings"[^}]*"model"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'
}

# Položky po řádcích -> "a", "b" (tvar pro JSON pole).
pol_quote_join() { # stdin
  awk 'NF { gsub(/\\/, ""); gsub(/"/, ""); items = items (items == "" ? "" : ", ") "\"" $0 "\"" } END { printf "%s", items }'
}

# Jména MCP serverů odvozená ze sady nástrojů (mcp__<server>__<nástroj>).
pol_mcp_servery() { # stdin: nástroje po řádcích
  sed -n 's/^mcp__\([^_]*\)__.*/\1/p' | sort -u
}
