# Do platform library přibyli Humble a Komenský, marketingová role odevzdala produktovou microcopy

**ID:** 2026-08-03-hire-humble-komensky
**Osa:** A
**Vydáno:** 2026-08-03
**Autor:** Panoš (definice), Stanislav (rozhodnutí o hire a o rozsahu brány OR-11)
**Závažnost:** běžná
**Zdroj:** META 9c2b511 | GLOBAL 6018074
**Platforma:** 2.0.0
**Týká se:** vse
**Dosah:** runtime-pull, dokumentace
**Akce konzumenta:** žádná; noví agenti se načtou při příští session, na stroji NSL stačí `git pull` v `~/.claude`

## Co se změnilo

Platform library dostala dvě nové kanonické definice: **Humble** (release engineering a distribuce softwaru) a **Komenský** (technická dokumentace, uživatelské texty, poznámky k vydání pro klienta). Obojí per work order z 3. 8. 2026.

**Role pro marketingový text se zúžila.** Texty uvnitř klientského produktu (chybové hlášky, prázdné stavy, helptext) a manuály, runbooky, glosář a poznámky k vydání odešly ke Komenskému. Microcopy té role zůstává na marketingových površích. Změna je v jejím `description`, takže se projeví i v routingu orchestrátora.

**OR-11 dostala rozšířený rozsah.** Katalog content agentů (`foundation/content-context-engineering.md`) nově eviduje Komenského se **zúženou branou**: deklarace `Naloženo:` jen u nového nebo přepisovaného celého dokumentu a u zákaznických poznámek k vydání, ne u drobných editů. Precedent zúžení je Taiichi. Znění samotné normy OR-11 v META `CLAUDE.md` se nemění, mění se jen její rozsah v katalogu.

## Lidská věta

V týmu jsou dva noví lidé: Humble hlídá verze a to, aby změna doputovala k uživateli a šla vrátit, Komenský píše dokumentaci a texty, které čte klient. Role pro marketingový text píše marketing dál, texty uvnitř produktu už ne.

## Verifikace

```verify
runtime-pull   lib_grep   agents/humble.md              ^name: humble
runtime-pull   lib_grep   agents/komensky.md            ^name: komensky
runtime-pull   lib_grep   foundation/content-context-engineering.md   ^- \*\*Komenský\*\*
runtime-pull   lib_grep   agents/marketingova-role.md   poznámky k vydání \(Komenský\)
dokumentace    no_test
```

Testy míří do platform library, protože obě definice jsou třída 1 (platformní mašinerie) a jednotky je konzumují runtime-pullem. Do rendered artefaktů se Humble nerenderuje (per B-061 třída 1, tenant je příjemce vydání, ne provozovatel vydávacího mechanismu); u Komenského o zařazení do render profilu zatím nikdo nerozhodl, proto changeset vrstvu `rendered` nenese. Jednotka bez `$HOME/.claude` (cizí stroj) dostane u všech čtyř řádků `NEZJISTENO`, ne PASS.

## Poznámky

- **Otevřená položka pro Quentina META (dosah `dokumentace`):** propagace hire do manuálů zatím neproběhla. `docs/NAVOD.md`, `docs/TECHNIKA.md`, `docs/SLOVNIK.md` ani roster v `team/agent-stack.md` Humbla ani Komenského neznají, přestože maintenance pravidlo v META `CLAUDE.md` žádá všech pět kroků v jedné akci. Hlásím, neopravuji: manuály i roster jsou obsah METY pod Quentinem META. Ověřeno grepem 3. 8. 2026.
- **Řádek Komenského v katalogu je zatím jen v pracovním stromu** `~/.claude`, necommitnutý (commit 6018074 nese jen tři soubory `agents/`). Test proto prochází proti souboru na disku, což je správně: konzument čte disk, ne commit. Commit té změny je věcí úklidu pracovního stromu při zavedení brány.
- **Do definic agentů ani do znění norem jsem nesáhl.** Tenhle changeset je evidence změny, ne její zdroj (železné pravidlo 1, OR-09).
