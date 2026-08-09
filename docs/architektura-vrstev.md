# Architektura vrstev

Systém je rozdělený podle jedné otázky: **kdo který obsah spravuje.** Ne podle toho, kde
obsah leží na disku, a ne podle toho, komu patří projekt. Když se to dělí podle lokace,
vypadá to na první pohled přehledněji a do měsíce nejde odpovědět, kdo smí co změnit.

## Čtyři vrstvy

| Vrstva | Co spravuje | Kdo ji řídí |
|---|---|---|
| **USER** | Osobní kontext držitele účtu: styl, tonalita, osobní pravidla, osobní paměť. Nikdy není součástí platformy a nedistribuuje se. | člověk sám |
| **META** | Platformu: šablonu jednotky, engine a brány, normy, dokumentaci a **platformní knihovnu** (kanonické definice rolí, metodická jádra, skills). | orchestrátor platformy |
| **TENANT** | Jeden celek, pro který se pracuje, a jeho portfolio jednotek. Tenantem je firma sama, zákazník nebo jiný samostatný celek. | orchestrátor tenanta |
| **STUDIO** | Jednu oblast nebo jeden problém. Vlastní `CLAUDE.md`, `operations/`, `team-inbox/`, `team-outcomes/`. V řeči se jí říká **jednotka**. | orchestrátor jednotky |

**Jedna fyzická složka může nést dvě vrstvy a je to vědomé.** Uživatelský adresář nástroje
drží zároveň osobní kontext (USER) a platformní knihovnu (META). Fyzicky je to jedno místo,
protože ho tak čte nástroj; správa je rozdělená a rozhoduje o tom, co kam smí přibýt.

## Proč podle správy a ne podle lokace

Předchozí model dělil scope na meta, globální, instanční a portfoliový. Měl dvě strukturní
vady, které se obě projevily v provozu:

- **Globální vrstva slučovala dvě governance domény.** Osobní pravidla člověka a platformní
  knihovna stály vedle sebe a nikde nebylo napsané, kdo knihovnu vlastní. Důsledkem byl
  drift, doložený dvakrát: nová role vznikla a nepropsala se do odvozeného katalogu, takže
  provozně existovala a evidenčně ne; a norma se nepropsala do nově založené jednotky,
  protože žila jen v kořenovém souboru platformy a šablona ji nenesla.
- **Portfoliová vrstva byla definovaná v jednotném čísle**, jako pohled jednoho člověka
  přes všechno. To neškáluje ve chvíli, kdy se platforma nasadí u někoho dalšího: nasazení
  u zákazníka ani samostatná firma v takovém modelu nemají místo.

Nová vrstva TENANT je zobecnění, ne přejmenování: první tenant není definice vrstvy, je to
její první instance.

## Jednotka je atom celého systému

Všechno ostatní je buď uvnitř jednotky, nebo mezi jednotkami. Jednotka je adresář, který
má:

```
<jednotka>/
├── CLAUDE.md          kontext zadání a zkrácený výtah norem
├── operations/        stav, backlog, rozhodnutí, runbooky, evidence převzatých změn
├── team-inbox/        vstupy zvenčí, nic se odtud nemaže
├── team-outcomes/     hotové výstupy, číslované per OR-06, s archivem
└── .claude/agents/    lokální nadstavby definic, výchozí stav prázdný
```

Vyplněnou jednotku máš v balíčku jako `ukazka-jednotky/`. Vznikla zkopírováním
`scaffold/studio-template/` a vyplněním hlavičky, nic víc; `bash scaffold/validate.sh
ukazka-jednotky` nad ní projde.

Hlavička `operations/status.md` je kontrakt (OR-03) a je to místo, ze kterého se čte stav
portfolia. Nese ještě dvě metadata jednotky vedle stavu a fáze; jejich obor hodnot je vidět
v šabloně a tady je nerozvádím, protože k pochopení vrstev nepřidávají a jsou to interní
evidence.

