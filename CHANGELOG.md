# Changelog

Formát podle [Keep a Changelog](https://keepachangelog.com/cs/1.1.0/), verzování podle
[Semantic Versioning](https://semver.org/lang/cs/). Tenhle soubor má vlastní řadu čísel:
počítá změny balíčku, ne změny platformy.

## [1.2.0] - 2026-08-10

### Přidáno

- Definice role, kterou vydání 1.1.0 vyřadilo celou, je v `knihovna/agents/` zpátky.
  Platformní knihovna je tím v balíčku kompletní.

### Změněno

- `knihovna/README.md` a `docs/hranice-baliku.md` už netvrdí, že část knihovny zůstala
  doma. Doma zůstávají jen definice vázané na jednu jednotku nebo na jednoho tenanta.

## [1.1.0] - 2026-08-10

### Přidáno

- Definice rolí z platformní knihovny nejsou nadále výběr devíti, ale celá knihovna
  kromě rolí vázaných na jednu jednotku nebo tenanta a kromě jedné vyřazené celé.
  `knihovna/README.md` říká rovnou, že seznam není úplný, a proč.
- `docs/pripady-pouziti/` - čtyři případy práce z reálných projektů (nasazení sady rolí
  u zákazníka, interní nástroj nad vlastním provozem, znalostní úloha zakončená normou
  a vznik tohohle balíčku) plus rozcestník s pravidly anonymizace.
- `docs/datove-vrstvy.md` - dvě osy rozhodování o umístění obsahu, zavedená podoba PARA,
  datové zdroje a čtyři místa, kde to dnes drhne.

### Změněno

- Rozcestníky vedou na oba nové celky: kořenový `README.md`, `docs/PROHLIDKA.md`,
  `docs/CO-JE-DARK-FACTORY.md`, `docs/hranice-baliku.md`, `docs/architektura-vrstev.md`
  a `docs/casy/README.md`.
- Incident s rozšířenými oprávněními při renderu má jediný domov
  v `docs/casy/02-vycet-zakazaneho-je-o-krok-pozadu.md`; architektura vrstev a případ
  nasazení na něj odkazují místo druhého vyprávění (OR-10, kanonizační pravidlo).
- `docs/datove-vrstvy.md` popisuje pilířovou vrstvu pravidlem a anonymizovanými
  rozlišovacími testy; jmenný výčet pilířů a jejich počet z textu odešly.
- V definicích rolí se vrátila jména sousedních rolí tam, kde je předchozí vydání
  nahradilo popisem domény. Důvod té náhrady odpadl, když je v balíčku celá knihovna.

## [1.0.0] - 2026-08-09

Vyříznuto ze stavu platformy v2.14.0.

### Přidáno

- Engine platformy ke spuštění: validátor jednotky a fronty changesetů, sdílené shell
  funkce, sken přístupových údajů, dva testy, šablona jednotky.
- Vyplněná ukázková jednotka, na které validátor projde.
- Výběr reálných changesetů z jednoho týdne provozu plus kontrakt mechanismu propagace.
- Definice rolí z platformní knihovny, k nim vybrané metodické soubory a skilly.
- Dokumentace: co to je, prohlídka repa, architektura vrstev, provozní normy, mapa verzí,
  hranice balíčku, anonymizované casy.

### Poznámka k číslům

V balíčku jsou dvě čísla a nejsou to dva domovy jednoho čísla, ale dvě osy.
`VERSION` v kořeni je verze **tohohle balíčku** a mění se, když se změní balíček.
`scaffold/VERSION` je otisk **platformy**, ze které je balíček vyříznutý; validátor ho
čte a bez něj neběží. Podrobně v `docs/mapa-verzi.md`.

### Jak přijde další verze

Oprava je nové vydání, nikdy přepsaný tag. Vydaný stav je plně určený tagem `v1.0.0`.
