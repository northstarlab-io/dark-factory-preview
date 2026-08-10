# Co je Dark Factory

Způsob, jak provozovat práci s agenty tak, aby držela i ve chvíli, kdy u ní nesedíš. Prakticky je to šablona jednotky, definice rolí, zapsané normy a brány, které ty normy vynucují strojem.

Tenhle text vysvětluje. Když chceš rovnou vidět soubory, jdi na [PROHLIDKA.md](PROHLIDKA.md).

## Problém

Firma o pěti lidech, kde každý nosí víc klobouků. Škálovat se dá lidmi, nebo procesně a technologicky. Druhá cesta stojí na jedné představě: každý člověk má vedle sebe sadu poloautonomních asistentů, sám je validátorem kvality a agentní vrstva dělá tu část práce, kterou dnes stejně dělá napůl nebo vůbec. Rešerše, přelévání dat, příprava podkladů, operativa na dlouhé lokte.

První verze takové vrstvy se postaví za odpoledne a funguje. Rozpadne se za pár týdnů, a to dvěma způsoby:

- **Kolize.** Jednu roli si napíšeš a je dobrá. Jakmile jich je hrstka, dvě si začnou sahat na totéž a ani jedna neví, kde má přestat. Text definice tenhle spor neřeší, protože obě definice mluví jen o sobě.
- **Drift.** Změníš pravidlo na jednom místě a nemáš jak zjistit, kde všude ještě platí to staré. Po měsíci jsou v systému dvě pravdy a ta starší vypadá stejně důvěryhodně jako nová.

Nejtěžší na tom není napsat agenta. Těžká je tahle druhá fáze: kolize, drift a to, co se stane, když je práce víc než pozornosti. Tam míří všechno, co je v tomhle repu.

## Jak to řeší

**Jednotka je atom.** Jedna oblast nebo jeden problém = jeden projekt s vlastním `CLAUDE.md` a složkou `operations/`. Každá jednotka o sobě povinně hlásí stav v hlavičce `operations/status.md`: sedm polí v pevném tvaru, mezi nimi klasifikace, fáze, zdraví a to, komu jednotka slouží. Hlavička je strojově čitelná, takže stav portfolia se nesbírá dotazováním, ale čte ze souborů, které existují stejně v každé jednotce.

**Role je kontrakt, ne prompt.** Definice popisuje doménu, hranice vůči sousedním rolím, železná pravidla a anti-patterny. Většina textu neřeší, co má role dělat, ale kde přestává a komu to předává. Vzniká postupem: kompetenční mapa nejdřív, persona až potom, jméno schvaluje člověk. A agent svou vlastní definici needituje - zlepšení navrhuje, zapisuje ho jiná role po lidském schválení. Bez téhle hranice nejde odlišit záměr od nánosu. Co se z provozu sbírá, jak se z poznatku stane pravidlo a co se přitom neučí samo, je v [uceni-a-zavedeni.md](uceni-a-zavedeni.md).

**Norma nese incident.** Každé provozní pravidlo má čtyři části: co platí, proč, test, kterým si ověříš, že to dodržuješ, a doložený případ, kterým vzniklo, včetně data a toho, co selhalo. Pravidlo bez incidentu se za měsíc nedá ani obhájit, ani vyhodit.

**Změna se propaguje evidovaně.** Ke každé změně platformy s dosahem mimo ni vzniká changeset: lístek s lidskou větou napsanou v okamžiku změny, s akcí pro příjemce a s blokem strojového testu, který má tři výsledky včetně `NEZJISTENO`. Jednotka si vede baseline, tedy evidenci toho, co převzala. Do baseline zapisuje výhradně nástroj a jen po průchodu testem. Odpověď na otázku „na jaké verzi běžím a co mi uteklo" je tím jedno číslo místo pátrání v historii.

**Bránu drží stroj.** Validátor jednotky kontroluje strukturu a hlavičku. Validátor platformy kontroluje osmnáct číslovaných invariantů knihovny rolí a evidence. Oba jsou fail-closed: co nejde vyhodnotit, neprojde. Spouští je git hooky při commitu, instaluje je člověk jedním příkazem a stejným je vypíná. Obejít se to dá, ale ne tiše - commit bez pokrytí se najde zpětně při příštím běhu.

**Upgrade ví, čeho se nesmí dotknout.** Šablona jednotky je verzovaný artefakt a manifest dělí cesty na to, co upgrade přepisuje, a na data jednotky. Cesta, která není ani v jedné množině, se z principu nechává být.

