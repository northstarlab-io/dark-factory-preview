# Omezení, které nezaniklo

**Kdy:** zapsáno 16. a 17. června 2026, uklizeno 8. srpna 2026
**Kde:** paměť dvou sessions
**Třída vady:** dočasná direktiva v kanálu trvalých faktů

## Co se stalo

Jeden z modelů byl dočasně nedostupný kvůli vyčerpanému limitu. Pokyn „tenhle model
nepoužívej, spawnuj s jiným" se zapsal do automatické paměti dvou sessions. Obě položky
měly u sebe napsanou podmínku zániku, ve smyslu „platí, dokud nebude model zase dostupný".
Nikdo nic nezanedbal, podmínka tam byla.

## Jak se to projevilo

Nijak, dokud si osmého srpna někdo nevyžádal zrušení toho omezení napříč projekty. Sweep
našel obě položky živé. Přežily svou platnost o sedm týdnů.

Druhá věc se ukázala až při tom úklidu: jedna z položek mezitím zestárla i věcně. Stála na
tvrzení o výchozím modelu jedné role, které od změny alokace z 28. července neplatilo.
Dočasná direktiva v trvalém kanálu tedy postupně přestává být jen zbytečná a začíná být
škodlivá.

A třetí, nejnepříjemnější: **ten kanál to omezení nikdy ani nedoručoval.** Automatická
paměť hlavní session se nedědí do subagentů. Pokyn o modelu tedy nikdy neviděly právě ty
spawny, kterých se týkal; působil jen zprostředkovaně přes orchestrátora, když si vzpomněl.
Kanál byl špatně na obou koncích: na vstupu nedoručuje, na výstupu nezaniká.

## Co to stálo

Sedm týdnů, po které v systému formálně platilo omezení, které nikdo nezrušil a které se
zároveň nedoručovalo tam, kam mělo. Úklid stál sweep přes čtyři lokace, protože stejná
věta mohla být kdekoli.

Přímá škoda je nula. Cena je jinde: pravidlo, o kterém nevíš, jestli ještě platí, přestane
řídit chování a začne řídit dohady.

## Co se z toho stalo za pravidlo

Napsaná podmínka zániku není mechanismus zániku. Mechanismus potřebuje **aktéra** (kdo
vyhodnotí), **moment** (kdy se vyhodnocení spustí) a **podmínku vyhodnotitelnou bez
investigace**. Prozaická podmínka v paměti neměla ani jedno.

Nový tvar má tři vlastnosti:

- **Kalendářní datum, povinně.** Položka zní `Do 2026-08-09: ...`. Datum je jediná
  podmínka, kterou každý čtenář vyhodnotí zadarmo při každém načtení, protože dnešek
  v kontextu má. Prozaická podmínka je nevalidní zápis. Když konec neznáš, dej krátké
  datum a vědomě ho posouvej.
- **Domov podle dosahu.** Jeden běh drží brief běhu a zaniká sám jeho koncem. Jedna
  jednotka drží sekci ve svém `CLAUDE.md`. Celý ekosystém drží tutéž sekci v osobní
  vrstvě. Jedno omezení, jeden domov; ostatní kanály nanejvýš odkazují.
- **Položka po datu je neplatná z definice.** Agent se jí neřídí a flagne ji vlastníkovi
  souboru k odstranění.

Sekce existuje jen tehdy, když je neprázdná. Prázdný stav neznamená hlášku „momentálně
žádná omezení", znamená, že sekce v souboru vůbec není; jinak by se za nic platil nájem
v každé session.

Protipříklad, který fungoval celou dobu a byl vzorem: totéž omezení zapsané jako součást
zadání jednoho běhu vypršelo samo, koncem toho běhu. Aktéra, moment i podmínku mělo
implicitně.

## Jak se to hlídá dnes

Nehlídá to stroj a je to vědomé rozhodnutí, ne mezera. Varianta s vyhrazeným souborem
a spouštěčem na začátku session by měla garantované doručení, ale zaváděla by nový
mechanismus kvůli třídě omezení, která se dá vyřešit formátem. Je zapsaná jako trigger
k přehodnocení, ne jako plán.

To, co se změnilo, je **polarita selhání**. Bez data je výchozí stav přetrvání a zánik
stojí sweep napříč lokacemi. S datem je výchozí stav zánik a přetrvání stojí jeden vědomý
zápis. Škoda ze zapomenutí klesla ze „sedmi týdnů tiše platícího pokynu" na „mrtvý řádek,
který nikoho neřídí a při prvním přečtení se označí".

Test selhání je zapsaný předem, aby se za měsíc nedalo hádat: pokud se příští dočasné
omezení objeví v paměti nebo ve víc než jednom souboru, pravidlo se nepropsalo do místa,
kde se rozhoduje. Pokud položka s prošlým datem přežije víc než jednu session bez
označení, polarita nefunguje a na stole je varianta se spouštěčem.

## Co na tom pořád není dořešené

Vestavění pomocní agenti načítají projektový kontext jinak, takže se k nim sekce s TTL
nedostane; pro ně platí, co platilo vždycky - omezení musí nést zadání. A pravidlo stojí
na formátu, ne na kontrole: kdo napíše prozaickou podmínku, nic ho nezastaví, jen se to
při čtení pozná na první pohled.

## Kde si to v tomhle balíčku ověříš

- `operations/changesets/2026-08-08-docasna-omezeni-ttl-or10.md` - včetně poznámky
  o tom, že se do osobní vrstvy tímhle lístkem nezapsalo nic, protože sekce vzniká až
  s prvním živým omezením.
- Tentýž lístek má v dodatku druhou vadu z téhož dne: jeho vlastní ověřovací blok používal
  sloveso, které jazyk nezná. Není to náhoda, že je vidět - dodatek k vydanému lístku je
  jediná povolená cesta opravy a je dražší než napsat to rovnou.
- [`docs/normy.md`](../normy.md), OR-10, mechanismus 4.
