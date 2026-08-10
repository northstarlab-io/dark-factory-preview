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
portfolia. Vedle stavu a fáze nese dvě metadata, která rozhodují o tom, jak se s jednotkou
zachází; rozepsaná jsou níž v této sekci.

**Orchestrátor a specialista.** Orchestrátor jednotky zadává, koordinuje a drží kvalitu
zadání; specialisté dělají práci ve svých doménách. Rozdíl mezi tím, když session roli
**převezme** (je jí po celou dobu), a když ji **zavolá jako subagenta** (izolovaný kontext,
vrátí výsledek), je technický fakt s důsledky, ne styl. Převzatá role vidí celou historii
session, zavolaná začíná s prázdným kontextem a dostane jen to, co jí kdo napíše - odtud
OR-01.

### Klasifikace a typ: jen jedno z těch dvou polí smí řídit chování

**Klasifikace** říká, pro koho se pracuje a v jakém režimu. Jednotka je interní, zákaznická,
osobní, nebo je to samotná platforma. Klasifikace **chování řídit smí** a je to jediné pole
hlavičky, které to smí: orchestrátor jednotky podle ní volí, jak se nakládá s citlivými
daty, co smí opustit repozitář, jak často se hlásí stav a jakým tónem se komunikuje ven.

**Typ** říká, jaký tvar má práce uvnitř. Vícekrokový průvodce procesem, doménový asistent
po ruce, ohraničené zadání s koncem, mini-produkt jako trvalý artefakt, nebo automat, který
běží bez člověka u toho. Typ **neřídí nic**. Je to štítek pro člověka, který se dívá na
portfolio, a validátor jednotky je vůči němu slepý.

Ta asymetrie je celý smysl obou polí a je vykoupená jednou opravenou chybou. Dřívější model
bral kategorii projektu jako architektonický rozdíl: zákaznická práce byla vlastní vrstva
s vlastním postupem, osobní jiná. Vzniklo tím škatulkování v abstrakci, které provoz
nepotřeboval, a hlavně druhá doktrína, která se od první rozchází po detailech, o kterých
nikdo nerozhodl. Oprava zněla: jeden mechanismus, kategorie jsou metadata nad ním. Proto se
u typu drží pravidlo natvrdo - jakmile typ začne větvit chování, je to zpátky fork, jen
pojmenovaný jinak.

Hranice mezi typy jsou neostré a je to řečené nahlas, protože právě to chrání před
fragmentací. Typy nejsou body na jedné ose; každý rozlišuje víc věcí naráz (jestli to má
konec, kde stojí člověk vůči běhu, jestli vzniká trvalý artefakt). U štítku je to v pořádku,
ale kdyby se hledala ta jedna správná osa, skončí to pěti doktrínami. Když sedí víc typů
naráz, rozhoduje pevné pořadí - automat, projekt, mini-produkt, průvodce, asistent - a
vyhrává první, který sedí. Typ se navíc smí za života jednotky změnit: ohraničené zadání se
po dodání stává mini-produktem, který se udržuje.

Dvě pojistky, protože obojí se plete. Asistent není agent: je to plná jednotka s vlastním
adresářem a vlastním orchestrátorem, ne jeden soubor s definicí role. A automat je typ
jednotky, ne složka s evidencí mechanismů.

Které jednotky jsou v portfoliu a jak jsou klasifikované, tady nenajdeš. To je výskyt, ne
mechanismus. Páteř platformy jménem a byznysovou vrstvu kategoriemi popisuje
[`mapa-projektu.md`](mapa-projektu.md); jmenný seznam zákazníků a rozsah portfolia
z balíčku nejdou.

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

### Nadstavba má povinný tvar a ten tvar je celá její bezpečnost

- **Vlastní jméno se suffixem prostředí.** Nikdy stejné jako kanonická definice; stínění je
  zakázané a hlídá ho validátor jednotky.
- **Ukazatel místo kopie.** Tělo začíná instrukcí načíst kanonickou definici a teprve pak
  aplikovat rozdíl. Nadstavba neopakuje personu, metodiku ani normy; je v ní jen delta,
  cílově do několika desítek řádků.
- **Kompletní výčet nástrojů v hlavičce.** Jediná povolená duplikace a technická nutnost,
  protože hlavičky se neslučují. Výsledná sada smí být užší i širší než kanonická -
  oprávnění jsou vlastnost prostředí, ne role.
- **Čerstvost z konstrukce.** Nadstavba čte kanonickou definici při spuštění, takže se
  vylepšení propíše okamžitě. Není co synchronizovat, takže není co rozejít.

**Strop jsou dvě vrstvy.** Kanonická plus nanejvýš jedna nadstavba, nikdy řetěz. Potřeba
třetí vrstvy není problém k vyřešení další nadstavbou, je to signál špatné granularity: buď
to patří do kanonické definice, nebo je to jiná role.

