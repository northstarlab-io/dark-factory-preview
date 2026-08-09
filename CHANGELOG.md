# Changelog

Formát podle [Keep a Changelog](https://keepachangelog.com/cs/1.1.0/), verzování podle
[Semantic Versioning](https://semver.org/lang/cs/). Tenhle soubor má vlastní řadu čísel:
počítá změny balíčku, ne změny platformy.

## [Nevydáno]

## [1.0.0] - 2026-08-09

Vyříznuto ze stavu platformy v2.14.0.

### Přidáno

- Engine platformy ke spuštění: validátor jednotky a fronty changesetů, sdílené shell
  funkce, sken přístupových údajů, dva testy, šablona jednotky.
- Vyplněná ukázková jednotka, na které validátor projde.
- Výběr reálných changesetů z jednoho týdne provozu plus kontrakt mechanismu propagace.
- Výběr definic rolí, metodických souborů a skillů z platformní knihovny.
- Dokumentace: co to je, prohlídka repa, architektura vrstev, provozní normy, mapa verzí,
  hranice balíčku, anonymizované casy.

### Poznámka k číslům

V balíčku jsou dvě čísla a nejsou to dva domovy jednoho čísla, ale dvě osy.
`VERSION` v kořeni je verze **tohohle balíčku** a mění se, když se změní balíček.
`scaffold/VERSION` je otisk **platformy**, ze které je balíček vyříznutý; validátor ho
čte a bez něj neběží. Podrobně v `docs/mapa-verzi.md`.

### Jak přijde další verze

Oprava je nové vydání, nikdy přepsaný tag. Vydaný stav je plně určený tagem `v1.0.0`.
