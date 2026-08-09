# Mapa verzí

Čísel je víc než jedno a je to správně: **různé věci se mění různě rychle a mají různé
konzumenty.** Verze softwaru, který někomu běží, se nesmí hýbat jen proto, že jsme upravili
definici role. Špatně je jenom to, když nikde není napsané, které číslo je které.

Tenhle dokument je ta jedna stránka. Odpovídá na čtyři otázky: **jaká čísla existují, co
znamenají, kam se propisují a kam se vědomě nepropisují.**

**Co z mapy uvidíš v tomhle balíčku.** Osa platformy je tu celá, protože její zdroj
i evidence jsou přiložené a příkazy níž se dají spustit. Osa vydávaného softwaru a osa
vlastních nástrojů bydlí v repozitářích, které v balíčku nejsou; jsou tu popsané jednou
větou, ať nehledáš, co tu není.

## Proč tu skoro nejsou čísla

Mapa odpovídá na otázku **kde číslo bydlí a jak se šíří**, ne na otázku **jaké to číslo je**.
To druhé zestárne vždycky: tenhle dokument vznikl 7. srpna 2026 a devátého tvrdil o platformě
číslo o tři vydání pozadu, protože ho tam jeho vlastní autor napsal rukou. Druhý domov čísla
driftuje i uvnitř dokumentu, který před druhými domovy čísel varuje.

Proto tady místo dnešní hodnoty stojí **cesta ke zdroji a příkaz, kterým si ji přečteš**.
Dvě výjimky, obě poznáš na první pohled:

- **Historické číslo a horizont** (co kdysi platilo, kdy se něco odstraní) se píše
  **s `v`**: `v2.0.0`. Je to doklad, ne živý údaj, a nezastará.
- **Datované měření** je označené datem v téže větě. Záznam okamžiku se opravuje novým
  měřením, ne přepsáním starého.

Živé číslo psané rukou v tomhle dokumentu být nesmí a hlídá to samostatná kontrola
platformního validátoru. Podrobněji v [`casy/05-cislo-verze-psane-rukou.md`](casy/05-cislo-verze-psane-rukou.md).

## Čtyři slova, která tu používám

- **Jednotka** - jeden projekt s vlastním `CLAUDE.md` a složkou `operations/`. Příklad máš
  v balíčku jako `ukazka-jednotky/`.
- **Osa** - jedna nezávislá řada čísel s vlastním zdrojem, vlastním způsobem šíření
  a vlastním publikem. Osy se nesmějí slít; kdyby se slily, nedá se odpovědět ani na jednu
  otázku.
- **Changeset** - lístek k jedné změně platformy: co se změnilo, koho se to týká, co s tím
  má příjemce udělat a jak se pozná, že to udělal.
- **Baseline** - evidence jedné jednotky o tom, které changesety už převzala a na jakém
  čísle stojí. Zapisuje do ní výhradně nástroj, a jen po průchodu testem.

## Přehled na jednu obrazovku

| Osa | Co číslo měří | Zdroj pravdy | Evidence u příjemce | Kdo se dívá |
|---|---|---|---|---|
| **A - platforma** | způsob práce: normy, definice rolí, šablony, engine | `scaffold/VERSION` | `<jednotka>/operations/platform-baseline.md` | orchestrátoři jednotek |
| **B - vydávaný software** | které vydání někomu reálně běží | `VERSION` v repu toho softwaru a tag `v<číslo>` | evidence instalace u té instance | uživatel v hlavičce aplikace |
| **C - vlastní nástroje** | jeden nástroj se samostatnou řadou | `VERSION` v kořeni jeho repa a tag | žádná, konzument je zároveň vlastník repa | autor nástroje |
| **D - schémata dat** | tvar souboru, na který se něco spoléhá | pole `schema` uvnitř souboru | tentýž soubor | čtečky, ne lidi |

Osy B a C v balíčku nejsou, protože v něm nejsou repozitáře, kterým patří.

## Dvě čísla v tomhle balíčku

V kořeni je `VERSION` a ve `scaffold/` je další. **Nejsou to dva domovy jednoho čísla, jsou
to dvě osy:**

- `VERSION` v kořeni je verze **tohohle balíčku**. Mění se, když se změní balíček.
- `scaffold/VERSION` je otisk **platformy**, ze které je balíček vyříznutý. Validátor ho
  čte a bez něj neběží.

Dědit jedno z druhého by rozbilo tři věci naráz: číslo balíčku by se muselo hýbat pokaždé,
když se hne platforma, i kdyby se v balíčku nezměnilo nic; shodné číslo by tvrdilo shodný
obsah, přičemž balíček je výběr s přepsanými větami; a oprava překlepu v balíčku by vyrobila
číslo, které se srazí s příštím vydáním platformy.

