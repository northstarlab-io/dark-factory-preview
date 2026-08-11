# Koncept: dotažení samoučících, samoléčících a samoaktualizačních smyček do autonomního provozu

> Tohle je návrhový koncept - popisuje směr, kterým se platforma chce vydat, ne hotovou věc ani závazek. Datum: 11. srpna 2026.

**Stav dokumentu:** koncept po technické oponentuře, čeká na rozhodnutí vlastníka platformy.
**Čtenář:** technický peer, který si staví vlastní systém a posuzuje kvalitu návrhu.
**Vztah ke zbytku dokumentace:** co běží dnes, popisuje [`uceni-a-zavedeni.md`](uceni-a-zavedeni.md)
a [`hranice-baliku.md`](hranice-baliku.md); tenhle dokument navazuje a navrhuje tři cesty dál.
Doporučení na konci je názor autora; rozhodnutí je vlastníka platformy a zatím nepadlo.
V dokumentaci proto stojí v nejspodnějším patře, vedle případů a incidentů, a do big picture
nahoře schválně nezasahuje: popisuje záměr, ne stav. Čti ho až po tom, co víš, co běží.

## Rozsah a necíle

Koncept řeší tři osy: jak se z poznatku z práce stane pravidlo nebo znalost (self-learning),
jak se vadný výstup nebo stav detekuje a opraví (self-healing) a jak se změna dostane ke
konzumentům a jak se pozná drift (self-update).

Necíle, aby se o nich nemuselo dohadovat později:

- **Odstranit člověka z cyklu není cíl.** Hrdlem systému je rozhodovací fronta jednoho člověka,
  ne výkon agentů; cílem je zvýšit propustnost a kvalitu té fronty, ne její existenci.
