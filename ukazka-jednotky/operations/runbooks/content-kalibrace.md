# Runbook - kalibrace hranice tónu (template)

> Provozní rituál, kterým se vkus držitele hlasu převádí na pravidla použitelná strojem. Template ve verzi V0 - rámec stojí, obsahovou náplň (kritéria dávky, taxonomii tónu, práh) doplní specialisté projektu. Patří k content context-engineering normě platformy jako její provozní část (c) feedback loop. Kanonický katalog té normy je mimo tenhle balíček.
>
> **Jak template použít:** zkopíruj do `<projekt>/operations/runbooks/content-kalibrace.md`, vyplň konfiguraci per projekt (níže) a smaž tenhle blockquote. Placeholdery `<...>` nahraď konkrétními hodnotami projektu.

## Konfigurace per projekt (vyplň před prvním kolem)

- **Držitel vkusu (kdo verdiktuje):** `<v NSL projektech typicky Stanislav; u klienta klient nebo Stanislav v jeho zastoupení>`.
- **Cílový žánr / kanál:** `<copy, marketing, social, klientské updaty, ...>`.
- **Specialista destilující pravidla:** `<content specialista nebo stratég projektu>`.
- **Zdroj sestavující dávku cizího materiálu:** `<výzkumná role projektu>`.
- **Zdroj učení feedback loopu (per-agent volba, viz norma):** `<z lidských editů | z destilovaných verdiktů>`. Default je učení z editů - agent psaný pod skutečným jménem člověka smí nést jeho rukopis. Verdict-only zvol jen tam, kde by agent musel vědomě divergovat od reálného idiolektu konkrétního člověka. Vyber jedno a napiš proč.

## Proč to existuje

Hranice tónu je zpočátku tacit knowledge. Držitel vkusu ji pozná, až ji uvidí, ale neumí ji dopředu popsat - a to je normální stav, ne nedostatek přípravy. Zároveň platí tvrdý constraint: pravidla musí být **strojově exekvovatelná**, protože podle nich generuje obsah agentní systém. Věta "drzý, ale nikdy vulgární" je pro člověka srozumitelná a pro stroj bezcenná.

Kalibrace je most mezi tím dvojím. Sbírá verdikty nad konkrétním materiálem a destiluje z nich rozhodovací pravidla.

**Hranice je obousměrná.** Horní hranice = obsah, který jde za čáru (agrese, vulgarita, cílená šikana). Spodní hranice = obsah, který je mrtvý (moralizující, generický, opatrný, bez názoru). Spodní hranice je pro projekt stejně nebezpečná jako horní: text, který nikoho neurazí, taky nikoho nezaujme.

## Co to není

**Není to schvalovací fronta.** Cílem není odklepávat jednotlivé kusy - to je přesně role, které se chceme zbavit. Cílem je naučit pravidla tak dobře, aby odklepávání přestalo být potřeba. Každé kolo má snížit počet věcí, které musí posoudit člověk, ne ho zvýšit.

Rozdíl v praxi: schvalování se ptá "publikovat tenhle kus?", kalibrace se ptá "co tenhle verdikt říká o pravidle?".

## Škála verdiktů

Pět stupňů, ne ano/ne. Binární verdikt zahazuje informaci o vzdálenosti od hranice, a právě ta vzdálenost je to, co potřebujeme.

| Stupeň | Význam |
|--------|--------|
| **Přes čáru** | Za horní hranicí. Nepublikovat. |
| **Ostré, ale ano** | Těsně pod horní hranicí. Publikovat. |
| **Trefa** | Střed pásma, přesně ono. |
| **Krotké** | Nad spodní hranicí, ale slabé. Publikovatelné, nezajímavé. |
| **Mrtvé** | Pod spodní hranicí. Moralizující, generické, bez názoru. |

**Nejcennější jsou oba krajní přijatelné stupně** - "ostré, ale ano" a "krotké". Ty definují, kde hranice leží. Verdikty "přes čáru" a "mrtvé" potvrzují, že hranice existuje, ale neříkají, kudy vede.

Volitelně jedna věta proč. Nepovinná - vynucené zdůvodňování zpomaluje a úsudek je platný i bez něj. Když ale věta přijde, má vyšší hodnotu než samotný verdikt.

## Slepý tip - metrika konvergence (doporučená součást)

Tohle je jádro celého mechanismu a odlišuje ho od pouhého sbírání názorů. **Doporučeno pro každou implementaci** - je to čistší měřítko kvality context engineeringu než cokoli jiného v rituálu.

**Než dávku uvidí držitel vkusu, agent si u každého kusu tipne, jaký verdikt padne.** Tipy se zapíšou a zapečetí. Po lidském průchodu se porovnají.

Shoda tipu se skutečným verdiktem je **přímé měřítko toho, jak dobře naložený kontext zachycuje vkus.** Není to vedlejší metrika - je to hlavní ukazatel zdraví celé disciplíny.

