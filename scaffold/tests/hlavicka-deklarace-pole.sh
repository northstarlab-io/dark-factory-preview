#!/usr/bin/env bash
#
# Pole OR-03 hlavičky se čte z DEKLARACE, ne z výskytu jména pole kdekoli v hlavičce.
#
#   bash scaffold/tests/hlavicka-deklarace-pole.sh
#
# Regrese, kterou test drží (9. 8. 2026, scaffold 2.12.0): kontrola (h) brala hodnotu
# pole `Slouží:` z prvního řádku, který ten řetězec obsahoval. META si pole doplnila
# správně, ale v poli `Last update` o něm zároveň napsala větu - a validátor přečetl
# jako hodnotu zbytek té věty. Hlavička zapsaná podle normy tak neprošla vlastní bránou.
#
# Testuje se průchodem nad fixturami v dočasném adresáři, na živé jednotky se nesahá.
# Scénáře jdou po obou směrech vady: zmínka nesmí vyrobit FAIL (S1, S3, S6) a nesmí
# vyrobit ani falešné PASS (S2, S4, S7).
#
# POSIX-friendly bash 3.2, macOS BSD nástroje.

set -u

SELF_DIR="$(cd "$(dirname "$0")" && pwd)"
META="${SELF_DIR%/scaffold/tests}"
VAL="$META/scaffold/validate.sh"

ROOT="$(mktemp -d "${TMPDIR:-/tmp}/nsl-hlavicka-test.XXXXXX")"
trap 'rm -rf "$ROOT"' EXIT

FAILN=0
check() { # <popis> <očekáváno> <skutečnost>
  if [ "$2" = "$3" ]; then
    printf 'PASS  %s\n' "$1"
  else
    printf 'FAIL  %s\n        čekáno: [%s]\n        reálně: [%s]\n' "$1" "$2" "$3"
    FAILN=$((FAILN + 1))
  fi
}

# Výsledek jedné kontroly z výpisu validátoru: "PASS", "FAIL", "WARN", "n/a" nebo "-".
vysledek() { # <výpis> <značka kontroly, např. "(h)">
  printf '%s\n' "$1" | awk -v zn="$2" '$2 == zn {print $1; found=1; exit} END{if (!found) print "-"}'
}

# Jednotka studio profilu: CLAUDE.md s deklarací Klasifikace + hlavička ze stdin.
jednotka() { # <cesta> [obsah CLAUDE.md]
  mkdir -p "$1/operations"
  if [ "${2:-}" = "bez-klasifikace" ]; then
    # Klasifikace jen jako zmínka v próze - nikoli deklarace.
    printf '# Fixture\n\nAR-05 říká, že Klasifikace projektu je metadata zadání.\n' > "$1/CLAUDE.md"
  else
    printf '# Fixture\n\n- **Klasifikace:** Internal. Autoritativní zdroj typu projektu.\n' > "$1/CLAUDE.md"
  fi
  cat > "$1/operations/status.md"
}

# --- S1: zmínka pole v próze nesmí přebít deklaraci ------------------------
# Přesná podoba vady z 9. 8.: věta o poli `Slouží:` v poli `Last update`.
U1="$ROOT/s1-zminka-v-proze"
jednotka "$U1" <<'EOF'
# Status - fixture

**Last update:** 2026-08-09 - hlavička jednotky nese nové pole `Slouží:` (osa mandátu, uzavřený obor hodnot); chybějící hodnota varuje, hodnota mimo obor padá.
**Klasifikace:** Internal
**Slouží:** Dark Factory
**Fáze:** Provoz
**Health:** 🟢
**Aktivní úkoly (top 3):**
- nic
**Blokátory:** žádné
**Next milestone:** žádný