**Orchestrátor a specialista.** Orchestrátor jednotky zadává, koordinuje a drží kvalitu
zadání; specialisté dělají práci ve svých doménách. Rozdíl mezi tím, když session roli
**převezme** (je jí po celou dobu), a když ji **zavolá jako subagenta** (izolovaný kontext,
vrátí výsledek), je technický fakt s důsledky, ne styl. Převzatá role vidí celou historii
session, zavolaná začíná s prázdným kontextem a dostane jen to, co jí kdo napíše - odtud
OR-01.

## Platformní knihovna

Knihovna drží kanonické definice rolí, metodická jádra, na která definice odkazují, a
skills. Co z ní je v tomhle balíčku, najdeš ve složce [`knihovna/`](../knihovna/README.md).

Dvě pravidla, na kterých knihovna stojí:

- **Definice role má právě jeden kanonický domov.** Jediné místo, kde se role rozvíjí;
  poznatky z provozu se propisují tam, po lidském schválení, a nikdy do kopií.
- **Lokální odchylka se dělá jako pojmenovaná nadstavba, nikdy kopií pod týmž jménem.**
  Kopie je fork a fork je drift: odpojí se od kanonické definice a už nikdy nedostane
  vylepšení. Nadstavba naopak kanonickou definici načte a přidá jen rozdíl, takže je čerstvá
  z konstrukce. Zákaz stínění kontroluje `validate.sh`.

## Architektonická rozhodnutí

Platforma má třináct architektonických rozhodnutí. Ta, která tvarují vrstvy a práci uvnitř
nich, jsou tady; zbytek se týká distribuce k jinému prostředí a vztahu k zákaznickým datům
a v tomhle balíčku není (viz [`hranice-baliku.md`](hranice-baliku.md)).

| # | Rozhodnutí | Jednou větou |
|---|---|---|
| AR-02 | Jeden zdroj pravdy pro definice rolí | Definice žije v knihovně; ručně psaný duplikát v projektu neexistuje, odvozený katalog se generuje. |
| AR-03 | `operations/` jako povinná vrstva jednotky | Bez stavu, backlogu, rozhodnutí a runbooků není jednotka provoz, ale sklad dokumentů. |
| AR-04 | `strategic/` jako volitelná vrstva | Strategická práce má vlastní místo, ale jen tam, kde se dělá; prázdná kostra je vycpávka. |
| AR-05 | Čtyři vrstvy podle správy | Tabulka nahoře. Fyzická lokace je organizační konvence, ne architektonický rozdíl. |
| AR-06 | Víc úrovní orchestrace, jeden vstupní bod | Člověk mluví s jedním orchestrátorem; ten zakládá jednotky a předává je jejich vlastním orchestrátorům. Paralelní provoz bez kolize kontextů. |
| AR-07 | Repozitář je pracovní paměť, znalostní báze dlouhodobá | Rozpracované žije v repu, vydané a trvalé ve znalostní bázi. |
| AR-08 | Dva typy obsahu, dva zdroje pravdy | Implementační obsah (definice, skills, normy, kód) má zdroj pravdy na disku a je verzovaný gitem. Živý obsah firmy má zdroj pravdy ve znalostní bázi a do gitu nepatří. |
| AR-12 | Vrstvení definic | Kanonická definice plus nanejvýš jedna nadstavba. Řetězení nadstaveb je signál špatné granularity, ne řešení. |
| AR-13 | Propagace změn | Changeset, evidence převzetí, brána. Detail níž. |

## Scaffold: šablona jako verzovaný artefakt

`scaffold/` není složka se vzorovými soubory, je to engine. Nová jednotka vzniká kopií
šablony, ne ručním skládáním, a integritu kontroluje validátor.

**Seam mezi enginem a daty.** Aby upgrade platformy mohl bezpečně přepsat šablonové soubory
a nikdy nesáhl na data jednotky, dělí `scaffold/manifest.json` cesty do dvou množin:

- **engine** jsou šablonové soubory platformy. Upgrade je smí přepsat, takže se ručně
  needitují; ruční změna by se při příštím upgradu ztratila.
- **state** jsou data jednotky (kontext, stav, backlog, výstupy, lokální nadstavby).
  Upgrade se jich nedotkne nikdy.
- **Politika je fail-closed.** Cesta, která není ani v jedné množině, se nedotýká a flagne
  se k ručnímu rozhodnutí. Nejasnost znamená neměnit.

