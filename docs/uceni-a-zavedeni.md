# Jak se to učí a jak se to zavádí do firmy

Dvě otázky, na které se v balíčku dalo odpovědět jen po kusech: podle čeho se ten systém
mění, když se změní realita kolem něj, a jak se dostane k lidem ve firmě. Nic nového tu
nepřibývá, jen se skládá to, co v balíčku leží, a u každé části je napsané, kde to nedrží.

Patří do patra mechanismů a je z něj nejméně technický: nepopisuje jeden soubor ani jednu
bránu, ale dvě smyčky vedoucí z platformy ven - jednu do vlastních definic rolí, druhou
k lidem ve firmě.

## A. Co se z provozu učí a co se neučí samo

Krátká odpověď dopředu: **sběr a návrhy jsou zautomatizované, zápis do definice role dělá
člověk.** Není to chybějící funkce, je to rozhodnutí a stojí v normě. A druhé přiznání
hned vedle: co systém sleduje, je jeho vlastní provoz, ne provoz firmy kolem něj. Signál
z reality firmy do něj dnes nosí člověk.

### 1. Co se sbírá

| Soubor | Co dělá |
|---|---|
| `knihovna/skills/agent-retro/SKILL.md` | Retro po dokončené práci: co fungovalo, co ne, co bych udělal jinak. Dvě z pěti sekcí jsou přímo návrhy na změnu definice role a jejího metodického jádra. Spouští se selektivně, ne po každém úkolu, a důvod je napsaný v samotném souboru: úzké hrdlo je kapacita člověka na posuzování. |
| `knihovna/skills/agent-output-check/SKILL.md` | Kontrola výstupu před předáním proti třem signálům: rozpor s metodickým jádrem role, rozpor s pravidly firmy, vymyšlená entita. Čtyři konce: projde, opraveno a zalogováno, zastaveno k posouzení, zahozeno. Log opravených případů je hlavní zpětná vazba, ne vedlejší produkt. |
| `knihovna/foundation/quentin-signals.md` | Log člověka. Dvě až tři věty po interakci ve tvaru „tohle sedlo, tohle ne". Orchestrátor ho čte na začátku session jako kontext, jak se má chovat. |
| `knihovna/foundation/anti-patterns-catalog.md` | Katalog opakovaných selhání s postupem zotavení. Pravidlo růstu je záměrně přísné: záznam vzniká po třech výskytech, ne po prvním. |
| `operations/changesets/` a `ukazka-jednotky/operations/platform-baseline.md` | Evidence toho, co kdo převzal. Jedna strana vydává lístky, druhá si vede, co z nich vstřebala, a rozdíl je číslo. |

### 2. Kde je člověk povinně v cyklu a proč

Norma OR-09 v [`normy.md`](normy.md): žádná role needituje vlastní definici, vlastní
spouštěč ani pravidla, kterými se řídí. Zlepšení navrhuje, zapisuje ho jiná role po
lidském schválení.

Důvod za tím je jeden a je to jádro celé odpovědi. **V systému, kde si role upravuje
vlastní pravidla, nejde odlišit záměr od nánosu.** Smyčka, která si sama přepíše popis,
funguje do chvíle, kdy se někdo zeptá „proč to dělá takhle" a nejde zjistit, jestli to
někdo rozhodl, nebo si to systém přidal sám. Cena za tuhle hranici je zpoždění. Koupená je
za ni čitelnost historie chování.

Totéž pokrývá i vykonávanou konfiguraci: git hook role napsat smí, aktivovat ho na stroji
ne. Konfigurace, která se aktivuje sama, je od driftu nerozeznatelná.

### 3. Jak se z poznatku stane pravidlo

Čtyři kroky: retro, týdenní předfiltr na tři až pět kandidátů
(`knihovna/skills/methodology-promote/SKILL.md`), rozhodnutí člověka, zápis do definice,
který dělá jiná role než ta dotčená.