## Rolling log
EOF
OUT1="$(bash "$VAL" "$U1" 2>&1)"
check "S1 (h) čte deklaraci, ne větu o poli" "PASS" "$(vysledek "$OUT1" "(h)")"
check "S1 (h) hlásí hodnotu z deklarace" "1" "$(printf '%s\n' "$OUT1" | grep -c '"Dark Factory" je z uzavřeného oboru')"
check "S1 (b) hlavička je úplná" "PASS" "$(vysledek "$OUT1" "(b)")"

# --- S2: neplatná hodnota na deklaračním řádku padá i vedle platné zmínky ---
U2="$ROOT/s2-neplatna-deklarace"
jednotka "$U2" <<'EOF'
# Status - fixture

**Last update:** 2026-08-09 - obor hodnot pole je NorthStar Lab, Dark Factory nebo žádná.
**Klasifikace:** Internal
**Slouží:** Kdovíco
**Fáze:** Provoz
**Health:** 🟢
**Aktivní úkoly (top 3):**
- nic
**Blokátory:** žádné
**Next milestone:** žádný

## Rolling log
EOF
OUT2="$(bash "$VAL" "$U2" 2>&1)"
check "S2 (h) neplatná hodnota padá" "FAIL" "$(vysledek "$OUT2" "(h)")"
check "S2 (h) hlásí hodnotu z deklarace, ne ze zmínky" "1" "$(printf '%s\n' "$OUT2" | grep -c 'hodnota "Kdovíco" není v uzavřeném oboru')"

# --- S3: samotná zmínka bez deklarace není vyplněné pole -------------------
U3="$ROOT/s3-jen-zminka"
jednotka "$U3" <<'EOF'
# Status - fixture

**Last update:** 2026-08-09 - do hlavičky se doplňuje pole `Slouží:` s hodnotou Dark Factory, zatím se k tomu nikdo nedostal.
**Klasifikace:** Internal
**Fáze:** Provoz
**Health:** 🟢
**Aktivní úkoly (top 3):**
- nic
**Blokátory:** žádné
**Next milestone:** žádný

## Rolling log
EOF
OUT3="$(bash "$VAL" "$U3" 2>&1)"
check "S3 (h) zmínka není hodnota" "WARN" "$(vysledek "$OUT3" "(h)")"
check "S3 (h) hlásí chybějící pole" "1" "$(printf '%s\n' "$OUT3" | grep -c 'pole chybí')"

# --- S4: pole zmíněné v próze, ale nedeklarované, nesmí projít jako úplné ---
# Reálný tvar vady: deklarace přilepená na konec odrážky v `Aktivní úkoly`.
U4="$ROOT/s4-privarene-pole"
jednotka "$U4" <<'EOF'
# Status - fixture

**Last update:** 2026-08-09
**Klasifikace:** Internal
**Fáze:** Provoz
**Health:** 🟢
**Aktivní úkoly (top 3):**
- něco velkého, co se v jedné editaci slilo s dalším polem **Blokátory:**
**Next milestone:** žádný

## Rolling log
EOF
OUT4="$(bash "$VAL" "$U4" 2>&1)"
check "S4 (b) přivařené pole se nepočítá" "FAIL" "$(vysledek "$OUT4" "(b)")"
check "S4 (b) jmenuje chybějící pole" "1" "$(printf '%s\n' "$OUT4" | grep -c 'chybí deklarace pole: "Blokátory"')"

# --- S5: upřesnění v závorce před dvojtečkou je pořád deklarace ------------
# V provozu existuje `**Next milestone (aktualizováno 3.8. 22:30):**` - ukotvení
# nesmí být tak úzké, aby ho zahodilo.
U5="$ROOT/s5-upresneni-v-zavorce"
jednotka "$U5" <<'EOF'
# Status - fixture

**Last update:** 2026-08-09
**Klasifikace:** Internal
**Fáze:** Provoz
**Health:** 🟢
**Aktivní úkoly (top 3):**
- nic
**Blokátory:** žádné
**Next milestone (aktualizováno 3.8. 22:30):** ranní běh

## Rolling log
EOF
OUT5="$(bash "$VAL" "$U5" 2>&1)"
check "S5 (b) upřesnění v závorce projde" "PASS" "$(vysledek "$OUT5" "(b)")"

