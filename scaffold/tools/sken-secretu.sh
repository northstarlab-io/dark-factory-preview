#!/bin/bash
#
# sken-secretu.sh - mechanická brzda k OR-02: hledá v obsahu vzory přístupových
# údajů dřív, než odejde ven.
#
# KANONICKÝ DOMOV: scaffold/tools/ v METĚ. Nástroj má platformní působnost (běhá nad
# všemi projekty portfolia), takže patří k platformě a k tenantovi odchází vydáním.
# Do 7. 8. 2026 žil v repozitáři kokpitu, tedy v tenantním artefaktu - obrácený tok,
# který bránil platformě sáhnout na skript ve vlastní bráně, aniž by závisela na cizím
# repu.
#
# Dva důvody, proč existuje:
#   1. Kontrakt K10 - balík odchází k tenantovi a nesmí v něm být žádný token.
#      Volá se z release.sh nad payloadem před vydáním.
#   2. Podmínka D7 (rozhodnutí Stanislava 4. 8. 2026) - obsah jednotek tenanta
#      je od teď verzovaný v gitu včetně team-inbox/ a team-outcomes/, takže
#      push do klientova orgu potřebuje bránu. Historie se maže přepisem, ne
#      commitem "oprava".
#
# Sken NENAHRAZUJE review. Chytá tvarové vzory a přiřazení s hodnotou, ne
# lidský úsudek. Falešně negativní výsledek je možný; proto brzda, ne důkaz.
#
# ZÁSADA CONTAINMENTU (OR-02): skript hlásí lokaci a jméno vzoru, NIKDY nalezenou
# hodnotu. Opsat hodnotu do výpisu, logu nebo do reportu znamená zreplikovat
# secret do dalšího plaintext kanálu - detekce bez containmentu je pořád únik.
#
# Použití:
#   sken-secretu.sh <cesta>                 sken celého stromu (soubory, ne binárky)
#   sken-secretu.sh <cesta> --od <ref>      sken jen souborů změněných od git ref
#   sken-secretu.sh <cesta> --quiet         bez výpisu při čistém výsledku
#
# Výjimka na řádku: komentář `sken-secretu:povoleno` na témže řádku. Používá se
# na doložené případy typu ukázkový tvar v dokumentaci; je vidět v diffu a dá se
# na ni ptát.
#
# Návratové kódy:
#   0  čisto
#   1  nález (aspoň jeden)
#   2  chyba použití

set -euo pipefail

CESTA=""
OD=""
QUIET=0

napoveda() {
  # celý úvodní komentářový blok, ať se nápověda neusekne po doplnění odstavce
  # (stejný tvar jako validate-platform.sh - pevný rozsah řádků se rozejde s obsahem)
  awk 'NR>1 && /^#/ { sub(/^# ?/, ""); print; next } NR>1 { exit }' "$0"
}

while [ $# -gt 0 ]; do
  case "$1" in
    --od)      OD="${2:-}"; shift 2 ;;
    --quiet)   QUIET=1; shift ;;
    -h|--help) napoveda; exit 0 ;;
    -*)        echo "[CHYBA] neznámý argument: $1 (--help)" >&2; exit 2 ;;
    *)         if [ -n "$CESTA" ]; then echo "[CHYBA] čekám jen jednu cestu" >&2; exit 2; fi
               CESTA="$1"; shift ;;
  esac
done

[ -n "$CESTA" ] || { echo "[CHYBA] chybí cesta ke skenu (--help)" >&2; exit 2; }
[ -e "$CESTA" ] || { echo "[CHYBA] cesta neexistuje: $CESTA" >&2; exit 2; }
CESTA="$(cd "$(dirname "$CESTA")" && pwd)/$(basename "$CESTA")"