- Vysoká shoda znamená, že pravidla fungují a rozhodování lze pustit strojem.
- Nízká shoda ukazuje, kde pravidla chybí. **Neshody jsou cennější než shody** - každá je díra v pravidlech s konkrétní adresou.
- Systematická odchylka jedním směrem (agent tipuje soustavně krotčeji, než člověk soudí) je nález sám o sobě a míří na konkrétní chybějící pravidlo.

Práh, při kterém se rozhodování pouští strojem, se stanoví po prvních kolech z reálných dat - dřív by to bylo číslo z prstu.

## Fáze 1 - kalibrace na cizím materiálu (běží před vlastní produkcí)

Nečekat na vlastní obsah. Svět je plný existujícího materiálu a u cizího kusu se verdikt vynáší snáz než u vlastního nápadu.

**Postup:**

1. Research agent sestaví dávku ~20 kusů reálného obsahu z cílového žánru. Ke každému krátký kontext: kdo, kde, jaký ohlas.
2. **Podmínka kvality dávky:** většina kusů musí ležet blízko předpokládané hranice. Dávka ze zjevných extrémů nekalibruje nic - držitel vkusu u ní odklepe dvacetkrát to samé a nedozvíme se, co bychom nevěděli.
3. Agent si u každého kusu udělá slepý tip (viz výše) a zapečetí ho.
4. Držitel vkusu projde dávku a vynese verdikt na pětistupňové škále. Odhad nákladu: 15-20 minut.
5. Tip i verdikt se zapíšou do kalibračního logu.

## Fáze 2 - kalibrace na vlastním materiálu (po startu produkce)

Stejná mechanika, jiný zdroj. Materiál generuje agentní systém, člověk soudí. Přechod z fáze 1 do fáze 2 je plynulý; nějakou dobu poběží obojí, protože cizí materiál dodává hranice, které vlastní produkce sama netrefí.

## Zápis a destilace

**Kalibrační log:** jeden append-only soubor, `operations/kalibrace-log.md`. Jeden záznam = kus obsahu, slepý tip agenta, verdikt člověka, volitelně důvod, datum. Log se nepřepisuje ani neuklízí - historie je hodnota, z posunu verdiktů v čase se pozná, jestli se hranice hýbe.

**Destilace:** po každých zhruba 40 verdiktech projde log specialista a přepíše z něj **rozhodovací pravidla**. Pravidlo musí být formulované tak, aby podle něj rozhodl stroj.

Příklad rozdílu: "posměch míří na chování a na výrok, nikdy na vzhled, rodinu nebo majetek" je použitelné pravidlo. "Buď drzý, ale slušný" není.

Destilace **nikdy nemaže log** a nikdy nenahrazuje verdikty vlastní interpretací - jen z nich odvozuje. Když je pravidlo sporné, zůstává v logu jako otevřená otázka do dalšího kola.

**OR-09:** destilovaná pravidla se do agent definice ani do projektových pravidel zapisují přes lidské schválení, ne agentem samotným. Agent svá pravidla nikdy nepřepisuje sám.

## Rytmus a náklad

- **Fáze 1:** jedna dávka týdně, dokud nemáme první sadu pravidel. Náklad člověka 15-20 minut týdně.
- **Fáze 2:** frekvence klesá podle konvergence. Když shoda tipů roste, rytmus se ředí na jednou za dva týdny, pak měsíčně.
- **Trvale:** i po konvergenci zůstává řídká kontrolní dávka (měsíčně nebo kvartálně). Hranice se v čase posouvá s publikem, dobou i samotným brandem; kalibrace, která ustane, tiše zastará.

Rituál je vědomě navázaný na nízký a předvídatelný náklad. Kalibrace, která stojí hodinu týdně, se přestane dělat.

## Vztah k vkusovému vetu

Kalibrace **nenahrazuje** právo držitele vkusu cokoli stopnout před publikací. Zlevňuje ho. Čím lepší pravidla, tím méně často veto padne a tím méně materiálu musí projít lidským okem. Veto zůstává natrvalo, i v cílovém stavu.

## Co ještě chybí (doplní specialisté projektu)

Tenhle runbook drží **rámec rituálu**. Obsahovou náplň musí dodat specialisté, jinak zůstane prázdnou formou:

- **Kritéria pro sestavení dávky** - jak research agent pozná materiál blízko hranice, z jakých zdrojů čerpá, jak zajistí rozptyl.
- **Taxonomie tónu** - jazyk, ve kterém se pravidla formulují (na co posměch míří, jaké prostředky, jaký odstup, jaká témata). Bez sdíleného jazyka bude každá destilace vypadat jinak.
- **Práh pro pouštění rozhodování strojem** - konkrétní číslo shody slepých tipů. Stanoví se po prvních kolech z reálných dat.
- **Umístění a citlivost logu** - log obsahuje verdikty držitele vkusu, tedy otisk jeho úsudku. U projektů s opsec nebo NDA constraintem posuď, kde log fyzicky žije a kdo k němu má přístup, dřív než začneš zapisovat.
