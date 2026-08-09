# Normy k indexu platformy a k vykonávané konfiguraci

**ID:** 2026-08-06-normy-index-a-vykonavana-konfigurace
**Osa:** A
**Vydáno:** 2026-08-06
**Autor:** Quentin META
**Závažnost:** běžná
**Zdroj:** META (tento commit)
**Platforma:** 2.4.0
**Týká se:** vše
**Dosah:** dokumentace
**Akce konzumenta:** Přečíst OR-12 povinnost 3 a doplněk OR-09. Pro jednotky se nic nemění, obě se týkají práce v METĚ.

## Co se změnilo

**OR-12 má nově tři povinnosti místo dvou.** Třetí zní: kdo mění kanonický domov platformy evidovaný v `project-init/platform-index.json`, regeneruje index v témž commitu. Není to náhrada changesetu, obě povinnosti se posuzují nezávisle, protože každá odpovídá na jinou otázku. Changeset říká, co má kdo převzít. Index říká, co se změnilo ve čtené ploše platformy, tedy v tom, co konzument jen čte a nepřebírá. Východiskem z brány je regenerace jedním příkazem, ne evidovaná výjimka - u něčeho tak levného by výjimka byla jen pohodlnost.

Do OR-12 přibyl odstavec o automatickém spouštění brány a odstavec o evidovaných výjimkách místo posunu kotvy. Druhý jmenovaný uzavírá vzorec, který se během tří dnů objevil dvakrát: kotva je jeden bod a každý posun promine celý rozsah před sebou, takže po druhém posunu už není co počítat.

**OR-09 dostala doplněk o vykonávané konfiguraci.** Pod pravidlo „agent nepřepisuje vlastní kontrakt" nově výslovně spadá `scaffold/hooks/**` a nastavení `core.hooksPath`. Agent smí hook napsat jako běžnou verzovanou změnu, ale aktivovat ho na stroji smí jen člověk. Samoaktivující se vykonávaná konfigurace je nerozlišitelná od driftu, což je přesně ta hranice, kterou OR-09 chrání u definic.

**AR-13 dostal doplněk o indexu platformy.** Popisuje tři soubory a jejich role (deklarace psaná člověkem, generovaný index, odvozený lidský rozcestník), rozlišení „index skutečnosti versus evidence záměru" proti baseline, invariant „index vybírá, allowlist autorizuje, nikdy naopak", a výslovné konstatování, že index **není třetí osa propagace**, ale evidence plochy, nad kterou obě osy pracují. K tomu vysvětlení vrstvy `dokumentace`, která byla do dneška netestovatelná, a invariant vykonávané brány.

**Deklarace tříd faktů přepnuta na `platny`.** Tím se kontrola (11) ve `validate-platform.sh` mění z WARN na fail-closed, per rozhodnutí Stanislava ze 6. 8. 2026 (fail-closed plus automatické spouštění). Index zregenerován, 67 položek, 20 měřených otiskem.

## Lidská věta

Mechanismus, který od včerejška existuje jako skripty a kontroly, je od teď zapsaný jako norma, takže platí i pro toho, kdo ty skripty nikdy neviděl.

## Verifikační test

```verify
dokumentace     grep CLAUDE.md ^\*\*Pravidlo - tři povinnosti:\*\*
dokumentace     grep CLAUDE.md regeneruje index v témž commitu
dokumentace     grep CLAUDE.md Doplněk 2026-08-06 - vykonávaná konfigurace
dokumentace     grep project-init/02-architektura-vrstev.md ^\*\*Index platformy \(doplněk 2026-08-06\)
dokumentace     grep project-init/02-architektura-vrstev.md index vybírá, allowlist autorizuje
dokumentace     grep scaffold/platform-index-config.json "stav": "platny"
```