Postup je v balíčku u všech čtyř kroků, doložený průchod jen u posledních dvou. První dva
kroky si přečteš jako skill v tabulce výše; co po nich zbylo v provozu, tu není. Poslední
dva jsou vidět na výsledku: záznam AP-003 a jeho revize
ze 7. srpna 2026 v `knihovna/foundation/anti-patterns-catalog.md`: původní pravidlo
zakázalo orchestrátorovi celou exekuci, provoz ukázal, že řez byl moc široký a skutečná
vada byla jinde, tak se pravidlo změnilo a v definici role je vidět z druhé strany
(`knihovna/agents/alfred.md`, krok 0 ve workflow „Dispatch nového zadání"). Ten záznam
nevznikl z retra; všiml si toho člověk při práci. Retro reporty ani týdenní fronty
kandidátů v balíčku nejsou, protože vznikají uvnitř jednotek
([`hranice-baliku.md`](hranice-baliku.md), bod 6). Podstatné na tom je, že smyčka umí
i uvolnit pravidlo, které se ukázalo jako moc přísné. To u přírůstkových katalogů obvykle
chybí.

### 4. Co dnes nefunguje

- **Zastarávání hlídá rituál, ne stroj.** Na disku běží brána při každém commitu, ve
  znalostní bázi neběží nic: existuje runbook, kadence i vlastník, ale žádná kontrola
  neřekne, že revize proběhla.
- **Sebehlášení role o vlastní náročnosti se neosvědčilo jako signál.** V jednom běhu
  napsalo všech 32 spuštění, že přidělené nastavení sedělo. Nula doporučení v obou směrech
  není kalibrace, je to ticho.
- **Kalibrační smyčka je zatím ruční.** Předfiltr, posouzení i zápis jsou lidské kroky
  v jednom týdenním slotu. Když ten slot vypadne, smyčka stojí a nikde se to nerozsvítí.
- **Jeden ze sběrných kanálů se sám zastavil.** Signální log má tři záznamy, všechny
  z 8. až 10. května 2026, a delší záznam v balíčku není. Vlastní práh si přitom nastavil
  na osm signálů, takže se zastavil pod ním. Katalog selhání nese revizi ze srpna, takže
  poznatky tečou dál, jen jiným kanálem, než na který se to stavělo.

Odpověď na otázku, jestli to sleduje, jak se ve firmě reálně žije, a upravuje podle toho
popisy, je proto **částečně ano a částečně vědomě ne.** Ano ve sběru: co selhalo, co se
opakuje, co si člověk poznamenal, co která jednotka nepřevzala. Ne v zápisu: popis role
mění člověk. A ne v dosahu: měří se práce systému, ne to, co se ve firmě kolem něj děje.

Kam to míří: jak tenhle stav dotáhnout do autonomního provozu a jakými cestami, rozepisuje
[`koncept-autonomie.md`](koncept-autonomie.md). Je to budoucí koncept - směr, ne popis toho,
co v balíčku běží.

**Kde si to ověříš:** pět souborů z tabulky výše; [`normy.md`](normy.md) OR-09 a OR-10;
[`datove-vrstvy.md`](datove-vrstvy.md), sekce „Kde to dnes drhne", bod 2;
[`CO-JE-DARK-FACTORY.md`](CO-JE-DARK-FACTORY.md), sekce „Kde zůstává člověk"; a
k sebehlášení [`pripady-pouziti/03-reserse-ktera-skoncila-pravidlem.md`](pripady-pouziti/03-reserse-ktera-skoncila-pravidlem.md).

## B. Jak se to zavádí do firmy

Postup není v balíčku sepsaný jako metodika, leží rozložený v definicích rolí, které ho
vykonávají. Tohle je jeho poskládání do šesti kroků.

1. **Discovery.** Rozhovor po třech otázkách, každá otázka nese vlastní doporučení, aby
   druhá strana korigovala, ne vymýšlela. Výstup je zápis zadání: typ práce a termín,
   vztah k zadavateli, co je uvnitř a co venku, citlivá data, doporučené role.
   (`knihovna/agents/alfred.md`, workflow 2 a 3)
2. **Založení jednotky z verzované šablony**, ne z prázdného listu. Šablona už nese blok
   norem, tři runbooky a hlavičku stavu, takže nová jednotka o sobě hlásí stav od prvního
   dne. Příčina je zapsaná: co se nedědí ze šablony, se při ručním kopírování jednou
   zapomene. (`scaffold/studio-template/`, `ukazka-jednotky/operations/status.md`)
3. **Výběr rolí podle toho, co oblast potřebuje**, ne podle katalogu. Definice nesou
   i výslovné „nevolej pro", takže výběr je čtení hranic. (`knihovna/README.md`)
4. **Předávka orchestrátorovi jednotky, ale až po kontrole.** `scaffold/validate.sh` musí
   vrátit OK, jinak založení není hotové. Pak předávka jednou větou: kde to je, jaká
   klasifikace, kdo pokračuje, jaké role doporučené. Tím zakládání končí. Denní
   orchestraci přebírá orchestrátor jednotky, ale ten, kdo zakládal, dál drží jeden plán
   napříč jednotkami a práci téhle jednotce zadává, když to plán vyžaduje. Tahle hranice
   se v srpnu posunula a je to týž případ, který stojí v části A.
5. **Zavedení u lidí.** Kalibrace zralosti před startem, měřená po jednotlivcích ve třech
   osách (rozumím tomu, umím ten nástroj, mám to v rutině), protože průměr týmu skrývá
   rozdíl mezi vyrovnanou skupinou a skupinou, kde jsou dva lidé úplně nahoře a dva na
   začátku. Průměr vyjde stejně, návrh musí být jiný. Série sezení s pevnou trajektorií
   a proměnným obsahem: první je navržené celé, další dvě jsou draft s předem zapsanými
   spouštěči změny. Odpor se bere jako data a odpovídá se na něj diagnostickou otázkou,
   ne přesvědčováním. Dokumentace se píše pro toho, kdo produkt používá, ne pro toho, kdo
   ho staví. (`knihovna/agents/lasso.md`, `knihovna/agents/komensky.md`)
6. **Co se měří, aby se poznalo, jestli to chytlo.** Rozdíl zralosti proti vstupnímu
   měření, soupis případů použití, které tým sám přinesl, a kolik z nich přešlo do rutiny; na
   straně systému stav a zdraví jednotky v pevné hlavičce a počet nepřevzatých změn jako
   číslo. Přijetí ve firmě dnes vyhodnocuje člověk, ne stroj, a je fér to říct rovnou.

**Nejtěžší na tom není technika.** Podle materiálu v balíčku se hrdlem stane rozhodovací
fronta člověka dřív než kapacita agentů. Je to vidět na třech nezávislých místech: retro
se schválně nespouští po každé práci, protože úzké hrdlo je kapacita člověka na posuzování;
týdenní dávka kandidátů je stropovaná na tři až pět, protože víc už nikdo v jednom slotu
neprojde; a v nasazení mimo vlastní prostředí zablokoval dodávku dvakrát administrátorský
úkon na druhé straně, který nešlo udělat ani vynutit. První dvě místa jsou naše vlastní
kapacita na posuzování, třetí je čekání na člověka, kterého neřídíme. Plánovat je potřeba
obojí a ani jedno z toho není výkon agentů.

**Kde si to ověříš:** `knihovna/agents/alfred.md` (workflow 2 a 3),
`knihovna/agents/lasso.md` (adaptivní návrh programu a pět výchozích rozhodovacích
pravidel), `knihovna/agents/komensky.md` (doména dokumentace),
`knihovna/agents/panos.md` (kdo zapisuje definice rolí),
`scaffold/studio-template/` a `scaffold/validate.sh`,
[`pripady-pouziti/01-nasazeni-u-zakaznika.md`](pripady-pouziti/01-nasazeni-u-zakaznika.md)
(týž postup na reálném nasazení, včetně toho, co se v něm předělávalo).

## C. Co si z toho vezmeš hned a co je vázané na zbytek

Hned a bez zbytku systému: pravidlo, že si role nepřepisuje vlastní definici, a katalog
selhání s prahem tří výskytů. Obojí je jedna věta a jeden soubor. Vázaná na zbytek je
propagace poznatku do definice, protože potřebuje evidenci převzetí a bránu, která ji
vynutí. Kroky 1 až 4 z části B stojí na šabloně a validátoru, které v balíčku jsou; krok 5
stojí na lidech. Co z balíčku nespustíš a proč, je v [`hranice-baliku.md`](hranice-baliku.md).

## Kam odsud dál

Obě pravidla, o která se to opírá, jsou OR-09 a OR-10 v [`normy.md`](normy.md). Týž postup
zavedení na reálném nasazení včetně toho, co se v něm předělávalo, ukazuje
[`pripady-pouziti/01-nasazeni-u-zakaznika.md`](pripady-pouziti/01-nasazeni-u-zakaznika.md).
A návrh, jak by se stav popsaný v části A dal dotáhnout dál, je v samostatném
[`koncept-autonomie.md`](koncept-autonomie.md): tři cesty na společných osách, s doporučením
a s rozborem toho, čím to může selhat. Je to směr, ne popis toho, co dnes běží.