# --- vzory --------------------------------------------------------------------
# Dvě třídy. Tvarové vzory jsou samy o sobě důkazem tvaru přístupového údaje.
# Slovní vzory z K10 (token, secret, api_key, heslo) hlásíme JEN ve tvaru
# přiřazení s hodnotou - jinak by brána šuměla na každé větě "žádný token na
# stroji uživatele" a šumící brána se do měsíce vypne.
VZORY_JMENA=(
  "soukromy-klic"
  "github-token"
  "slack-token"
  "aws-klic"
  "google-klic"
  "sk-klic"
  "bearer"
  "url-s-heslem"
  "prirazeni-hodnoty"
)
VZORY_REGEX=(
  '-----BEGIN [A-Z ]*PRIVATE KEY-----'
  'gh[pousr]_[A-Za-z0-9]{20,}'
  'xox[abprs]-[A-Za-z0-9-]{10,}'
  '(A3T[A-Z0-9]|AKIA|ASIA|ABIA|ACCA)[A-Z0-9]{16}'
  'AIza[0-9A-Za-z_-]{35}'
  # Hranice slova před "sk-" je povinná, jinak vzor chytá každé slovo končící na "sk"
  # (task-, risk-, opendesk-) následované pomlčkou. Naměřeno 7. 8. 2026: osm shod nad
  # team-outcomes/ portfolia, všech osm tohoto druhu, nula pravých nálezů.
  # Zápis přes "(^|[^A-Za-z0-9_-])", ne přes lookbehind: grep -E je POSIX ERE a
  # "(?<!...)" v něm neexistuje - na macOS by vzor tiše nematchoval nic.
  '(^|[^A-Za-z0-9_-])sk-(ant-)?[A-Za-z0-9_-]{20,}'
  '[Bb]earer [A-Za-z0-9._~+/-]{16,}'
  '[a-z][a-z0-9+.-]*://[^/[:space:]:@]+:[^/[:space:]@]{6,}@'
  '(api[_-]?key|apikey|secret|token|password|passwd|heslo)["'"'"' ]*[:=][ ]*["'"'"']?[A-Za-z0-9_./+=-]{12,}'
)

# Co se neskenuje: git interní data, závislosti, stažený runtime, OS smetí.
VYNECHAT_RE='(^|/)\.git/|(^|/)node_modules/|(^|/)runtime/|(^|/)\.DS_Store$|(^|/)\._'

# --- seznam souborů -----------------------------------------------------------
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

if [ -n "$OD" ]; then
  REPO="$CESTA"; [ -d "$REPO" ] || REPO="$(dirname "$CESTA")"
  git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1 \
    || { echo "[CHYBA] --od potřebuje git repo, '$CESTA' jím není" >&2; exit 2; }
  git -C "$REPO" rev-parse --verify --quiet "$OD" >/dev/null \
    || { echo "[CHYBA] neznámý git ref: $OD" >&2; exit 2; }
  # Porovnáváme pracovní strom proti ref, ne HEAD proti ref - rozpracovaná změna
  # je přesně ta, u které secret nejčastěji vznikne.
  git -C "$REPO" diff --name-only "$OD" -- . \
    | while IFS= read -r r; do [ -f "$REPO/$r" ] && printf '%s/%s\n' "$REPO" "$r"; done \
    > "$TMP/soubory.txt" || true
  # Neevidované soubory se do diffu nedostanou a jsou to typicky lokální poznámky.
  git -C "$REPO" ls-files --others --exclude-standard -- . \
    | while IFS= read -r r; do [ -f "$REPO/$r" ] && printf '%s/%s\n' "$REPO" "$r"; done \
    >> "$TMP/soubory.txt" || true
elif [ -d "$CESTA" ]; then
  find "$CESTA" -type f > "$TMP/vse.txt"
  { grep -Ev "$VYNECHAT_RE" "$TMP/vse.txt" || true; } > "$TMP/soubory.txt"
else
  printf '%s\n' "$CESTA" > "$TMP/soubory.txt"
fi

# --- sken ---------------------------------------------------------------------
NALEZU=0
SOUBORU=0
: > "$TMP/nalezy.txt"