# --- S6: věta o normě OR-10 neshodí kontrolu (c) --------------------------
U6="$ROOT/s6-zminka-o-or10"
jednotka "$U6" <<'EOF'
# Status - fixture

**Last update:** 2026-08-09 - per OR-10 se řetězení `Předchozí:` do hlavičky nepíše, historie patří do rolling logu.
**Klasifikace:** Internal
**Fáze:** Provoz
**Health:** 🟢
**Aktivní úkoly (top 3):**
- nic
**Blokátory:** žádné
**Next milestone:** žádný

## Rolling log
EOF
OUT6="$(bash "$VAL" "$U6" 2>&1)"
check "S6 (c) zmínka o normě neshodí kontrolu" "PASS" "$(vysledek "$OUT6" "(c)")"

# --- S6b: skutečné řetězení historie pořád padá ---------------------------
U6B="$ROOT/s6b-skutecne-retezeni"
jednotka "$U6B" <<'EOF'
# Status - fixture

**Last update:** 2026-08-09 - hotovo. **Předchozí:** 2026-08-08 - taky hotovo.
**Klasifikace:** Internal
**Fáze:** Provoz
**Health:** 🟢
**Aktivní úkoly (top 3):**
- nic
**Blokátory:** žádné
**Next milestone:** žádný

## Rolling log
EOF
OUT6B="$(bash "$VAL" "$U6B" 2>&1)"
check "S6b (c) skutečné řetězení padá" "FAIL" "$(vysledek "$OUT6B" "(c)")"

# --- S7: zdroj Klasifikace se hlásí podle deklarace, ne podle zmínky -------
U7="$ROOT/s7-zdroj-klasifikace"
jednotka "$U7" "bez-klasifikace" <<'EOF'
# Status - fixture

**Last update:** 2026-08-09
**Klasifikace:** Internal
**Fáze:** Provoz
**Health:** 🟢
**Aktivní úkoly (top 3):**
- nic
**Blokátory:** žádné
**Next milestone:** žádný

## Rolling log
EOF
OUT7="$(bash "$VAL" "$U7" 2>&1)"
check "S7 (a) prochází" "PASS" "$(vysledek "$OUT7" "(a)")"
check "S7 (a) hlásí zdroj, kde hodnota opravdu je" "1" "$(printf '%s\n' "$OUT7" | grep -c 'nalezeno v: operations/status.md')"

# --- S8: tenant režim čte hlavičku harnessu stejnou optikou ----------------
U8="$ROOT/s8-tenant"
mkdir -p "$U8/team-inbox" "$U8/escalations" "$U8/operations"
printf '# Fixture harness\n' > "$U8/CLAUDE.md"
printf '# Portfolio\n' > "$U8/portfolio-status.md"
cat > "$U8/operations/status.md" <<'EOF'
# Status - fixture harness

**Last update:** 2026-08-09 - harness dostal pole `Slouží:` do hlavičky.
**Klasifikace:** Client
**Slouží:** NorthStar Lab
**Fáze:** Provoz
**Health:** 🟢
**Aktivní úkoly (top 3):**
- nic
**Blokátory:** žádné
**Next milestone:** žádný

## Rolling log
EOF
OUT8="$(bash "$VAL" "$U8" --tenant 2>&1)"
check "S8 (t5) hlavička harnessu je úplná" "PASS" "$(vysledek "$OUT8" "(t5)")"
check "S8 (t6) čte deklaraci, ne zmínku" "PASS" "$(vysledek "$OUT8" "(t6)")"
check "S8 (t6) hlásí hodnotu z deklarace" "1" "$(printf '%s\n' "$OUT8" | grep -c '"NorthStar Lab" je z uzavřeného oboru')"

printf '\nSouhrn scénářů: %d FAIL\n' "$FAILN"
[ "$FAILN" -eq 0 ] || exit 1