## Jak si dnešní čísla přečteš

```
# osa A - kde je platforma, ze které je balíček vyříznutý
cat scaffold/VERSION

# osa A - co jednotka převzala a jestli je pozadu
bash scaffold/validate.sh --baseline ukazka-jednotky --line

# verze tohohle balíčku
cat VERSION

# osa D - která datová schémata jsou v provozu; pouští se v repozitáři platformy,
# tady vrátí prázdno, protože soubory s deklarací schématu v balíčku nejsou
grep -rhoE '"schema"[[:space:]]*:[[:space:]]*"[^"]+"' . | sort -u
```

Poslední příkaz vypíše i formátovací řetězce, které schéma nejsou. Pořád je to levnější než
seznam schémat psaný rukou: ten v původní podobě tohohle dokumentu byl a chybělo v něm šest
schémat, která mezitím vznikla. V balíčku vrátí prázdno a je to správný výsledek - ta osa tu
nemá nad čím měřit, stejně jako platformní validátor.

## Osa A - platforma

**Co to číslo znamená:** kde je způsob práce. Zvedne se, když se změní norma, definice role,
šablona jednotky nebo nástroj platformy. Neříká nic o tom, co u koho běží; to říká baseline.

**Kdy se hýbe:** MINOR při změně tvaru engine souborů nebo kontraktu validátoru, PATCH
u obsahových změn. MAJOR by znamenal rozbití kontraktu jednotek, tedy poslední možnost.
Číslo se nikdy nezvedá samostatně, vždycky jde s changesetem - číslo bez lístku nikomu nic
neřekne a nikdo podle něj nic neudělá.

**Kam se propisuje:**

| Kam | Co tam stojí | Kdo to tam zapíše |
|---|---|---|
| `scaffold/manifest.json`, pole `scaffold_version` | totéž číslo | člověk; shodu obou míst hlídá kontrola platformního validátoru |
| `<jednotka>/operations/platform-baseline.md`, pole `**Platforma:**` | číslo v okamžiku posledního převzetí | `validate.sh --baseline --accept`, jen po průchodu testem |
| lidský rozcestník po platformě | dnešní číslo | generátor indexu |

Kromě prvního řádku je všude **nástroj**, ne ruka. Je to záměr: ruční synchronizace čísla ve
třech souborech selže při prvním spěchu.

**Pozor na dvě čísla, která se pletou.** `**Platforma:**` v baseline jednotky je **co
jednotka převzala**. `platforma_meta` ve strojovém výpisu je **kde platforma je teď**. Rozdíl
mezi nimi sám o sobě neznamená žádnou práci; typicky nastane, když se od posledního převzetí
vydaly jen changesety, které se téhle jednotky netýkají. Jestli má jednotka co dělat, se
pozná podle `stav=pozadu` a `lag`, ne podle rozdílu čísel.

## Osy B, C a D jednou větou

**Osa B** se šíří vydáním: kontrola tvaru čísla, čistý strom, neexistence tagu, pak vznikne
tag. Instalace se aktualizuje na tag, ne na hlavu větve; vydaný tag se nepřepisuje, oprava
vydání je nové vydání. Že je instalace pozadu za vydáním, je normální stav, ne poplach -
převzetí je klik uživatele, ne tichá aktualizace.

**Osa C** patří nástroji, který má vlastní životní cyklus a vlastního uživatele. Číslo drží
`VERSION` v kořeni jeho repa a ven se nepropisuje nikam, protože se nikam nedistribuuje.
Pravidlo, které u téhle osy stálo za nedorozumění: **dokud k číslu neexistuje tag, není to
vydání, je to záměr.** Zpětné tagování je přepisování historie a stojí víc než jedno
přeskočené číslo.

**Osa D** je tvar souboru, na který se něco spoléhá. Mění se **skokem celého jména**, ne
desetinným místem (`neco/v2` na `v3`), a autoritativní hodnota je vždy pole `schema`
v samotném souboru. Přechod na vyšší schéma se dělá dvoufázově: nejdřív čtečka umí obě
podoby, teprve o vydání dál se přestane číst ta stará. Nikdy obojí naráz.

## Kam se čísla vědomě nepropisují

Tahle půlka je stejně důležitá jako ta předchozí. Bez ní se za měsíc do každého souboru
dopíše číslo v dobré víře a systém začne lhát na deseti místech naráz.