**Obsah má dvě osy, ne jednu složku.** Kam co patří, rozhoduje typ obsahu (kdo je jeho zdroj pravdy: disk, nebo znalostní báze) a fáze (rozpracované, nebo platné). Osy jsou kolmé a jejich slití končí u pravidla „důležité věci do znalostní báze", které nerozhoduje nic. Rozepsané i se zavedenou podobou PARA a se čtyřmi místy, kde to dnes drhne, v [datove-vrstvy.md](datove-vrstvy.md).

## Čím se to liší od toho, co si postavíš sám

Nic z toho není technicky obtížné. Rozdíl není ve schopnostech, ale v tom, co je už zaplacené:

1. **Hranice mezi rolemi jsou vypsané v textu obou rolí.** Ne v hlavě toho, kdo je psal. Věta „tohle nedělám já, dělá to role, která vlastní tuhle doménu" je to, co u víc rolí naráz brání tomu, aby dvě dělaly totéž jinak. Ověřit si to jde na jedné dělbě: kdo vlastní mechaniku vydání a kdo text, který k němu čte zákazník, stojí v `knihovna/agents/humble.md` i v `knihovna/agents/komensky.md`.
2. **Pravidla mají doložený původ.** Pravidlo bez incidentu je názor. Totéž pravidlo s datem a popisem selhání je provozní paměť, kterou lze předat dál a taky vyhodit, až přestane platit.
3. **Propagace není pull.** Vlastní systém obvykle stojí na tom, že si změnu pamatuje autor. To drží do chvíle, kdy je konzumentů víc než jeden a autor si vzpomene o týden později.
4. **Kontrola není disciplína.** Všechno, co v tomhle systému hlídá regulární výraz, hlídal dřív člověk. Ten přesun je celý přínos a nebyl zadarmo, viz sekce níž.
5. **Hranice mezi platformou a nasazením u klienta je fyzická.** V tomhle balíčku není konfigurace žádného nasazení a je to nejlevnější doklad, že ta hranice není jen deklarovaná.

Čestněji řečeno: rozdíl není v tom, co to umí. Je v tom, že je to zapsané, vynucené strojem a přežije to týden, kdy se tomu nikdo nevěnuje. Kdybys to stavěl sám, dojdeš ke stejným mechanismům; jen tě to bude stát ty incidenty.

Jak to vypadá na konkrétní práci, ukazují čtyři případy v [pripady-pouziti/](pripady-pouziti/README.md): co se zadalo, jak se to rozdělilo, co odvedla agentní vrstva, kde vstoupil člověk a co se v tom předělávalo. Oddíl o předělávání je u každého nejdelší schválně.

## Co z toho běží dnes

- **Engine se spouští při běžné práci** a nevznikl kvůli téhle prohlídce. Validátory, hooky a šablona jsou soubory z provozu; v balíčku si je můžeš spustit nad přiloženou ukázkovou jednotkou.
- **Evidence propagace běží od 3. srpna 2026.** Za prvních sedm dní vzniklo pětašedesát lístků. Třináct z nich, celý týden 3. až 9. 8., je v `operations/changesets/` i s jejich strojovými testy.
- **Jednotky založené z téhle šablony běží nad reálnou prací.** Ta v balíčku je prázdný výsledek zkopírování šablony, aby bylo na čem spustit validátor.
- **U platícího zákazníka dnes běží software v ostrém provozu a aktualizuje se vydáním.** Zákazník ani jeho obor tu jmenovaný není a nebude.
- **Číslo verze platformy v tomhle textu schválně není.** Čte se ze `scaffold/VERSION` a hlídá to samostatná kontrola validátoru, protože živé číslo napsané rukou zestárne dřív, než ho někdo přečte. Tenhle balíček má vlastní číslo v `VERSION` a je to jiná osa; vysvětlení je v [mapa-verzi.md](mapa-verzi.md).

Záměrem, tedy ne hotovou věcí, zůstává: automatická integrace, měřená kvalita místo odhadu při volbě modelu a jakákoli podoba plné autonomie bez člověka v bráně.

## Co dnes nefunguje