### Kdy je to nadstavba a kdy fork, který se rozejde

Tohle rozhodnutí uděláš sám a nikdo u toho nestojí, tak ať je aspoň rozhodnutelné. Tři
otázky:

1. **Přidávám, nebo přepisuji?** Nadstavba přidává - konektor do systému, který existuje jen
   tady, doménový slovník, lokální pravidlo. Když sahám na personu, na hranice domény nebo
   na metodiku, není to lokální odchylka, je to nesouhlas s kanonickou definicí. Ten se řeší
   v ní, ne vedle ní.
2. **Platí to jen tady, nebo je to obecné zlepšení?** Zlepšení schované v nadstavbě je
   nejhorší z možností: dostane ho jedno prostředí, ostatní ne a nikdo se o něm nedozví.
   Kanonická definice je jediné místo, kde se role rozvíjí.
3. **Přežije to upgrade kanonické vrstvy?** Delta počítá s tím, že text pod ní se bude
   měnit. Když by si po upgradu s kanonickou definicí odporovala, není to delta, je to jiná
   role.

Praktický práh je délka. Když delta roste a začne opakovat věty, které stojí i v kanonické
definici, přestala být deltou dřív, než sis toho všiml - a ta zopakovaná pasáž je přesně to
místo, které se rozejde první.

**Proč je kopie pod stejným jménem tak lákavá.** Protože je nejlevnější. Soubor máš před
sebou, zkrátíš ho na to, co zrovna potřebuješ, a funguje to hned. Nevidíš, co jsi ztratil:
kopie přestala dostávat vylepšení a nic o tom neřekne, protože zkrácená definice neselže,
jen umí míň. U jednoho nasazení jsme takhle měli lokální definici o pětatřiceti řádcích,
která stínila plnotučnou kanonickou, vedle ní druhou zkrácenou kopii, model zapsaný mimo
konvenci a nulové odkazy na normy. Nic z toho nespadlo. A byl to přesně ten kanál, kterým
jedna norma nedorazila do jednotky, která ji potřebovala: kopie se odpojí tiše a upgrade už
nikdy nedostane.

## Render: jak se sada dostane na stroj, který nespravujeme

Nadstavba stojí na tom, že kanonická definice je na stroji po ruce. Mimo naše prostředí to
neplatí a instalace knihovny tam nepřipadá v úvahu ze dvou důvodů naráz: vystavila by osobní
vrstvu držitele účtu i celou metodiku. Ukazatel na soubor, který na cílovém stroji
neexistuje, je ale k ničemu. Odtud třetí mechanismus.

**Render je sestavení, ne kopie.** Z kanonické definice a případné delty vyrobí pro
konkrétní prostředí artefakt, který stojí sám o sobě. Čtyři vlastnosti, všechny povinné: je
evidovaný v manifestu renderu (jiný soubor než manifest šablony, o kterém je řeč níž); je
vyloučený z verzování v repozitáři příjemce, protože naše metodika nemá končit v cizím
gitu; nemá v sobě ukazatel, protože na cílovém stroji není na co ukazovat; a **nikdy se
needituje rukou** - změna jde do kanonické definice nebo do delty a artefakt se sestaví
znovu.

**Sankcionované stejné jméno.** Tady render naráží na zákaz stínění: artefakt musí nést
běžné jméno role, protože se na něj odkazuje katalog i spouštěč. Rozřešení je v tom, co ten
zákaz vlastně chrání. Zakázaný je ručně udržovaný fork, protože se rozejde. Artefakt renderu
je jiná třída: výstup sestavení, u kterého je drift vyloučený konstrukcí, protože příští běh
soubor přepíše. Validátor proto třídí soubory podle manifestu, ne podle shody jmen.

| Třída souboru v `.claude/agents/` | Poznávací znak | Co pro ni platí |
|---|---|---|
| Artefakt renderu | je v manifestu renderu | čtyři vlastnosti výše; stejné jméno povolené |
| Zdroj nadstavby | tvar `<kanonická>-<suffix>`, kanonická existuje | ukazatel, delta, kompletní výčet nástrojů |
| Role jen pro toto prostředí | jméno bez kanonického protějšku | ukazatel se nevyžaduje, kontroluje se hlavička |
| Ruční fork | koliduje s kanonickou a v manifestu není | zakázáno, validátor to hlásí jako chybu |

Na té tabulce je nejcennější poznámka o síle testu. Původní kontrola porovnávala jména
s knihovnou, takže byla nejpřísnější na stroji, kde knihovna je, a na cílovém stroji, kde
o to jde nejvíc, procházela naprázdno. Identita odvozená z manifestu na přítomnosti knihovny
nezávisí.