| Číslo | Kam se vědomě nepropisuje | Proč |
|---|---|---|
| Osa A | do kořene jednotky | Kopie vzniká při založení a dál se neaktualizuje. Ve všech třech jednotkách, kde ten soubor byl, zamrzl na `v2.0.0`, zatímco platforma byla dál. Druhý domov čísla driftuje vždycky. |
| Osa A | k uživateli vydávaného softwaru | Uživatele nezajímá verze našeho způsobu práce, zajímá ho verze nástroje, který spustil. Číslo bez adresáta je šum a šum se přestane číst. |
| Osa A | do prózy manuálů **a do téhle mapy** | Číslo napsané rukou do věty zastará první změnou a nikdo si toho nevšimne. Kde je v dokumentaci potřeba, píše ho generátor; jinde stojí cesta ke zdroji a příkaz. |
| Osa B | do baseline jednotky | Tam je evidence osy A. Jedna evidence odpovídající na dvě otázky neodpoví spolehlivě ani na jednu. |
| Osa B | do verze platformy | Aktualizace software nemění nic na tom, co jednotka převzala z platformy. Dvě různé změny, dvě různé fronty, dvě různá tlačítka. |
| Osa C | kamkoli mimo vlastní repo | Takový nástroj se nedistribuuje. Číslo má jediného konzumenta, hlavičku vlastního rozhraní. |
| Osa D | do semver kterékoli osy | Kdyby verze schématu byla v semver, každá aditivní změna tvaru souboru by vypadala jako změna produktu a MINOR by přestal být bezpečný. |
| Cokoli | počet commitů jako míra zpoždění | „Pozadu o 47 commitů" je šum, po kterém nikdo nic neudělá. „Pozadu o 2 changesety" je věta, po které někdo něco udělá. |

## Soubory jménem VERSION, které nejsou tím, čím vypadají

Několik různých souborů se jmenuje stejně a znamená různé věci. Tohle je ta past.

| Cesta | Co to opravdu je | Kdo do něj píše |
|---|---|---|
| `scaffold/VERSION` | osa A, jediný zdroj pravdy | role pro vydávání, vždy s changesetem |
| `<repo software>/VERSION` | osa B, jediný zdroj pravdy | táž role, vydáním |
| `<instalace>/VERSION` | kopie osy B, kterou přinesla instalace | nástroj, který instaluje; ručně se nesahá |
| `<projekt>/VERSION` u vlastního nástroje | osa C, vlastní řada toho nástroje | autor nástroje vydáním; číslo bez tagu není vydání |
| `<jednotka>/VERSION` | zamrzlá kopie osy A z doby založení | nikdo, proto driftovala; zrušeno, verzi jednotky drží baseline |

Jedna kolize jmen, kterou je poctivé pojmenovat: **stejné jméno pole znamená ve dvou různých
souborech dvě různé osy.** Přejmenovat se to dá jen aditivně a v rámci vydání, které to
potřebuje; do té doby platí, že rozhoduje soubor, ne jméno klíče.

## Jeden příkaz na otázku „jsme pozadu?"

```
bash scaffold/validate.sh --baseline <cesta k jednotce> --line
```

Vypíše jeden řádek, kde `lag` je počet nepřevzatých changesetů, `platforma` číslo v baseline
a `platforma_meta` číslo v platformě. Bez `--line` vypíše i frontu s lidskou větou u každé
položky. Orchestrátor jednotky ho spouští na startu session per OR-12.

Ten řádek je **kontrakt**, ne jen výpis: je vždycky první na výstupu, pole se čtou podle
klíče a ne podle pozice, a hlídá ho vlastní test (`scaffold/tests/strojovy-radek.sh`).
Kanonický popis včetně návratových kódů drží
[`operations/changesets/README.md`](../operations/changesets/README.md).

## Co nesedí, měřeno 9. srpna 2026

Poctivý výčet je součást mapy, ne příloha. Je to datovaný snímek: každý řádek má vedle sebe
způsob, jak si ho přeměřit, aby se nedalo spolehnout na text, který mezitím zestárl.

| Nesoulad | Stav | Jak si to přeměříš |
|---|---|---|
| Totéž jméno pole znamená ve dvou souborech dvě různé osy | pojmenováno výš; přejmenování jen aditivně a s vydáním, které to potřebuje | otevřít oba soubory a porovnat, co pole popisuje |
| V dokumentaci jednoho z vlastních nástrojů žije druhý domov téhož faktu (tabulka o třech číslech a třech domovech) | po dohodě se nahradí odkazem sem; cizí jednotka, patří to do její session | otevřít ten dokument |
| Instalace software u příjemce bývá pozadu za vydáním | pull model, převzetí je uživatelské kliknutí; poplach je až regrese nebo dlouhé stání | porovnat číslo zdroje a číslo instalace |

Uzavřené od minula, ať je vidět, že se výčet zkracuje: kořenové soubory s číslem ve třech
jednotkách jsou pryč a nástroj, o kterém tenhle dokument tvrdil, že nemá tag, ho mezitím má.