- **Fine-tuning a trénink vlastního modelu nejsou na stole.** U iterativního převodu zkušenosti
  do parametrů je doložená postupná degradace místo sčítání zlepšení („progressive capability
  collapse rather than compounding improvement", arXiv 2606.04703); kontextová větev je
  levnější, vratná a lépe prozkoumaná.
- **Vektorová databáze ani grafová paměť se nezavádí.** Korpus je malý dost na strukturní
  dohledání; benchmarková čísla paměťových platforem si napříč zdroji odporují o desítky
  procentních bodů, takže ani nejsou rozhodovací vstup.
- **Autonomie se neměří procentem.** „Systém je z 60 % autonomní" neznamená nic. Autonomie je
  výčet tříd zásahu, které běží bez člověka, a ten výčet je v sekci 2.

## 1. Výchozí stav

Podklad je inventura celé platformy z 11. srpna 2026, měřená z disku a z gitu, ne z paměti.
Metodická zásada: **důkaz běhu, ne popis funkce.** Runbook s kadencí není důkaz, že revize
proběhla; log se třemi záznamy z jednoho měsíce je důkaz, že se kanál zastavil.

Inventura našla 32 mechanismů. U každého jeden z pěti stavů: funguje (doložená data nebo zásah
v posledních 30 dnech), zavedený ale zastavený, zavedený s nedoložitelným během (nezanechává
stopu, takže „neběžel" nejde odlišit od „běžel"), připravený ale neaktivní, jen návrh:

| Osa | Celkem | Funguje | Zastavený | Nedoložitelný | Připravený | Jen návrh |
|---|---|---|---|---|---|---|
| Self-learning | 10 | 2 | 4 | 0 | 2 | 2 |
| Self-healing | 10 | 7 | 1 | 0 | 2 | 0 |
| Self-update | 12 | 10 | 0 | 1 | 0 | 1 |

Čísla v téhle sekci jsou změřená (soubor, datum, počet záznamů); co je dál v textu odhad nebo
domněnka, je tak označené.

### Nález, který drží celý koncept

Hranici mezi fungujícím a mrtvým netvoří důležitost, stáří ani rozpočet. Vede jinudy: každý
mechanismus postavený jako odložený rituál - někdo si má po dokončení práce vzpomenout a
napsat řádek - je dnes zastavený, připravený nebo jen návrh, deset z deseti. Drtivá většina
fungujících má naopak strojového aktéra: skript, bránu, generátor nebo git hook, který
zapisuje sám.

Lákavá redukce zní „přežije jen to, co zapisuje stroj". Vlastní měření ji vyvrací a je fér to
napsat: mezi fungujícími jsou i mechanismy, jejichž aktérem je člověk nebo instrukce -
korekční paměť hlavní pracovní session, ověření integrity hned po strukturní operaci,
propagační triage při změně role. Spojuje je jiná vlastnost než strojovost: **běží uvnitř
momentu práce a mají okamžitého konzumenta.** Korekce padne přímo v rozhovoru, ověření
následuje bezprostředně po operaci, triage je součást téže akce. Není tu žádné okno mezi
prací a mechanismem, ve kterém by se dalo zapomenout.

Testovatelná věta, na které koncept stojí, proto zní: **v téhle platformě přežije mechanismus,
jehož nesplnění něco zastaví nebo něco spočítá, nebo který běží uvnitř momentu práce; umírá
rituál odložený na potom.**

### Osa učení: postavená celá, zastavená skoro celá

Řetěz od poznatku k pravidlu má čtyři stupně (sběr, agregace, lidská brána, zápis) a všechny
existují jako artefakt: retro skill ([`../knihovna/skills/agent-retro/SKILL.md`](../knihovna/skills/agent-retro/SKILL.md)),
týdenní předfiltr ([`../knihovna/skills/methodology-promote/SKILL.md`](../knihovna/skills/methodology-promote/SKILL.md)),
rozhodnutí člověka, zápis jinou rolí. Doložený průchod: retro reporty vznikly tři za celou
historii, všechny na jedné roli, poslední 31. května 2026 - na retro skill neodkazuje ani jedna
z 24 definic rolí, takže mechanismus nemá nositele ve vrstvě, která se roli při práci načte.
Týdenní fronta kandidátů se naplnila jednou, pěti kandidáty; žádný nedošel do cílového souboru
a grep potvrdil, že se nepropsali ani jinou cestou. Signální log člověka
([`../knihovna/foundation/quentin-signals.md`](../knihovna/foundation/quentin-signals.md)) se
zastavil na třech záznamech proti vlastnímu prahu osmi a instrukce „přečti ho na startu každé
session" v definicích orchestrátorů běží dál; platforma vypadá, že se učí, což je horší než
čistý konec. Katalog selhání roste po incidentech a ručně, ne mechanismem. Sběrné mechanismy
se přitom zaváděly jako dvoutýdenní experimenty s předepsaným závěrečným rozhodnutím
(pokračovat, upravit, zrušit) - ani jedno takové rozhodnutí nepadlo a experimenty formálně
běží dál, víc než tři měsíce po datu, kdy měly skončit.

Za tři měsíce tudy neprošel ani jeden poznatek. Lidská brána není problém: 15 minut týdně je
levné a vědomé. Problém je, že osa učení nemá ani jednu ze čtyř vlastností funkční osy
propagace: počitatelnou frontu, strojový test převzetí, bránu v okamžiku práce, automatické
spouštění.

### Osa léčení: strojová půlka funguje, úsudková stojí

Deterministická část běží a má doložené zásahy: validátory
([`../scaffold/validate.sh`](../scaffold/validate.sh),
[`../scaffold/validate-platform.sh`](../scaffold/validate-platform.sh)), git hooky, které je
spouštějí ([`../scaffold/hooks/`](../scaffold/hooks/)), sken přístupových údajů, brána na tvar
verifikačních bloků - poslední jmenovaná je nejrychlejší doložená učící smyčka platformy: tři
výskyty téže třídy chyby ve třech dnech se třetího dne proměnily v deterministickou bránu
u autora ([`casy/01-brana-kterou-nikdo-nespoustel.md`](casy/01-brana-kterou-nikdo-nespoustel.md),
oddíl „Totéž o tři dny později, jinou třídou"). Že ta brána hlídá tvar řádku a ne jeho smysl,
si do sebe napsal rovnou lístek, kterým vznikla
([`../operations/changesets/2026-08-09-brana-verify-bloku-a-kontrakt-radku.md`](../operations/changesets/2026-08-09-brana-verify-bloku-a-kontrakt-radku.md),
Poznámky) - a další výskyt téže třídy o den později přišel právě tudy.

Úsudková část stojí. Kontrola výstupu před předáním
([`../knihovna/skills/agent-output-check/SKILL.md`](../knihovna/skills/agent-output-check/SKILL.md))
má tři záznamy v logu oprav a nespočitatelnou míru léčení, protože se neeviduje jmenovatel
(počet posouzených výstupů). Revize čerstvosti znalostní báze má runbook, kadenci i vlastníka,
ale ani jeden doložený běh. A sebehlášení rolí o vlastní náročnosti je signál bez rozlišovací
schopnosti: v jednom běhu hlásilo „sedělo" všech 32 spuštění z 32
([`pripady-pouziti/03-reserse-ktera-skoncila-pravidlem.md`](pripady-pouziti/03-reserse-ktera-skoncila-pravidlem.md)).

### Osa aktualizace: hotové jádro, dvě jmenovité díry

Propagace změn je nejsilnější část platformy: adresovaná fronta lístků
([`../operations/changesets/`](../operations/changesets/)), evidence převzetí per jednotka
([`../ukazka-jednotky/operations/platform-baseline.md`](../ukazka-jednotky/operations/platform-baseline.md)),
strojový řádek se stavem fronty, index platformy pro změny, které se jen čtou, render s
manifestem pro distribuci mimo vlastní prostředí. Fronta se počítá sama (`lag=N`). Dvě doložené
díry brání říct „uzavřeno": otisk vyrenderovaného artefaktu se proti disku neporovnává, takže
ruční editace po instalaci se nedetekuje (přesně ta operace, kterou norma OR-09 zakazuje); a
startup check orchestrátora nezanechává stopu, takže se jeho dodržení nedá ověřit ani zpětně.

### Co v platformě není vůbec

Nula hooků Claude Code (oba fungující hooky, `pre-commit` a `commit-msg` ve
[`../scaffold/hooks/`](../scaffold/hooks/), jsou git hooky, jiná technologie na jiné
události), nula plánovaných rutin mezi sessions, nula regresních sad nad instrukčními artefakty
(změna definice role se nasazuje bez testu chování - testuje se tvar, nikdy účinek).

## 2. Cílový stav

### Definice autonomie: čtyři třídy zásahu podle vratnosti a detekovatelnosti

Návrhová otázka nezní „kolik autonomie", ale „které zásahy jsou vratné jedním příkazem - a u
kterých se selhání pozná strojově dřív, než napáchá škodu":

| Třída | Charakter zásahu | Kdo jedná | Příklad |
|---|---|---|---|
| 1 | Vratný jedním příkazem, selhání viditelné okamžitě, poloměr jedna jednotka | Stroj sám, loguje | Dorovnání hlavičky, regenerace indexu, razítko běhu |
| 2 | Vratný a strojově detekovatelný, poloměr platforma, mění referenční obsah | Stroj po stínové fázi, se stopou, revertem a detektorem selhání | Zápis ověřené poučky do paměti (varianta C) |
| 3 | Mění chování rolí: definice, normy, brány, skilly | Vždy člověk rozhoduje, jiná role zapisuje | Propsání poznatku do definice |
| 4 | Nevratný nebo v prostředí, které platforma nevlastní | Člověk spouští, agent připravuje | Zásah v repu či nástroji druhé strany |

Vratnost sama o sobě je špatná osa a platforma na to má vlastní důkaz: incident s odpojenými
databázemi ([`casy/03-odpojene-databaze.md`](casy/03-odpojene-databaze.md)) měl revert v řádu
jedné operace a detekci dva dny. U vadné poučky je poměr ještě horší - revert je jeden příkaz,
ale detekce vyžaduje, aby si někdo všiml jemně posunutého principu vloženého v momentě
rozhodnutí. Třída se proto určuje dvěma osami, vratností a detekovatelností. Konkrétně pro
třídu 2: strojový zápis je přípustný, jen když existují obě pojistky - (1) pojmenovaný
strojový detektor selhání právě tohohle druhu zápisu (kolize s existující poučkou, provenience
a citovaný externí signál, prošlá platnost) a (2) diffová plocha, kterou člověk reálně čte
(týdenní přehled nových a změněných pouček ve stávajícím slotu). Bez obojího položka patří do
třídy 3.

Cíl: co nejvíc provozu do tříd 1 a 2; třídy 3 a 4 zůstávají, jen s lepší přípravou rozhodnutí,
aby lidská fronta odbavovala rychleji a kvalitněji.

### Kde člověk zůstává vždy a proč

1. **Zápis do definic rolí a norem.** Norma OR-09 v [`normy.md`](normy.md): role nikdy
   nepřepisuje vlastní kontrakt. Důvod je auditovatelnost - kde si role upravuje vlastní
   pravidla, nejde odlišit záměr od nánosu. K tomu přibyl důvod z literatury: samoaktualizující
   se systém přidává ke známé rizikové trojici (přístup k datům, nedůvěryhodný vstup,
   komunikace ven) čtvrtý prvek - schopnost trvale změnit vlastní chování. Vsunutá instrukce
   pak nezpůsobí jednorázový únik, ale zapíše se do pravidla a působí dál. K téže zdi došly
   nezávisle čtyři týmy: neměnné jádro se snapshoty (Prime Agent), oddělení návrhu od zápisu
   (ACE, arXiv 2510.04618), kompilace zdroje do zamčeného artefaktu (GitHub Agentic Workflows),
   zadržená testovací sada (SpecBench). Čtyři nezávislé týmy a tatáž zeď: konstrukční nutnost.
2. **Validace učicího signálu.** Systém se nesmí učit z vlastního nevalidovaného výstupu.
   Poučka z běhu bez externího signálu o výsledku (prošlá nebo neprošlá brána, lidský verdikt,
   měřitelný důsledek) se nezapisuje nikam - ani do paměti. Opora: degenerace při rekurzivním
   učení z vlastní produkce (Nature 2024) a doložené obcházení bran, kterými je agent měřen.
3. **Nevratné zásahy a cizí prostředí.** Agent připravuje plán s výpisem změn, člověk spouští.
4. **Výstupy opouštějící systém.** Co jde ke druhé straně, prochází člověkem.

### Co znamená „hotovo" na každé ose

**Self-learning:** každý poznatek z kvalifikované práce má do týdne rozhodnutí (zapsat,
zahodit, odložit) a zapsaný má strojově ověřitelné převzetí - „propsáno" je měření, ne tvrzení;
většina poznatků míří do znalosti, do definic jde jen destilát přes lidskou bránu.
**Self-healing:** každá úsudková kontrola má evidovaný jmenovatel, takže spočitatelnou míru;
opravený výstup nese vlastní stav a nesplyne s „bylo to v pořádku". **Self-update:** dvě
jmenované díry uzavřené (otisk renderu, stopa startup checku); jinak beze změny - vzor, ne
pacient.

## 3. Varianty architektury

Tři skutečné volby, ne tři velikosti téhož. Liší se v kořenu problému: A říká „učení nemá
strojový pohon", B „učení nemá měřidlo", C „učení míří do špatného úložiště". Všechny
respektují čtyři hranice ze sekce 2.

### Varianta A: Poznatek jako lístek (evoluce doložené mechaniky)

**Princip.** Osa učení převezme čtyři konstrukční vlastnosti, které dělají funkční osu
propagace: adresovanou frontu, která se sama počítá; strojový test převzetí; bránu v okamžiku
práce; automatické spouštění. Poznatek putuje platformou jako changeset, jen opačným směrem.

**Technická podoba.**

- **Fronta poznatků per jednotka:** adresář lístků v `operations/`. Lístek nese druh (stav /
  znalost / pravidlo - tři různé brány zápisu), důkaz z běhu, návrh akce a stav. Formát zrcadlí
  changeset včetně verifikačního bloku pro krok „propsáno": schválený kandidát dostane grep
  test na cílový soubor, takže propsání je měřitelné stejně jako převzetí changesetu.
- **Brána učení v okamžiku commitu:** zrcadlo brány changesetů (OR-12 v [`normy.md`](normy.md)),
  jen opačným směrem. Commit, který sahá na cesty deliverables jednotky, nese trailer
  `Poznatek: <id>`, nebo evidovanou výjimku `Poznatek: none (<důvod>)`. Vynucuje to existující
  hook `commit-msg` - žádná nová technologie události, stejný instalátor, stejný vzor evidované
  výjimky, auditovatelné gitem; obejití přes `--no-verify` chytá zpětná kontrola při příštím
  běhu brány. Nenapsaný poznatek poprvé něco zastaví a výjimka je viditelná, ne tichá.
- **Zamítnutá podoba téže brány, ať se k ní nikdo nevrací omylem:** hook `Stop` s
  `decision: "block"`, který by nepustil session skončit bez zapsaného poznatku. Tři důvody
  zamítnutí. `Stop` se spouští po každém dokončeném tahu, ne na konci session, a událost konce
  session ukončení blokovat neumí. Blokace nutí model pokračovat a lístek si napsat sám o
  vlastní právě dokončené práci, což je přesně zápis bez externího signálu, který hranice 2 ze
  sekce 2 zakazuje - jen s vynuceným objemem. A u delegované práce se `Stop` automaticky
  převádí na `SubagentStop`, takže by brána padala na každé dokončení specialisty, ne na
  uzavření celku. Pošťouchnutí uvnitř session jde udělat neblokačně (hook smí vrátit dodatečný
  kontext do konverzace); tvrdá brána patří na commit.
- **Hook `SessionStart` (Claude Code):** vstřikne do kontextu stav obou front jako fakt
  doručený před prvním slovem orchestrátora a zapíše razítko běhu do `operations/` - což
  mimochodem uzavírá díru „běh nedoložitelný" ze sekce 1.
- **Podmínka jakéhokoli hooku Claude Code: tři pojistky, ne doprovod.** U hooků Claude Code
  neplatí ekvivalence s git hooky. Konfigurace se zvedá automaticky, jakmile je v souboru
  nastavení, a hook může přijít i z frontmatteru skillu nebo role, tedy z artefaktů, které se
  v platformě běžně editují. Je to perzistentní vykonávací plocha, kterou si role s právem
  zápisu umí otevřít sama. Pro git hooky má platforma tuhle třídu rizika ošetřenou (brána
  vykoná jen to, co je verzované v gitu, viz
  [`casy/01-brana-kterou-nikdo-nespoustel.md`](casy/01-brana-kterou-nikdo-nespoustel.md));
  pro hooky Claude Code ekvivalent nemá, protože jich dosud bylo nula - tenhle návrh tu plochu
  zapíná, a proto ji musí i uzavřít. První hook se zavádí až s: (1) fail-closed kontrolou
  platformní brány - konfigurace hooků kdekoli v měřené ploše musí odpovídat manifestu s
  otiskem obsahu, cokoli jiného je FAIL; (2) zákazem zápisu rolí do souborů nastavení a
  adresářů hooků - autorita na straně povoleného, ne výčtu zakázaného; (3) hranicí prostředí -
  hook jen v jednotkách, které platforma vlastní, nikdy v šabloně, nikdy ve vyrenderovaném
  artefaktu, nikdy v repu druhé strany, protože sdílený soubor nastavení by distribuoval
  spustitelný shell do cizího prostředí.
- **Čítač ve strojovém řádku:** vedle `lag=N` přibude počet nezpracovaných poznatků. Zastavení
  smyčky se projeví rostoucím číslem v přehledu portfolia, ne tichem.
- **Beze změny:** předfiltr, lidská brána 15 minut, zápis jinou rolí. Aktivaci hooků - git i
  Claude Code - provádí člověk explicitně.

**Akční člen:** commit brána, `SessionStart` hook a rozšířený validátor; u zápisu do definic
beze změny člověk. **Vratnost a vypínač:** odinstalace git hooků jedním příkazem, odebrání
hooku Claude Code jedním řádkem v nastavení; čítač konstantou ve validátoru. **Latence
smyčky:** capture v okamžiku commitu, rozhodnutí do týdne.

**Plusy.** Kopíruje jediný vzor, o kterém platforma naměřila, že u ní přežívá. Obrací polaritu
selhání: dnes je defaultem učení ticho, s čítačem a branou je defaultem viditelný dluh.
Nejrychlejší cesta k tomu, aby se zastavení smyčky poznalo dřív než za tři měsíce.

**Minusy a rizika.** Neříká nic o kvalitě poznatků - vynucený sběr umí vyrobit formální retra
psaná pro projití branou (tatáž třída jevu jako obcházení měřicích bran u agentů, jen
levnější). Commit brána se špatně zvolenými cestami obtěžuje u commitů, které kvalifikovaná
práce nejsou, a naučí autory psát `none` ze zvyku - podíl výjimek je proto metrika od prvního
dne, ne až od incidentu. Tři pojistky vykonávací plochy nejsou doprovod, ale reálný náklad
zavedení. A měří odbavení fronty, ne účinek: bez měřidla z varianty B nejde říct, jestli
propsaný poznatek pomohl.

**Náklady (odhad).** Zavedení: jednotky dní (rozšíření commit hooku, jeden `SessionStart`
hook, šablona lístku, rozšíření validátoru o manifest hooků a čítač). Provoz: tokeny
zanedbatelné, lidská brána beze změny.

**Co by muselo být pravda.** Že příčinou zastavení učení je chybějící spouštěč a počitatelnost,
ne nízká hodnota poznatků. Inventura tomu nasvědčuje (mechanismy umíraly na disciplíně, ne na
odmítnutých kandidátech), ale lidská brána zatím rozhodovala jedinou dávku, takže o hodnotě
kandidátů skoro nic nevíme - je to extrapolace z malého vzorku.

### Varianta B: Nejdřív měřidlo (evaluační harness jako podmínka autonomie)

**Princip.** Žádná automatizace zápisu bez měřicího aparátu. Nejdřív zlatá sada scénářů nad
instrukčními artefakty a regresní brána, pak teprve vyšší autonomie čehokoli, co zapisuje.
Opora je konvergentní nález literatury: reflexe bez externího signálu o úspěchu je reflexe
nad vlastním dojmem - bez evaluační sady není self-learning, je jen zápis.

**Technická podoba.**

- **Zlatá sada 20 až 30 scénářů** pro dvě až tři nejvytěžovanější role. Scénáře se neberou z
  hlavy: vzorek reálných běhů se ručně okóduje, kódy se sloučí do os selhání a četnosti určí,
  co se testuje. Část sady je zadržená - optimalizovaný systém ji nevidí.
- **Regresní běh:** skript spustí scénáře neinteraktivně (headless `claude -p` s definicí role
  a scénářem), výstupy posoudí soudce - levnější model s promptem mířeným na konkrétní osy
  selhání, ne „ohodnoť užitečnost 1 až 5". Práh shodí commit měnící definici nebo skill;
  mechanika brány stejná jako u validátoru platformy, jen dražší uvnitř.
- **Kalibrace soudce:** 30 až 50 lidských verdiktů jako kalibrační sada; fronta neshod soudce
  versus člověk kalibruje prompt soudce. Soudce, který nesouhlasí s expertem ve víc než pětině
  jednoznačných případů, se opravuje, nenasazuje. Bez toho se měří měřidlo.
- **Stínový režim pro každý další automatizační krok:** nový mechanismus běží vedle stávajícího,
  výstupy se porovnávají, nic se nepropisuje, dokud shoda s člověkem není naměřená.

**Akční člen:** regresní brána (stroj) a kurátor sady (člověk). **Vratnost a vypínač:** brána
konstantou; sada je soubor v gitu. **Latence smyčky:** při každé změně artefaktu, tedy dny.

**Plusy.** Řeší kořen, který A i C obcházejí: dnes se změna definice role nasazuje bez testu
chování, testuje se jen tvar. Jediná cesta, jak kdy poctivě zvýšit autonomii zápisu - a chytá i
regrese z lidských změn, kterých je dnes většina.

**Minusy a rizika.** Nejdražší start a jediná varianta s výrazným provozním nákladem: plný
regresní běh je desítky headless sessions, řádově stovky tisíc tokenů na hlídanou změnu
(odhad; závisí na délce scénářů). Latence commitu roste. Sada zastarává a zastaralá fail-closed
brána brzdí legitimní vývoj. Platforma na to má dvě vlastní poučky: výjimka z brány musí být
jmenovitá a evidovaná, protože posun kotvy promine celý rozsah před sebou; a brána, kterou se
vyplatí obejít kvůli délce, je horší než žádná
([`casy/01-brana-kterou-nikdo-nespoustel.md`](casy/01-brana-kterou-nikdo-nespoustel.md)).
Soudce ze stejné rodiny modelů má doloženou zaujatost ve prospěch vlastních výstupů (uvádí se
10 až 25 %), proto kalibrace není volitelná. A B sama nic nesbírá: měřidlo bez přítoku
poznatků měří prázdnou frontu.

**Náklady (odhad).** Zavedení: týdny na první sadu a harness, plus průběžná kurátorská práce
(hodiny měsíčně). Provoz: tokenově nejdražší varianta.

**Co by muselo být pravda.** Že největší reálné riziko je nezměřená regrese chování při
změnách definic a že kapacita na údržbu sady vydrží i po prvním nadšení. Druhé je přesně ten
typ disciplíny, na kterém se tu zastavilo 10 mechanismů z 10 - bez strojového hlídače (stáří
sady jako kontrola validátoru) zdegraduje B stejně jako sběrné experimenty ze sekce 1.

### Varianta C: Paměť místo pravidel (stabilní definice, učení ve znalosti)

**Princip.** Většina toho, co se z provozu dá naučit, nepatří do pravidel, ale do znalosti - a
platforma to nerozlišuje, takže každý poznatek míří do nejdražšího a nejpomalejšího kanálu
(definice za lidskou branou). C zavádí strukturovanou paměť mimo definice: definice zůstávají
malé a stabilní (neměnné jádro), poučky žijí ve vlastní knihovně s lehčí branou zápisu a
vkládají se v momentě rozhodnutí, ne globálně do hlavičky. Do definice se propisuje jen vzácný
destilát s opakovaně potvrzeným účinkem.

**Technická podoba.**

- **Knihovna pouček:** poučka je jeden Markdown soubor, řazený per doména. Formát podle
  nejlépe doložených implementací (ReasoningBank, ExpeL): titulek, jednořádkový popis, obsah
  na úrovni principu (ne přepis běhu), důkaz (odkaz na běh a externí signál) a bi-temporální
  platnost - kdy to platilo a kdy jsme se to dozvěděli. Nahrazená poučka se nemaže, označí se.
- **Oddělení reflexe od kurátorství:** role, která poučku destiluje, nemá právo zápisu;
  kurátorská role rozhoduje o zařazení proti dvěma podmínkám - poučka cituje externí signál
  (podmínka 2 ze sekce 2) a nekoliduje s existující poučkou bez vyznačení náhrady. Konstrukce
  proti dvěma selháním pojmenovaným v literatuře: tlaku na stručnost, který vyhazuje doménový
  detail, a erozi obsahu opakovaným přepisováním.
- **Vkládání v momentě rozhodnutí:** metadata pouček (titulky) jsou dostupná vždy, obsah se
  dotahuje při relevanci - trojstupňový vzor, jakým Claude Code odhaluje skilly. Retrieval je
  grep a struktura, žádná vektorová vrstva; vědomé omezení, dokud knihovna nepřeroste řádově
  stovky pouček.
- **Zánik jako default:** poučka bez potvrzeného použití má datum revize; kontrolu prošlých dat
  dělá validátor. Polarita selhání se obrací stejně, jako to platforma udělala u dočasných
  omezení ([`casy/04-omezeni-ktere-nezaniklo.md`](casy/04-omezeni-ktere-nezaniklo.md)).

**Akční člen:** kurátor; přechod na stroj až po stínové fázi a jen s oběma pojistkami třídy 2
(detektor selhání zápisu, čtená diffová plocha); validátor pro platnost. **Vratnost a
vypínač:** poučka je soubor, revert jeden příkaz; vypínač je zrušit odkaz na knihovnu ze
skillů. **Latence smyčky:** zápis dny, účinek při nejbližším relevantním rozhodnutí.

**Plusy.** Externě nejlépe podložená větev: principy místo trajektorií a vkládání v momentě
rozhodnutí mají oporu ve třech nezávislých pracích. Řeší skutečnou konstrukční vadu: jediný
fungující učicí kanál (paměť hlavní session) se nedědí do subagentů, takže poznatky nikdy
nevidí právě ty běhy, kterých se týkají; knihovna na disku tuhle díru uzavírá. Paměť je
referenční materiál, ne příkaz - cena chyby v poučce je řádově nižší než v definici, a právě
proto si třída 2 může dovolit vyšší autonomii zápisu než třída 3, pokud unese i její
podmínky detekovatelnosti.

**Minusy a rizika.** Hlavní riziko je mrtvá knihovna. Platforma už jednu má: katalog selhání
referencuje jediná definice z 24, přestože deklarovaný vzor zněl „každý ho při startu skenuje";
bez nositele čtení v načítané vrstvě dopadne knihovna pouček stejně. Druhé je otrava paměti:
poučka je perzistentní kontext, vsunutá instrukce, která projde kurátorem, působí dlouhodobě -
proto externí signál a lidský tok paměť → definice. Třetí je dvojí pravda: poučka a pravidlo si
mohou začít odporovat; řeší to kanonizační disciplína a kontrola kolizí, ale je to trvalá údržba.

**Náklady (odhad).** Zavedení: dny až týden (formát, kurátorský skill, kontrola platnosti,
nositel čtení). Provoz: levný - zápis mimo kritickou cestu, čtení stovky tokenů na dotažení.

**Co by muselo být pravda.** Že podstatná část hodnoty poznatků je znalost, ne pravidlo (dnes
neměřitelné, obojí se hrne do jednoho kanálu); že čtení v momentě rozhodnutí půjde udělat
strojově nesené, ne disciplinované; a že korpus zůstane malý dost na dohledání bez vektorů.

### Zvažované a odložené

**Proxy rozhodovací fronty** (zástupný agent s kalibrovaným profilem člověka, který přes noc
vydává verdikty za něj) se jako varianta nezařazuje. Verdikt proxy není mandát - jakmile na něj
systém zapíše změnu, je člověk vyřazen z okruhu, aniž cokoli schválil; proxy je soudce ze
stejné rodiny modelů se zaujatostí ve prospěch posuzovaných; a nejsilnější doložená práce o
simulaci jednotlivce drží přesnost na dvouhodinovém hloubkovém rozhovoru jako vstupu, tedy
řádově bohatším materiálu, než jaký je k dispozici. Použitelná je slabší forma: **příprava
rozhodnutí** - noční třídění fronty, spárování s precedentem, návrh verdiktu jako hypotézy s
odůvodněním; ráno se odbavuje připravené a rozhodují tři skutečné otázky. V doporučení je jako
pozdější krok; mandátová forma se zamítá celá.

**Parametrická cesta a paměťové platformy** jsou zamítnuté v necílech; zamítnutí je podložené
(kolaps při iteraci, rozporná benchmarková čísla), ne konzervativní. **Blokující hook `Stop`
jako brána učení** je zamítnutý uvnitř varianty A, s důvody přímo u návrhu, který nahradil.

## 4. Srovnání variant

| | A: Poznatek jako lístek | B: Nejdřív měřidlo | C: Paměť místo pravidel |
|---|---|---|---|
| Akční člen | Commit brána + `SessionStart` hook + validátor | Regresní brána + kurátor sady | Kurátor paměti + validátor platnosti |
| Vratnost zásahu | Úplná (odinstalace hooků) | Úplná (vypnutí brány) | Úplná (revert souboru) |
| Brána člověka | Beze změny (týdenní slot) | Při změně definic + kalibrace | Lehčí u paměti, plná u definic |
| Latence smyčky | Capture při commitu, rozhodnutí týden | Dny (per změna artefaktu) | Dny až první relevantní použití |
| Poloměr zásahu | Proces jednotek | Vývoj platformy (commity) | Referenční vrstva rolí |
| Jak se pozná selhání | Čítač fronty roste; podíl výjimek `none` roste; podíl schválených klesá | Fronta neshod soudce roste; evidované overridy | Poměr čtení k zápisům; poučky po platnosti |
| Auditovatelnost | Vysoká - lístek s testem, stejná evidence jako changesety | Vysoká; měřidlo samo vyžaduje kalibrační audit | Vysoká se stopou zdroje; hrozí dvojí pravda |
| Bezpečnost: persistence vsunuté instrukce | Zápis do pravidel zůstává za člověkem; nová plocha hooků krytá manifestem, zákazem zápisu rolí a hranicí prostředí | Nezvyšuje; zadržená sada chrání měřidlo | Zvyšuje plochu (perzistentní kontext) - kryto branou externího signálu a lidským tokem paměť → definice |
| Bezpečnost: učení z vlastního výstupu | Riziko formálních ret - kryto lidskou branou | Přímo proti němu (externí signál je podstata) | Kryto podmínkou externího signálu u zápisu |
| Cena zavedení (odhad) | Dny | Týdny | Dny až týden |
| Cena provozu (odhad) | Zanedbatelná | Nejvyšší (tokeny regresních běhů) | Nízká |
| Rychlost prvního přínosu | Dny (viditelnost zastavení) | Týdny až měsíce | Týdny (první použitá poučka) |
| Slučitelnost s normami a branami | Přímé rozšíření existující mechaniky | Nová třída brány, stejná filozofie fail-closed | Nová vrstva; vyžaduje kanonizační disciplínu |

## 5. Doporučení

Preferované kritérium doporučení je **slučitelnost s naměřenou hranicí přežití mechanismů**
(přežívá strojový aktér, počitatelnost a vazba na moment práce; umírá rituál odložený na
potom) **při zachování auditovatelnosti**. Podle jiného kritéria - třeba nejrychlejší
maximalizace kvality rozhodnutí - by pořadí vyšlo jinak, proto je pojmenované.

Doporučená je kombinace v tomhle pořadí, ne výběr jedné varianty:

1. **Krok 0: uzavřít, co se tváří živé.** Závěrečná rozhodnutí u zastavených sběrných
   experimentů, odstranění mrtvých instrukcí z definic, dorovnání evidence. Nestojí to skoro
   nic a bez toho každý další krok staví na nepravdivém obrazu. Fakt, že to je potřeba
   vyhlásit krokem, je sám o sobě výpověď o limitech disciplíny jako aktéru.
2. **Kostra varianty A** (dny): razítkující `SessionStart` hook - a před ním tři pojistky
   vykonávací plochy, které jsou jeho podmínkou - fronta poznatků s čítačem ve strojovém
   řádku, lístek se strukturou. Bez blokující commit brány: ta se přidá až podle naměřeného
   chování, protože podíl kvalifikované práce bez poznatku je zatím neznámé číslo a brána
   nastavená naslepo učí lidi psát výjimky. Zastavení učení se tím stane viditelným číslem,
   což je podmínka všeho dalšího.
3. **Formát a brána varianty C** (do týdne): knihovna pouček s bi-temporální platností,
   oddělený reflektor a kurátor, nositel čtení v načítané vrstvě. Poznatky druhu „znalost" z
   fronty kroku 2 tečou sem; do definic jde jen destilát přes stávající lidskou bránu.
4. **Minimální měřidlo z varianty B** (týdny, postupně): zlatá sada pro dvě nejvytěžovanější
   role, zprvu jen jako poradní běh po změně definice, ne blokující brána. Kalibrace soudce
   proti lidským verdiktům od prvního dne, stáří sady hlídá validátor.
5. **Teprve potom posun autonomie:** stínový kurátor paměti (stroj navrhuje zápisy, člověk
   potvrzuje, shoda se měří) a při naměřené shodě přesun zápisu pouček do třídy 2 - jen s
   oběma pojistkami té třídy, tedy detektorem selhání zápisu a diffovou plochou, kterou člověk
   čte. Autonomie zápisu do definic (třída 3) se neposouvá vůbec; posouvá se kvalita přípravy
   lidské fronty, případně noční příprava rozhodnutí ze Zvažovaného.

Každý krok má vypínač na jeden řádek (odinstalace hooku, konstanta, smazání odkazu) a zavádí se
zvlášť, aby se dal zvlášť i vrátit. Rozhodnutí o pořadí, rozsahu i o tom, jestli vůbec, je
vlastníka platformy.

## 6. Rizika a limity

Rozbor selhání dopředu - předstíráme, že je únor 2027 a nefunguje to. Nejpravděpodobnější
příčiny, u složitého systému typicky v kombinaci:

- **Formální compliance místo učení.** Commit brána a čítače vynutily lístky, agenti je píšou
  tak, aby prošly, podíl výjimek `none` roste, kurátor pod objemem propouští ze zvyku, paměť
  se plní vatou. Pozná se to na podílu schválených kandidátů (klesá k nule nebo roste k jedné -
  obojí je patologie) a poměru čtených pouček k zapsaným; oba poměry měřit od prvního dne a mít
  předem napsané, kdy se mechanismus vypíná.
- **Konkurenční vysvětlení, které zpochybňuje variantu A i celý koncept.** Možná se sběrné
  mechanismy nezastavily proto, že neměly pohon, ale proto, že poznatky nestály za sběr. Pak A
  vyrobí vynucenou byrokracii nad prázdnem. Test je levný a je v kroku 2: když lidská brána dva
  měsíce po sobě schvaluje jen zlomek kandidátů, platí konkurenční vysvětlení a smyčka se
  zeštíhlí na incident-driven režim, který jako jediný reálně plnil katalog selhání i normy.
- **Hook mimo manifest.** Konfigurace hooků Claude Code je soubor, který si role s právem
  zápisu umí upravit, a zvedá se automaticky. Kontrola manifestu je fail-closed jen tam, kde
  platformní brána běží; na klonu bez nainstalovaných git hooků zůstává okno mezi zápisem a
  nejbližším během brány. Zákaz zápisu pro role a pravidlo, že hook nikdy necestuje šablonou
  ani renderem, okno zmenšují, nezavírají - je poctivé to říct a je to důvod, proč hooků má
  být málo a mají být nudné.
- **Měřidlo se rozjede s realitou.** Zlatá sada zastará, soudce driftuje od lidských verdiktů,
  brána blokuje legitimní změny a lidé se ji naučí obcházet. Mitigace: stáří sady a míra neshod
  jako kontroly validátoru, výjimky jen evidované.
- **Otrávená poučka.** Obsah z nedůvěryhodného vstupu projde reflexí i kurátorem a působí v
  paměti dlouhodobě. Plná prevence neexistuje; snižuje se pravděpodobnost (externí signál,
  oddělený kurátor) a dopad (paměť není příkazová vrstva, tok paměť → definice jde přes
  člověka, poučka je odstranitelná revertem).
- **Jeden člověk jako brána zůstává jediným bodem selhání.** Když týdenní slot vypadne na
  měsíc, smyčky se zastaví - nově aspoň viditelně (čítače), ale zastaví. Odstranit ten limit
  znamená posunout hranici tříd zásahu, což je rozhodnutí vlastníka, ne technická otázka.
- **Náklady B se ukážou neúnosné.** Regresní běhy jsou tokenově drahé a poradní režim je
  svádivé zrušit jako první úsporu - čímž se zruší jediné měřidlo účinku. Pak platforma zůstane
  u A + C, což je funkční, ale bez odpovědi na otázku „pomohlo to". Je poctivé říct, že přesně
  tam se dnes stojí: platforma za tři měsíce nedoložila, že by jediný poznatek prošel smyčkou
  až do pravidla, a tenhle koncept je návrh, jak to změnit - ne důkaz, že se to povede.

Co v návrhu změřit nejde: hodnota jednotlivé poučky před jejím použitím. Proxy metriky
(schválení kurátorem, četnost čtení) měří oběh, ne přínos; skutečný test přínosu má až měřidlo
z varianty B, a proto je v doporučení, přestože je nejdražší.

## Kam odsud zpět

Stav, ze kterého tenhle návrh vychází, je v [`uceni-a-zavedeni.md`](uceni-a-zavedeni.md),
část A. Pravidla, kterých se drží, jsou OR-09, OR-10 a OR-12 v [`normy.md`](normy.md).
Mechanika propagace, kterou varianta A kopíruje na druhou stranu, je popsaná
v [`architektura-vrstev.md`](architektura-vrstev.md). Z toho, co je na téhle stránce, zatím
neběží nic.