# Předfiltr: sjednocení všech vzorů do jedné alternace. Soubor, který netrefí ani ji,
# nemůže trefit žádný vzor jednotlivě, takže se devět průchodů přeskočí naráz.
# Semantika se nemění (alternace matchne právě to, co aspoň jeden vzor), mění se cena:
# bez něj je to 9 x počet souborů volání grepu, s ním 1 x počet souborů plus hrstka.
# Důvod, proč na tom záleží: bez předfiltru trvá sken METY 8 sekund a kontrola (14)
# ve validátoru by zdvojnásobila jeho běh - a brána, kterou lidi obcházejí kvůli čekání,
# je stejně mrtvá jako brána, kterou obcházejí kvůli šumu.
PREDFILTR=""
for r in "${VZORY_REGEX[@]}"; do
  [ -n "$PREDFILTR" ] && PREDFILTR="$PREDFILTR|"
  PREDFILTR="$PREDFILTR($r)"
done

while IFS= read -r f; do
  [ -n "$f" ] || continue
  [ -f "$f" ] || continue
  case "$f" in *"/.git/"*|*/node_modules/*|*/runtime/*) continue ;; esac
  grep -Iq . "$f" 2>/dev/null || continue   # binárku přeskoč
  SOUBORU=$((SOUBORU + 1))
  rel="${f#"$CESTA"/}"

  # Soubor .env s hodnotami (ne .env.example a spol.)
  case "$(basename "$f")" in
    .env|.env.local|.env.production)
      printf '%s\t%s\t%s\n' "$rel" "-" "soubor-env" >> "$TMP/nalezy.txt"
      NALEZU=$((NALEZU + 1)) ;;
  esac

  grep -qE "$PREDFILTR" "$f" 2>/dev/null || continue

  i=0
  while [ $i -lt ${#VZORY_REGEX[@]} ]; do
    while IFS=: read -r cislo zbytek; do
      [ -n "$cislo" ] || continue
      case "$zbytek" in *"sken-secretu:povoleno"*) continue ;; esac
      printf '%s\t%s\t%s\n' "$rel" "$cislo" "${VZORY_JMENA[$i]}" >> "$TMP/nalezy.txt"
      NALEZU=$((NALEZU + 1))
    done < <(grep -nE "${VZORY_REGEX[$i]}" "$f" 2>/dev/null || true)
    i=$((i + 1))
  done
done < "$TMP/soubory.txt"

# --- výstup -------------------------------------------------------------------
if [ "$NALEZU" -eq 0 ]; then
  if [ "$QUIET" -eq 0 ]; then
    echo "[ČISTO] $SOUBORU souborů, žádný vzor přístupového údaje."
    if [ -n "$OD" ]; then echo "        rozsah: změny od $OD"; else echo "        rozsah: $CESTA"; fi
  fi
  exit 0
fi

echo "[NÁLEZ] shod: $NALEZU, prohledaných souborů: $SOUBORU" >&2
echo "        Vypisuji lokaci a jméno vzoru, nikdy hodnotu (OR-02 containment)." >&2
echo "" >&2
while IFS="$(printf '\t')" read -r cesta cislo vzor; do
  if [ "$cislo" = "-" ]; then
    printf '  %s  vzor=%s\n' "$cesta" "$vzor" >&2
  else
    printf '  %s:%s  vzor=%s\n' "$cesta" "$cislo" "$vzor" >&2
  fi
done < "$TMP/nalezy.txt"
echo "" >&2
echo "Co s tím: ověř každý řádek u zdroje. Je-li to opravdu přístupový údaj," >&2
echo "nestačí ho smazat commitem - musí ven i z historie (runbook výmazu), a" >&2
echo "hodnota se považuje za kompromitovanou a rotuje se. Doložený falešný" >&2
echo "poplach se umlčí komentářem 'sken-secretu:povoleno' na tomtéž řádku." >&2
exit 1
