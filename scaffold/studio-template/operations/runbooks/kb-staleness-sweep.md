# Runbook - Staleness sweep živého obsahu

> Periodická revize živého obsahu projektu per OR-10 (lifecycle obsahu). Cíl: zastaralá, duplicitní a osiřelá informace se najde a vyřadí dřív, než na ní někdo postaví chybný výstup. Zastaralá informace v KB je aktivní škoda, ne neutrální šum.

## Vlastník

- **Role pro provoz znalostní báze**, pokud je v týmu projektu - drží sweep mechaniku.
- Jinak **orchestrátor projektu** (Quentin per-projekt, v tenant scope tenantní orchestrátor).
- Strukturní zásahy ve znalostní bázi vykonává **role pro informační architekturu** per OR-05 (viz krok 4).

## Cadence

- **Default: měsíčně.**
- **Aktivní projekty** (denní provoz, rychle rostoucí obsah): **týdně.**
- Ad-hoc trigger: po velké dodávce, po uzavření fáze, po migraci obsahu.

## Postup

1. **Inventura živých dokumentů.** Soupis všech živých dokumentů projektu: `operations/status.md`, `operations/backlog.md`, `team-outcomes/*`, `team-inbox/*`, methodology deliverables, napojené Notion KB stránky. U každého zaznamenej poslední úpravu (git log / mtime / Notion last-edited).
2. **Flag per dokument.** Projdi každý dokument a označ:
   - **zastaralé** - popisuje stav, který už neplatí (uzavřená linie, superseded verze).
   - **duplicitní** - fakt žije kanonicky jinde; tato kopie je bug per OR-10 kanonizační pravidlo.
   - **osiřelé** - nikdo na dokument neodkazuje, nemá vlastníka ani vazbu na aktivní úkol.
3. **Návrh akce per flag.** Ke každému flagu přiřaď: **archiv** (přesun do `team-outcomes/archive/`) / **update** (dožití na aktuální stav) / **smazání** (jen bezcenný duplikát, dohledatelnost zůstává přes git) / **kanonizace** (nahradit duplikát odkazem `[text](cesta.md)`).
4. **Lidské schválení.** Předlož soupis flagů + návrhů Stanislavovi (nebo vlastníkovi projektu). **Žádný destruktivní zásah bez schválení.** Notion strukturní operace (move, `replace_content`, edit stránky s inline databázemi) se provádí POVINNĚ per OR-05 3-krokovým postupem: pre-op fetch soupisu všech children -> operace -> post-op verifikační fetch (každá child page / DB musí být živá). Deleguj na roli, která vlastní strukturu znalostní báze.
5. **Provedení + zápis.** Proveď schválené akce. Zapiš shrnutí sweepu do rolling logu `operations/status.md` (co flagnuto, co provedeno, co odloženo, s datem). OR-03 header updatuj jen při reálné změně health / blokátoru.

## Výstupní formát flagu

Jeden blok per flag:

- **Lokace:** cesta k souboru nebo Notion odkaz (u secretu jen lokace, nikdy hodnota - OR-02).
- **Důvod:** zastaralé / duplicitní / osiřelé + jedna věta proč.
- **Návrh:** archiv / update / smazání / kanonizace.
- **Riziko:** co se pokazí, když se to nechá být, nebo když se akce provede (vč. dopadu na odkazy z jiných dokumentů).