1. **Sken přístupových údajů nevidí jméno klienta a je to vlastnost, ne chyba.** Hledá tvary tokenů, takže třídu „klientská identita" z konstrukce nevidí. Ukázalo se to při přípravě tohohle balíčku: strojový sken byl čistý, ruční audit našel jméno klienta ve víc než stovce souborů. Proto balíček nevznikl klonem, ale vydělením bez historie.
2. **Dokumentace zestárla dřív než platforma.** Kořenový soubor repa měsíce tvrdil, že projekt je v úvodní fázi a tým není postavený, zatímco platforma byla dávno jinde. Rozpor našel až audit před tímhle sdílením.
3. **Brána existovala dřív, než ji začal někdo spouštět.** Validátor platformy hlásil chyby, které nikdo neviděl, protože ho od posledního ručního běhu nikdo nepustil. Git hooky vznikly až po tom zjištění.
4. **Ruční synchronizace čísla selhala pokaždé.** Verze platformy zamrzla v kopiích v několika jednotkách. Dokument, který přesně před tímhle varuje, sám nesl číslo o tři vydání pozadu, protože ho tam někdo napsal rukou.
5. **Testy se pouštějí rukou.** Scénáře nad mechanikou propagace existují a běží před commitem; server, který by je spustil za člověka, není.
6. **Kvalita se zatím měří tím, na co se člověk zeptá.** Metrika je zavedená a slepé srovnání běží, ale do jeho vyhodnocení je volba modelu pro úlohu informovaný odhad.

## Kde zůstává člověk

Na šesti místech a žádné z nich se neplánuje odstranit: rozhodnutí, co jde ven; akceptace výstupu; jméno nové role; zapnutí bran na konkrétním stroji; jakákoli komunikace s druhou stranou; a zápis poznatku z provozu do definice role. To poslední místo je nejméně samozřejmé a má vlastní text: [uceni-a-zavedeni.md](uceni-a-zavedeni.md). Autonomní továrna to není. Je to továrna s jedním člověkem v bráně a hodně mechaniky za ní.

## Osm pojmů

- **Jednotka.** Jeden projekt s vlastním `CLAUDE.md` a složkou `operations/`. Atom systému; všechno ostatní je buď uvnitř jednotky, nebo mezi jednotkami.
- **Vrstva.** Čtyři vrstvy dělené podle toho, kdo obsah spravuje, ne podle toho, kde leží na disku: osobní kontext držitele účtu, platforma, tenant, jednotka. Jedna složka může nést dvě vrstvy a je to vědomé.
- **Orchestrátor a specialista.** Orchestrátor zadává a koordinuje, specialista dělá práci ve své doméně. Jestli session roli převezme, nebo ji zavolá jako subagenta, má technické důsledky; stylová volba to není.
- **Norma.** Zapsané rozhodnutí ve tvaru pravidlo, proč, test a incident, který ho odhalil. Architektonická rozhodnutí (AR) říkají, jak je systém postavený, provozní normy (OR) říkají, jak se v něm pracuje.
- **Kanonický domov.** Každý fakt má právě jedno místo, kde bydlí; ostatní místa na něj odkazují. Duplikace není pojistka, je to budoucí rozpor.
- **Changeset a baseline.** Changeset je lístek k jedné změně platformy s lidskou větou a testem, jak se pozná převzetí. Baseline je evidence jedné jednotky o tom, co převzala; zapisuje do ní výhradně nástroj a jen po průchodu testem.
- **Brána.** Mechanická kontrola, která je fail-closed: co nejde vyhodnotit, neprojde. Kdo ji obejde, zanechá po sobě stopu, kterou najde příští běh.
- **Scaffold a seam.** Scaffold je šablona jednotky jako verzovaný artefakt. Seam je deklarace, které cesty smí upgrade přepsat a které jsou data jednotky, kterých se nikdy nedotkne.

## Kdyby tě to zajímalo dál

První krok je jeden konkrétní mechanismus, ne celý systém. Vyber si ten, který v tvém prostředí dnes chybí a bolí to (nejčastěji propagace změn nebo hranice mezi rolemi), a pojďme si nad ním sednout: co jsi zkusil ty, co jsme zkusili my a čím se to u nás rozbilo.

Výměna je oboustranná, tak jak jsme se o ní bavili. Až budeš mít svoje odděleně od klientských dat, rád si to projdu stejně poctivě, jak čekám, že projdeš tohle - a nejužitečnější mi bude, když mi řekneš, kde ti to tady nesedí. Rámec toho, co se s balíčkem smí dělat, a kam mi napsat, je v [NOTICE.md](../NOTICE.md).
