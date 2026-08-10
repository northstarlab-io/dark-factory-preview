# Mapa projektů

Dark Factory stojí na samostatných repozitářích a ta dělba má tvrdý důvod. Atomem systému je
jednotka: jedna oblast nebo jeden problém, vlastní `CLAUDE.md`, vlastní `operations/`
a vlastní orchestrátor. Jakmile do jednoho projektu spadne druhé zadání, začnou si dvě práce sahat
na tentýž kontext a orchestrátor nemá podle čeho rozhodnout, které z nich patří pozornost.
Mechanismus dělby je popsaný v [`architektura-vrstev.md`](architektura-vrstev.md), sem ho
nepíšu podruhé; tenhle text je mapa toho, co z toho mechanismu dnes reálně stojí.

**Co je tu jmenovitě a co ne.** Páteř platformy jde jménem, protože její názvy neprozrazují
nic než samy sebe. Byznysová vrstva jde kategoriemi: část projektů nese jméno zákazníka
nebo spolupracovníka přímo v názvu složky a seznam zákazníků je třída, která z balíčku
nejde. Počty tu nejsou nikde, ani celkový. Hranice balíčku a její důvody jsou
v [`hranice-baliku.md`](hranice-baliku.md).

## Páteř platformy

Seřazeno podle toho, jak nutná je ta věc k pochopení celku, ne podle velikosti. U každé
položky je na konci věta o tom, co by se stalo, kdyby nebyla. Ta věta je na celé mapě
nejcennější, protože ukazuje, proč dělba vůbec vznikla.

**`nsl-dark-factory` - platforma sama.** Vrstva META. Staví a spravuje šablonu jednotky,
engine, brány, znění norem, dokumentaci a platformní knihovnu. Nedělá produktivní práci
žádné jednotky a nemá zákazníka; jejím výstupem je způsob, jakým pracují všechny ostatní
projekty. Konzumentem je každá jednotka a každý tenant, prakticky přes changesety a přes
kopie šablony. Kdyby neexistovala, psala by si pravidla každá jednotka sama a do měsíce by
bylo tolik doktrín, kolik je projektů, přičemž ta starší by pokaždé vypadala stejně
důvěryhodně jako nová.

**Platformní knihovna v `~/.claude/`.** Záměrně stojí mimo jednotky: je to sdílená vrstva,
kterou si nástroj načítá sám. Drží kanonické definice rolí, metodická jádra, na která
definice odkazují, a skills; v tomhle balíčku ji máš jako složku `knihovna/`. Fyzicky sdílí
složku s osobním kontextem držitele účtu, což je vědomé, protože ji tak čte nástroj; správa
je rozdělená a rozhoduje o tom, co kam smí přibýt. Konzumentem je každá spuštěná session
napříč vším ostatním. Kdyby neexistovala, kopírovaly by se definice mezi projekty a kopie
se odpojí tiše: přestane dostávat vylepšení, ale neselže, jen umí míň.

**`nsl-alfred` - orchestrátor portfolia.** Tenantní vrstva pro tenanta NSL. Sem přichází
nové zadání zvenčí, odsud se zakládají jednotky a předávají svým orchestrátorům, sem se
eskaluje to, co jednotka nerozhodne sama, a tady se čte stav celého portfolia. Produktivní
práci jednotek nedělá; když ji začne dělat, je to signál, že chybí jednotka. Konzumentem je
člověk, který chce jeden vstupní bod místo toho, aby držel v hlavě, do kterého otevřeného
projektu co patří. Kdyby neexistoval, chodila by zadání přímo do jednotek a přehled napříč
by se sbíral dotazováním, tedy prakticky nikdy.

**`nsl-system-kb` - znalostní báze a její architektura.** Druhý zdroj pravdy vedle disku:
implementační obsah je verzovaný gitem, živý obsah firmy bydlí ve znalostní bázi. Tenhle
projekt řeší, jak je ta báze postavená - struktura napříč nástroji, taxonomie, metadata,
životní cyklus obsahu a hranice mezi rozpracovaným a platným. Konzumentem jsou role, které
si při práci načítají kontext firmy, a člověk, který v tom hledá. Kdyby neexistovala, žila
by paměť firmy v repozitářích jednotek, které se po dodání archivují, a po každé dokončené
zakázce by se zapomnělo, co se v ní naučilo.

**`nsl-df-cockpit` - čtecí a řídící vrstva pro člověka.** Web nad platformou: hlavičky stavů
všech jednotek, fronta nepřevzatých změn, katalog rolí, architektura a dokumentační
rozcestník, k tomu řízené spouštění kontrol. Nikdy není druhým zdrojem pravdy, čte
artefakty, které stejně existují. Konzumentem je člověk v bráně, tedy ten, kdo rozhoduje
a akceptuje. Kdyby neexistoval, četl by se stav portfolia po jednotlivých souborech ručně,
což je práce, kterou nikdo nedělá pravidelně, takže by se místo stavu rozhodovalo podle
posledního dojmu.

**`nsl-tenant-cockpit` - kokpit vydávaný tenantovi.** Platformní produkt s vlastní verzní
řadou, vydáním a distribučním kanálem; u tenanta běží jako vendorovaná kopie, kterou tam
dostává synchronizace, ne uživatel. Konzumentem je instance u tenanta a přes ni koncový
uživatel, který není technik. Kdyby neexistoval, vyvíjel by se kokpit u každého nasazení
zvlášť a oprava nalezená u jednoho by se k ostatním nedostala, protože by nebylo čím ji
poslat.

## Byznysová vrstva

