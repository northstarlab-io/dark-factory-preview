# team-outcomes

Persistentní výstupy projektu, které mají přežít session - dokončené deliverables k revizi, výstupy metodické práce, záznamy. Ne rozpracované věci (ty žijí v pracovní paměti session).

## Číslování výstupů (OR-06)

Každý **sekvenční jednorázový výstup** dostane trojmístný nulou-doplněný prefix: `NNN-<slug>.md` (`001-`, `002-`, ...). Cíl je vidět z názvů pořadí, v jakém výstupy vznikaly.

- **Přidělení čísla:** před zápisem glob `team-outcomes/[0-9][0-9][0-9]-*` → nové číslo = (max existující `NNN-` prefix) + 1. Když žádný číslovaný soubor neexistuje, začni `001-`. Při dávce víc souborů přiděluj sekvenčně (`007-`, `008-`, `009-`), ne stejné číslo.
- **Kolize:** pokud vyjde už obsazené číslo, vezmi nejbližší volné.
- **Forward-only:** existující soubory se za provozu nepřečíslovávají, nová čísla jen přibývají na konci.

**Výjimka (NEčíslovat) - stabilní živé methodology deliverables**, na které odkazují agent definice stálým jménem a průběžně se aktualizují (číslo by u nich pořadí nevyjádřilo a přejmenování by rozbilo odkazy):
- `<projekt>-knowledge-architecture.md` (znalostní architektura), `<projekt>-workshop-playbook.md` (facilitace), `<projekt>-kb-operations-runbook.md` (provoz znalostní báze), `<projekt>-research-architecture.md` (výzkum), `<projekt>-system-architecture.md` (Ariadne), `<projekt>-assumption-map-<date>.md` (validace hypotéz) a obdobné stable-name deliverables odkazované agent definicí.

Kanonický text OR-06 (Why / reference): `docs/normy.md`.

## Archivace (OR-10)

Výstupy nahrazené novější verzí nebo uzavřenou linií → přesun do `team-outcomes/archive/`. Aktivní složka drží jen živé výstupy, historie žije v archivu. U Notion strukturních zásahů platí OR-05 (pre-op soupis + post-op verifikace).