**Oprávnění patří prostředí, ne roli.** Část rolí se renderuje bez jakékoli delty, protože
nemá nic lokálního - a tím neměla kde vyjádřit, že v cizím prostředí smí míň. Renderovala se
s kanonickou sadou nástrojů psanou pro naše prostředí a jednou tím na cizím stroji rozšířila
práva role nad schválenou hranici. Proto oprávnění žijí v konfiguraci renderu pro dané
prostředí a aplikují se na všechny třídy. Kanonická definice tím zůstane bez forku a pravidlo
se propíše do hlavičky artefaktu.

Autorita je přitom na straně seznamu povoleného, ne zakázaného, a je fail-closed: co v něm
není, do artefaktu nejde, i kdyby to nikdo nezakázal. Oba doložené případy téhle třídy, co
stály a proč platí, že udržovaný má být ten seznam, jehož zastarání selže fail-closed, jsou
rozepsané v [`casy/02-vycet-zakazaneho-je-o-krok-pozadu.md`](casy/02-vycet-zakazaneho-je-o-krok-pozadu.md).
Sem to nepíšu podruhé.

Poslední detail, na který se přijde až v provozu: zápisy artefaktů čekají ve frontě, dokud
neprojdou všechny role. Půlka nasazené sady je horší stav než žádná.

Konfigurace konkrétního nasazení - manifest, seznam povolených nástrojů, šablona prostředí -
v balíčku není. Popsaný je mechanismus, spustitelný tu není; důvod je
v [`hranice-baliku.md`](hranice-baliku.md).

## Architektonická rozhodnutí

Platforma má třináct architektonických rozhodnutí. Jedenáct z nich tvaruje vrstvy, knihovnu
a práci uvnitř nich a jsou v tabulce. Dvě zbývající řeší vlastnictví dat v zákaznickém
vztahu a dělbu jedné zakázky na víc jednotek; obojí se dá poctivě vysvětlit jen na
konkrétním případu a ten ven nejde (viz [`hranice-baliku.md`](hranice-baliku.md)).

| # | Rozhodnutí | Jednou větou |
|---|---|---|
| AR-01 | Knihovna je výchozí domov role | Role vzniká rovnou v knihovně a je dostupná všem jednotkám; lokální role je výjimka, ne výchozí stav. Stack roste s lifecyklem: audit, hodnocení, návrh na vyřazení. |
| AR-02 | Jeden zdroj pravdy pro definice rolí | Definice žije v knihovně; ručně psaný duplikát v projektu neexistuje, odvozený katalog se generuje. |
| AR-03 | `operations/` jako povinná vrstva jednotky | Bez stavu, backlogu, rozhodnutí a runbooků není jednotka provoz, ale sklad dokumentů. |
| AR-04 | `strategic/` jako volitelná vrstva | Strategická práce má vlastní místo, ale jen tam, kde se dělá; prázdná kostra je vycpávka. |
| AR-05 | Čtyři vrstvy podle správy | Tabulka nahoře. Fyzická lokace je organizační konvence, ne architektonický rozdíl; klasifikace a typ jednotky jsou metadata nad jedním mechanismem, ne kategorie v architektuře. |
| AR-06 | Víc úrovní orchestrace, jeden vstupní bod | Člověk mluví s jedním orchestrátorem; ten zakládá jednotky a předává je jejich vlastním orchestrátorům. Paralelní provoz bez kolize kontextů. |
| AR-07 | Repozitář je pracovní paměť, znalostní báze dlouhodobá | Rozpracované žije v repu, vydané a trvalé ve znalostní bázi. |
| AR-08 | Dva typy obsahu, dva zdroje pravdy | Implementační obsah (definice, skills, normy, kód) má zdroj pravdy na disku a je verzovaný gitem. Živý obsah firmy má zdroj pravdy ve znalostní bázi a do gitu nepatří. |
| AR-09 | Tenant jako vlastní vrstva | Každý celek, pro který se pracuje, má vlastní tenantní projekt a jednoho orchestrátora: jedna kanonická definice plus tenantní kontext, žádný fork role per tenant. |
| AR-12 | Vrstvení definic a distribuce ven | Kanonická definice plus nanejvýš jedna nadstavba; řetězení je signál špatné granularity. Na stroj mimo naše prostředí se sada dostane renderem, ne instalací knihovny. |
| AR-13 | Propagace změn | Changeset, evidence převzetí, brána. Detail níž. |

AR-07 a AR-08 jsou dvě kolmé osy jednoho rozhodování: kam který obsah patří. Rozepsané jsou
i se zavedenou podobou PARA a se čtyřmi místy, kde to dnes drhne,
v [`datove-vrstvy.md`](datove-vrstvy.md).

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
| Motor | render definic a kopie šablon | vydání s tagem a řízená instalace |
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