Kategorie s účelem, bez jmen a bez počtů. Společné mají to, že žádná z nich nestaví
platformu; všechny ji používají a některé ji přitom ohýbají, což je zpětná vazba, kterou
páteř sama o sobě nevyrobí.

**Zákaznické zakázky.** Ohraničené zadání s milníky, akceptací a fakturací, ať už je to
dodávka, poradenství, nebo pilot. Od páteře se liší tím, že má konec: páteř se udržuje,
zakázka se dodá a archivuje. Cyklus jde od nabídky přes delivery po milnících k předávce.
V řízení je jiné to, že klasifikace jednotky přepíná režim - co smí opustit repozitář, jak
se nakládá s citlivými daty, jakým tónem se komunikuje ven - a že termíny drží druhá
strana, takže fronta rozhodnutí má vnější deadline.

**Nasazení platformy u zákazníka.** Vlastní rovina vedle zakázky: u zákazníka běží tenantní
harness a jeho kopie kokpitu v ostrém provozu. Trvá, dokud trvá smlouva, takže se řídí
jinak než ohraničená zakázka. Cyklus je nasazení, vydání, aktualizace. V řízení je jiné
to, že sem tečou dvě nezávislé osy propagace, které se nesmí slít, a že oprávnění rolí
patří prostředí, ne roli - artefakty se do cizího repozitáře sestavují, needitují se rukou
a nikdy se nesynchronizují tiše.

**Produktové a partnerské linie.** Věci stavěné se spolupracovníky nebo partnery a vlastní
produkty bez externího zadavatele. Od zakázky se liší tím, že chybí ten, kdo akceptuje;
brzdou je vlastní kapacita a dohoda s druhou stranou. Cyklus je dlouhý a přerušovaný,
řízený kampaněmi nebo vydáními. V řízení je jiné to, že rychlost jednotky je rychlost
dohody, takže hlavní práce orchestrátora je držet rozpracované ve stavu, ze kterého se dá
po pauze pokračovat.

**Rozvoj a prezentace vlastní firmy.** Pozicování, obchodní příprava, vlastní web. Konzument
je trh, ne jiná jednotka, a akceptace neexistuje, takže cyklus je kontinuální. V řízení je
jiné to, že výstupy jdou ven pod jménem firmy, takže brána je přísnější než uvnitř: styl,
doložitelnost každého čísla a to, že nedoložené tvrzení se vyřadí i z pracovních materiálů,
ne až z finálního textu.

**Ohraničené průzkumy pod pracovním názvem.** Záměr, který ještě nemá veřejnou podobu ani
dohodu s druhou stranou; jméno jednotky je interní a nic o obsahu neříká. Od ostatních se
liší tím, že má datum, ke kterému buď dostane tvar, nebo se uzavře. V řízení je jiná
hranice ven: dokud není dohodnuto, nejde ven ani rám, protože jednostranně publikovaný
záměr se vyjednává hůř než nevyslovený.

## Osobní vrstva

Existuje, má stejný tvar jednotky jako všechno ostatní a do balíčku nepatří. Rozhoduje o tom
klasifikace jednotky, ne to, jak je technicky postavená: i projekt, který vypadá čistě
infrastrukturně, zůstává osobní vrstvou, když je tak klasifikovaný. Píšu to rovnou, protože
mlčení o celé jedné části portfolia si čtenář stejně odvodí z toho, že mapa jinak sedí.

## Co má každá jednotka společné

Projekty se liší zadáním, konstrukci mají stejnou. Každá jednotka má tutéž strojově
čitelnou hlavičku stavu, řídí se týmiž normami, má vlastního orchestrátora a vlastní
evidenci toho, co z platformy převzala. Novější jednotky do toho tvaru rovnou vznikají kopií
šablony, starší se do něj dorovnaly zpětně, protože jinak by nad nimi neběžely tytéž
kontroly. Proto nad kteroukoli
z nich běží tentýž validátor, proto se stav portfolia čte ze souborů místo dotazování
a proto změna platformy putuje ke všem stejným kanálem. Kategorie z předchozích sekcí jsou
metadata nad jedním mechanismem, ne oddělené doktríny; kdyby začaly větvit chování, je to
fork, jen pojmenovaný jinak.

## Kde to drhne

**Fronta rozhodnutí člověka se stane hrdlem dřív než kapacita agentů.** Jednotky přibývají
a každá si drží pár otevřených bodů, které delegovat nejde, protože jsou to rozhodnutí
o směru, ne o provedení. Agentní vrstva mezitím běží dál, takže se fronta plní rychleji,
než se odbavuje, a nejdřív to není vidět jako problém, ale jako projekt, který se nehýbe.

**Přehled napříč stojí na tom, že každá jednotka poctivě hlásí svůj stav.** Hlavička je
kontrakt a validátor kontroluje její tvar, ne pravdivost. Když ji orchestrátor po milníku
neaktualizuje, ukazuje portfolio včerejšek a od klidu se to nepozná. Čerstvě přidané pole
hlavičky je toho ukázka: dokud není doplněné všude, brána u něj jen varuje, protože
zpřísnit ji dřív by znamenalo zablokovat práci kvůli evidenci.

**Hranice mezi jednotkami se v praxi rozostřuje a musí se dopisovat.** Práce, která začne
v jedné, se dotkne druhé a chvíli žije v obou; kdo co vlastní, se pojmenuje až ve chvíli,
kdy se překryv projeví. Nejčastěji se to stává na dvou švech: mezi zakázkou a nasazením
u téhož zákazníka a mezi produktem, který vznikl z klientské práce, a páteří, do které se
postupně stěhuje.
