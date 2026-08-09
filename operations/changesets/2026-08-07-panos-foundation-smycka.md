# Panošova definice přestala rozsévat neexistující domov Foundation

**ID:** 2026-08-07-panos-foundation-smycka
**Osa:** A
**Vydáno:** 2026-08-07
**Autor:** Stanislav Skalický (zápis), Panoš (znění), Quentin META (evidence)
**Závažnost:** běžná
**Zdroj:** META (tento commit) | GLOBAL 80de437
**Platforma:** 2.7.0
**Týká se:** vše
**Dosah:** runtime-pull
**Akce konzumenta:** Žádná. Změna se projeví u definic psaných od teď.

## Co se změnilo

Dvě odrážky v `~/.claude/agents/panos.md` (sekce „Čeho se držet") posílaly **každou nově psanou agent definici** na `~/.claude/foundation/` jako domov NSL Foundation. To bylo špatně dvakrát: Foundation je Typ 2 se zdrojem pravdy v Notionu (AR-08 v2), takže `foundation/` jejím domovem nikdy nebyl, a po rozsudku Ariadne (`team-outcomes/046`) bude odvozenina v `~/.claude/nsl/foundation.md`, tedy jinde. Druhá odrážka navíc posílala agenty hledat do Foundation zakázaná slova a anti-AI styl, které žijí v `~/.claude/CLAUDE.md`.

Nové znění pojmenovává Notion jako kanonický zdroj, `~/.claude/foundation/` výslovně vylučuje jako domov Foundation (leží tam metodika Typu 1 s opačným směrem pravdy), zakázaná slova směruje na skutečný domov a odvozeninu zmiňuje s výhradou „jakmile vznikne" - natvrdo zapsaná cesta k neexistujícímu souboru by byla tatáž chyba s novým jménem.

**Proč to nezapsal agent:** OR-09 zakazuje agentovi editovat vlastní definici a Quentinovi METY editaci cizí definice mimo governance flow, jehož je Panoš vlastníkem. Opravář se tím sám opravit nemůže a zápis provedl člověk. Norma zafungovala, jak byla navržena; jestli z toho má vzniknout pravidlo dvou klíčů, je otevřená otázka mimo tento changeset.

## Lidská věta

Panoš přestal do každé nové definice psát cestu k Foundation, která neexistuje, takže se ta chyba dál nerozsévá.

## Verifikační test

```verify
runtime-pull    lib_grep agents/panos.md necituj jako domov Foundation
runtime-pull    lib_grep agents/panos.md nehledej ve Foundation
runtime-pull    lib_grep agents/panos.md zdrojem pravdy v Notionu
```