Zdroj kopie se nikde nemapuje: cesta v šabloně je táž jako cesta v jednotce. Manifest cesty
klasifikuje, není to kopírovací skript. Obě strany hlídá kontrola platformního validátoru:
deklarovaná cesta bez souboru v šabloně (mrtvá deklarace) i soubor v šabloně bez zařazení
(díra v seamu) jsou chyba.

**Dva validátory, dvě otázky.** `validate.sh` se ptá „je tahle jednotka v pořádku?"
a běží nad libovolným adresářem. `validate-platform.sh` se ptá „je platforma v pořádku?"
a měří invarianty knihovny, norem a propagace; v balíčku neběží, protože mu chybí korpus,
nad kterým měří, ale `--help` vypíše kontrakt kontrol generovaný z hlavičky vlastního
skriptu, takže se s ním nemůže rozejít.

## Propagace změn: dvě osy, jedna evidence

Změny se šíří dvěma nezávislými cestami a ty se nesmí slít, protože mají jiný obsah, jiný
motor a jiné publikum.

| | Osa A: způsob práce | Osa B: software |
|---|---|---|
| Obsah | definice rolí, normy, šablony, engine | server, rozhraní, skripty, dokumentace produktu |
| Motor | kopie šablon a knihovny | vydání s tagem a řízená instalace |
| Evidence u příjemce | `operations/platform-baseline.md` jednotky | evidence instalace u té instance |

**Changeset** je lístek k jedné změně: co se změnilo, koho se to týká, co má příjemce
udělat, lidská věta a ověřovací test. Testy se formulují proti profilu artefaktu, ne proti
zdroji, a mají tři výsledky: prošlo, neprošlo, nezjištěno. **Nezjištěno se nikdy nepočítá
jako prošlo** - to je celá pointa fail-closed jazyka.

**Evidence převzetí** zapisuje výhradně nástroj a jen po průchodu testem. Ruční editace té
evidence je lež o synchronizaci. Vědomé východisko existuje a je viditelné jako „převzato
na slovo", ne jako mlčení.

**Fronta se počítá v changesetech, ne v commitech.** „Pozadu o 47 commitů" je šum, po
kterém nikdo nic neudělá. „Pozadu o 2 changesety" je věta, po které někdo něco udělá.

Vyzkoušej si to: `bash scaffold/validate.sh --baseline ukazka-jednotky --line`. Přiložená
jednotka je schválně pozadu, protože baseline založená dnes počítá frontu od nuly. Je to
živá ukázka toho, o čem tahle sekce je - změna, kterou nikdo nepřevzal, je vidět jako
číslo, ne jako pocit.

## Index platformy

Vedle propagace stojí druhá třída změn: změna kanonického domova faktu, kterou nikdo
**nepřebírá**, ale kterou někdo **čte**. Changesetem z konstrukce propadá, což je změřené,
ne odhadnuté: za dva týdny sáhlo 16 z 51 commitů na dokumentaci a žádný nevyvolal událost.

Evidencí té třídy je generovaný index kanonických domovů s otiskem obsahu. Tři soubory,
tři role, žádnou nelze zaměnit: **deklarace tříd faktů** (píše člověk), **generovaný index
skutečnosti** (píše výhradně generátor) a **lidský rozcestník** (odvozenina téhož běhu).

Index je index skutečnosti, ne evidence záměru. Tím se liší od evidence převzetí: tam je
ruční editace lež, tady je neškodná, protože ji regenerace přepíše; měnit se má deklarace.
A index není třetí osa propagace, je to evidence **plochy**, nad kterou obě osy pracují.

## Kde je člověk

Pět míst, ze kterých se člověk neplánuje odstranit, je vypsaných v
[CO-JE-DARK-FACTORY.md](CO-JE-DARK-FACTORY.md), sekce „Kde zůstává člověk". Podruhé je
sem nepíšu schválně: kanonický domov faktu je jeden a druhá kopie se od něj do měsíce
odchýlí. Tenhle odkaz je zároveň nejlevnější ukázka toho pravidla v praxi.
