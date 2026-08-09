#!/usr/bin/env bash
#
# strojovy-radek.sh - kontrakt strojově čitelného řádku režimu `validate.sh --baseline`
#
#   bash scaffold/tests/strojovy-radek.sh
#
# Proč vlastní test: čtecí vrstva portfolia i orchestrátoři jednotek stojí
# na tom, že PRVNÍ řádek výstupu je "BASELINE klíč=hodnota ...". Do 9. 8. 2026 to byla
# vlastnost implementace, ne deklarovaný kontrakt - stačilo doplnit jeden printf před
# ten řádek a čtečky by tiše přestaly číst fronty. Kontrakt teď stojí v hlavičce
# validate.sh a v operations/changesets/README.md; tenhle test ho drží průchodem.
#
# Nic v repu nemění, fixtury vznikají v dočasném adresáři.
# POSIX-friendly bash 3.2, macOS BSD nástroje.

set -u

SELF_DIR="$(cd "$(dirname "$0")" && pwd)"
META="${SELF_DIR%/scaffold/tests}"
VAL="$META/scaffold/validate.sh"

ROOT="$(mktemp -d "${TMPDIR:-/tmp}/nsl-strojovy-radek.XXXXXX")"
trap 'rm -rf "$ROOT"' EXIT INT TERM

FAILN=0
check() { # <popis> <očekáváno> <skutečnost>
  if [ "$2" = "$3" ]; then
    printf 'PASS  %s\n' "$1"
  else
    printf 'FAIL  %s\n        čekáno: [%s]\n        reálně: [%s]\n' "$1" "$2" "$3"
    FAILN=$((FAILN + 1))
  fi
}

# Jednotka bez baseline: legitimní stav, fronta se počítá od nuly.
U="$ROOT/jednotka-fixtura"
mkdir -p "$U/operations"
printf '# Fixture jednotky pro test strojového řádku\n' > "$U/CLAUDE.md"

POLE="jednotka stav lag regrese nezjisteno blokujici vadne platforma platforma_meta profil"

# --- S1: --line vytiskne právě jeden řádek a je to ten strojový -------------
OUT_LINE="$(bash "$VAL" --baseline "$U" --line 2>/dev/null)"
check "S1 --line tiskne právě jeden řádek" "1" "$(printf '%s\n' "$OUT_LINE" | grep -c .)"
check "S1 řádek začíná klíčovým slovem BASELINE" "1" "$(printf '%s\n' "$OUT_LINE" | grep -c '^BASELINE ')"
CHYBI=""
for p in $POLE; do
  printf '%s\n' "$OUT_LINE" | grep -q "[ ]$p=" || CHYBI="$CHYBI $p"
done
check "S1 řádek nese všechna kontraktní pole" "" "$CHYBI"

# --- S2: v plném reportu je strojový řádek PRVNÍ -----------------------------
PRVNI="$(bash "$VAL" --baseline "$U" 2>/dev/null | head -1)"
check "S2 první řádek plného reportu je strojový" "1" "$(printf '%s\n' "$PRVNI" | grep -c '^BASELINE ')"

# --- S3: platí i na chybové cestě (--accept na neexistující ID) --------------
# Chybová hláška patří na stderr, strojový řádek zůstává první na stdout.
PRVNI_ERR="$(bash "$VAL" --baseline "$U" --accept "0000-00-00-neexistujici-changeset" --kdo test 2>/dev/null | head -1)"
check "S3 strojový řádek i při chybě použití" "1" "$(printf '%s\n' "$PRVNI_ERR" | grep -c '^BASELINE ')"
STDERR_ERR="$(bash "$VAL" --baseline "$U" --accept "0000-00-00-neexistujici-changeset" --kdo test 2>&1 >/dev/null | grep -c 'neexistuje')"
check "S3 vysvětlení chyby jde na stderr, ne na stdout" "1" "$STDERR_ERR"

# --- S4: platí i tehdy, když se META s changesety nenajde --------------------
# NSL_META_ROOT mimo disk plus spuštění kopie validátoru mimo strom METY: nástroj musí
# vrátit nezjisteno strojovým řádkem, ne prázdný výstup a hlášku.
KOPIE="$ROOT/mimo-metu"
mkdir -p "$KOPIE"
cp "$VAL" "$KOPIE/validate.sh"
OUT_NOMETA="$(cd "$KOPIE" && HOME="$ROOT/prazdny-domov" NSL_META_ROOT="$ROOT/neexistuje" \
  bash ./validate.sh --baseline "$U" --line 2>/dev/null)"
RC_NOMETA=$?
check "S4 bez METY je první řádek pořád strojový" "1" "$(printf '%s\n' "$OUT_NOMETA" | head -1 | grep -c '^BASELINE ')"
check "S4 a hlásí nezjisteno, ne aktuální" "1" "$(printf '%s\n' "$OUT_NOMETA" | head -1 | grep -c 'stav=nezjisteno')"
check "S4 návratový kód 3 (nelze rozhodnout)" "3" "$RC_NOMETA"

# --- S5: pole se čtou podle klíče, ne podle pozice ---------------------------
# Test čte hodnotu tak, jak ji čte konzument - a je jedno, kolikátá v řádku je.
HODNOTA_PROFIL="$(printf '%s\n' "$OUT_LINE" | tr ' ' '\n' | sed -n 's/^profil=//p')"
check "S5 hodnota pole profil je čitelná podle klíče" "1" "$([ -n "$HODNOTA_PROFIL" ] && echo 1 || echo 0)"

printf '\nSouhrn scénářů: %d FAIL\n' "$FAILN"
[ "$FAILN" -eq 0 ] || exit 1
