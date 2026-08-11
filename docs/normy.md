# Provozní normy

Dvanáct pravidel, kterými se řídí orchestrátoři a specialisté při běžné práci. Nejsou to
zásady ani hodnoty. Každá norma vznikla z konkrétní chyby, má u sebe zapsané, z jaké,
a u většiny z nich existuje mechanická kontrola, která ji hlídá místo pozornosti.

Je to referenční text z patra mechanismů, takže se nečte odshora dolů, ale hledá se v něm.
Když nevíš, na co se dívat nejdřív, vezmi tři normy z třetí zastávky
v [`PROHLIDKA.md`](PROHLIDKA.md) a zbytek nech být.

Tvar je u všech stejný: **pravidlo**, **proč** (co se stane, když se nedodrží),
**test** (věta, kterou si agent položí sám) a **incident** (co se doopravdy stalo).
Poslední pole je to, kvůli kterému normy nezůstávají teorií. Když u nějaké chybí, znamená
to, že vznikla preventivně, a je to u ní napsané.

Architektonická rozhodnutí (jak je systém postavený) žijí vedle v
[`architektura-vrstev.md`](architektura-vrstev.md). Normy říkají, jak se v tom systému
pracuje.

**Kde jsou normy vidět v provozu.** Každá jednotka nese ve svém `CLAUDE.md` zkrácený výtah
těchhle pravidel, aby platila i tam, kde nikdo neotevře plné znění. Podívej se do
`ukazka-jednotky/CLAUDE.md`; kanonické znění je tenhle dokument, výtah je odvozenina.

## OR-01: Subagentovi vždy předej kompletní kontext

**Pravidlo.** Před odesláním zadání subagentovi si projdi checklist: „co potřebuje vědět,
aby úkol vyřešil dobře, bez hádání a bez druhého kola?" Vždy přibal zdroje pravdy
(klíčové dokumenty, harmonogram, rozhodnutí, zadání), parametry (oslovení, tonalita,
jazyk, role vůči protistraně), fixní hodnoty (termíny, čísla, jména), předchozí
rozhodnutí, která subagent nemá v paměti, tvrdá omezení, očekávaný formát výstupu a místo,
kam ho uložit.

Když si nejsi jistý konkrétní hodnotou, **zastav se a ověř ji ve zdroji**. Nestav zadání
na vlastní paměti; paměť driftuje, dokumenty ne. Když subagent hodnotu ze zadání rozporuje,
ber to vážně - může mít zdroj přečtený lépe.

**Proč.** Subagent nemá kontext, který má orchestrátor v hlavě. Chudé zadání znamená
chybnou premisu a chybný výstup. Korekce stojí čas, důvěru a přepnutí kontextu, prevence
stojí jedno přečtení souboru.

**Test.** „Kdyby subagent dostal jen tohle zadání a nic víc, zvládl by to kvalitně bez
doptávání?"

**Incident.** Na jednom klientském projektu briefnul orchestrátor specialistu hodnotou
z paměti, zatímco zdroj říkal jinou. Specialista ji v draftu rozporoval a orchestrátor ji
ve výsledném souboru přepsal zpátky na tu špatnou. Plán, který z toho vznikl, počítal
s pracovním dnem mimo placený rozsah.

## OR-02: Přístupové údaje

**Pravidlo.** Žádný agent nikdy neukládá přístupové údaje (klíče, tokeny, hesla,
credentials služeb) do znalostní báze, do commitnutých souborů v gitu, do plaintextu mimo
ignorované soubory, do nezabezpečené komunikace ani do jakéhokoli sdíleného trvalého
kanálu bez určeného úložiště.

**Když agent najde cizí přístupový údaj, hlásí jen lokaci, nikdy hodnotu.** Opsat hodnotu
do reportu, výstupu nebo chatu znamená zreplikovat ji z jednoho plaintextového místa do
druhého. **Detekce bez zadržení je pořád únik.**

Úložiště se volí podle použití, ne podle zvyku: podle životnosti údaje (session, dlouhodobý,
trvalý), podle sdílení (jeden člověk, tým, víc prostředí) a podle režimu (běžný provoz,
regulovaný provoz). Nejmenší funkční varianta je proměnná prostředí v ignorovaném souboru,
největší je spravované úložiště tajemství.

**Baseline povědomí o rizicích** platí pro každého, kdo pracuje se vstupy z vnějšku nebo
s napojením na cizí systémy: vsunutá instrukce ve vstupu (přímá i skrz načtený obsah),
odčerpání dat přes otrávený zdroj pro vyhledávání, krádež přihlašovacích údajů, kompromis
dodavatelského řetězce u konektorů, obcházení systémových instrukcí, zmatený zástupce.

**Proč.** Kompromitace přístupového údaje má neohraničený dopad. Držet je mimo plaintextové
kanály není opatrnost navíc, je to výchozí hygiena.

**Test.** Před commitem, odesláním nebo sdílením: „mohl by v tom být přístupový údaj? Jde
obsah kanálem, nad kterým mám kontrolu?" Při pochybnosti zastav a ověř zdroj.

**Incident.** Agent našel v cizím obsahu heslo ke sdílenému nástroji. Detekci provedl
správně, ale hodnotu opsal do textu upozornění ve svém výstupu, takže ji z jednoho
plaintextového místa přenesl do druhého. Od té doby je pravidlo „jen lokace" napsané
výslovně, ne odvozené.

**Poznámka k nástroji.** `scaffold/tools/sken-secretu.sh` v tomhle balíčku hledá tvary
přístupových údajů. Nevidí identitu zákazníka, identifikátory znalostní vrstvy ani
ekonomiku firmy. Je to brzda, ne důkaz.

## OR-03: Hlavička stavu jako strojově čitelný kontrakt

**Pravidlo.** Každá jednotka má v `operations/status.md` jako první sekci hlavičku
s pevnými poli. Hlavička končí prvním nadpisem `## Rolling log`.

```markdown
# Status - <jednotka>

**Last update:** YYYY-MM-DD
**Klasifikace:** META | Internal | Client | Personal
**Typ:** Průvodce | Asistent | Projekt | Mini-produkt | Automat
**Slouží:** NorthStar Lab | Dark Factory | žádná
**Fáze:** <F0 Discovery | F1 Bootstrap | Delivery | Pilot | Advisory | Maintenance | Archive>
**Health:** 🟢 | 🟡 | 🔴
**Aktivní úkoly (top 3):**
- <úkol>
**Blokátory:** žádné | <stručně>
**Next milestone:** <co + kdy>
```

**Hodnota pole se čte z jeho deklaračního řádku**, tedy z řádku, který začíná
`**<Pole>:**`, nikdy ze zmínky téhož jména jinde v hlavičce. Pole se v hlavičce běžně
zmiňuje v próze (typicky v `Last update`, když se o něm zrovna píše) a bez tohohle pravidla
by taková věta hodnotu přebila.

**Health.** 🟢 běží podle plánu, 🟡 drobné tření (čeká na rozhodnutí, lehký skluz, externí
závislost), 🔴 blokátor nebo zastavený postup.

**Kdy se aktualizuje.** Při milníku (zavření úkolu, změna fáze, změna blokátoru nebo
zdraví), ne mechanicky po každé zprávě. Hlavička je vždy aktuální souhrn, historie patří
do rolling logu pod ní (viz OR-10).

**Proč.** Stav portfolia se nesbírá dotazováním, čte se ze souborů, které existují stejně
v každé jednotce. Bez kontraktu na tvar hlavičky driftuje každá jednotka po svém a čtecí
vrstva pak ukazuje stav, který nikde neplatí.

**Test.** „Když si někdo zvenčí načte hlavičky všech jednotek, bude v nich ta moje
reprezentovaná správně?"

**Incidenty dva.** První: přehled stavu napříč jednotkami nebyl přesný, protože žádný
kontrakt na tvar hlavičky neexistoval a každá vypadala jinak. Druhý, o poznání
poučnější: kontrola prvního nasazeného pole brala první řádek obsahující jméno pole,
takže zmínka téhož jména v próze shodila hlavičku, která byla zapsaná správně. Pravidlo
o deklaračním řádku vzniklo den po tom nálezu a platí pro všechna pole, ne jen pro to
jedno.

**Kontrola.** `bash scaffold/validate.sh <jednotka>` ověřuje existenci polí, uzavřený obor
hodnot a nepřítomnost řetězené historie. Přísnost jednoho z polí drží konstanta v tomtéž
skriptu; její překlopení z varování na chybu je samostatné rozhodnutí s changesetem, ne
tichá změna.

## OR-04: Přednost specialisty před pohodlím

**Pravidlo.** Když úkol leží v doméně specializované role, orchestrátor **deleguje**,
neexekvuje sám, i když má k dispozici nástroje té domény. Pohodlný přístup k nástroji není
důvod dělat práci specialisty.

**Sám to udělá jen tehdy, když platí alespoň jedna výjimka:**

- **(a)** specialista pro tu doménu neexistuje a jeho zřízení se nevyplatí (jednorázový
  úkol na pár minut),
- **(b)** jde o triviální přečtení nebo dohledání známé hodnoty; nikdy ne o vytvoření,
  úpravu, refaktor nebo návrh,
- **(c)** výslovný pokyn člověka „udělej to sám" v aktuálním turnu,
- **(d)** kruhová závislost (specialista nedeleguje sám sobě).

**Signál anti-vzoru.** Myšlenka „tohle bude rychlejší, když to udělám sám, než spawnovat
subagenta" je spouštěč sebekontroly, ne argument. Pokud si ji myslíš, pravděpodobně jsi
mimo výjimky a máš delegovat.

**Když delegaci omezuje instrukční vrstva nástroje.** Omezení typu „nespouštěj subagenty,
dokud si to uživatel nevyžádá" je podmínka, ne zákaz - vyžádání smí být udělené dopředu
a trvale. Když ho splnit nejde, agent to ohlásí jednou větou a teprve pak práci udělá sám.
Nikdy to neřeší tiše: tichá varianta vypadá jako hotová práce a rozdíl v kvalitě se pozná
až na artefaktu u příjemce.

**Proč.** Pohodlný nástroj tlačí orchestrátora k tomu, aby dělal expertní práci sám. To
degraduje kvalitu (specialista nese metodiku, ne jen přístup k nástroji) a znehodnocuje
investici do role.

**Test.** „Jakou doménu právě obsluhuju? Mám důvod z výjimek (a) až (d)?" Pokud ne,
deleguj a předej kompletní zadání per OR-01.

**Incidenty dva.** První: orchestrátor jednotky opakovaně sám vytvářel a četl obsah ve
znalostní bázi místo toho, aby zavolal specialistu, který tu doménu vlastní; příčinou byl
přímý přístup k nástroji. Druhý: orchestrátor tenanta vyhodnotil omezení instrukční vrstvy
jako nadřazené téhle normě a sám napsal text do klientsky viditelného dokumentu, který
patří roli pro dokumentaci, plus integrační zápis patřící roli pro bezpečnost. Prověřením
se ukázalo, že to omezení nepocházelo z žádné konfigurace, kterou vlastníme. Cena je
měřitelná v kvalitě artefaktu, který týden před akceptací četl majitel klientské firmy.

**Mapa domén** je v [`knihovna/foundation/specialist-delegation-matrix.md`](../knihovna/foundation/specialist-delegation-matrix.md).

## OR-05: Strukturní integrita

**Pravidlo.** Každá operace, která může odpojit nebo zahodit vnořené objekty (přesun
kontejnerové stránky, přepis obsahu, úprava stránky s vnořenými databázemi), má povinný
třídílný postup bez výjimky:

1. **Soupis před operací** se všemi vnořenými objekty a jejich identifikátory.
2. **Operace.**
3. **Ověření hned po operaci** proti soupisu. Chybí-li cokoli, zastav a obnov.

Před destruktivním krokem záloha. Při přepisu obsahu musí nový obsah zachovat značky
vnořených objektů, jinak se odpojí.

**Orchestrátor navíc po sérii takových operací** dělá závěrečnou kontrolu celého zasaženého
stromu proti výchozímu soupisu. Integrita prostředí, na kterém záleží, nesmí stát jen na
tom, co o sobě hlásí agent, který operaci provedl.

**Doplněk: mutace cizího prostředí.** Totéž platí pro jakýkoli zásah do prostředí, které
nevlastníme (cizí znalostní báze, CRM, souborový systém, cloudová konfigurace, cizí
repozitář): plán se suchým výpisem toho, co se změní, výslovný souhlas člověka, provedení,
ověření proti plánu. **Agent připravuje, člověk spouští** - u cizích prostředí bez výjimky.

**Proč.** Čtení před zápisem bez symetrického ověření po zápisu je půlka bezpečnostní
smyčky. Přesun a přepis kontejnerů systematicky riskuje tiché odpojení potomků a bez
ověření to unikne.

**Test.** „Vím, co všechno pod tím objektem viselo, než jsem na něj sáhl? A ověřil jsem po
operaci, že to tam pořád je?"

**Incident.** Podrobně v [`casy/03-odpojene-databaze.md`](casy/03-odpojene-databaze.md).
Migrace ve vlastní znalostní bázi odpojila čtyři databáze i se všemi řádky; zjistilo se to
za dva dny při zápisu, který selhal na archivovaném předkovi. Data byla obnovena celá.

## OR-06: Sekvenční číslování výstupů

**Pravidlo.** Každý nový jednorázový výstup v `team-outcomes/` dostane trojmístný prefix
`NNN-<slug>.md`. Číslo se přiděluje před zápisem jako nejvyšší existující plus jedna; při
dávce sekvenčně, nikdy stejné číslo dvakrát. Přiděluje ten, kdo soubor zapisuje.

**Nečíslují se** stabilní živé dokumenty, na které se odkazuje stálým jménem a které se
průběžně aktualizují (metodické výstupy rolí, runbooky). U nich by číslo pořadí nevyjádřilo
a přejmenování by rozbilo odkazy.

**Ekvivalentní schéma** je povolené: norma je splněná i vlastním schématem projektu, pokud
drží monotónně rostoucí sekvenci viditelnou v názvu souboru a je to zdokumentované v jeho
`CLAUDE.md`. Norma cílí na viditelné pořadí vzniku, ne na konkrétní syntax.

**Forward-only.** Existující soubory se nepřečíslovávají, nová čísla přibývají na konci.
Smíšený stav je v pořádku.

**Proč.** Bez čísel není z abecedního výpisu poznat, v jakém pořadí výstupy vznikaly, a při
rostoucí složce se ztrácí návaznost. Vzor fungoval roky ad hoc, ale bez zapsané normy
driftoval do kolizí a děr.

**Test.** „Kdyby někdo otevřel složku výstupů za rok, pozná pořadí, ve kterém vznikaly?"

**Incident.** Norma existovala, ale nepropsala se do nově založené jednotky, která začala
psát výstupy bez čísel. Kořen byl mechanický: norma žila jen v kořenovém souboru platformy
a šablona nové jednotky ji tehdy nenesla. Od té doby je výtah norem součástí šablony
a nová jednotka ho dostane při založení.

**Kontrola.** `validate.sh` hlásí duplicitní čísla ve složce výstupů jako chybu.

## OR-07: Model a effort podle povahy úkolu

**Pravidlo.** Model i effort se volí **v okamžiku spuštění** agenta; běžící agent za běhu
nezmění ani jedno. Jsou to dvě nezávislé osy a rozhoduje se o obou.

**Tři vrstvy rozhodování:**

1. **Výchozí model v definici role** je model pro typickou práci té role a bezpečná
   záchranná síť, když nikdo nepřemýšlí. Vždy alias, nikdy připnutá verze. Výchozí hodnota
   leží na té straně, kde je škoda ohraničená: u orchestrace a strategické práce stojí
   zapomenutý downgrade peníze (ohraničené), zapomenutý upgrade kvalitu rozhodnutí
   (neohraničenou a špatně viditelnou).
2. **Routing při delegaci** je hlavní páka. Mechanická transformace, dohledání a
   formátování jdou dolů na obou osách. Typická doménová práce jede na výchozím modelu.
   Dlouhý agentický běh a náročné programování si zaslouží vyšší effort. Otevřený úsudek,
   novum a vysoká cena chyby jdou nahoru na modelu, jen pro ten jeden úkol.
3. **Sebehlášení agenta.** Úkol nad tier: dodej výstup a napiš „doporučuji zopakovat na
   vyšším tieru, protože…". Úkol pod tier: dodej a napiš „příště stačí nižší". Je to
   kalibrační signál pro toho, kdo zadává.

**Směr kalibrace se řídí rizikem.** Levná a vratná práce začíná na nejnižším tieru, který
to zvládne, a stoupá podle sebehlášení. Drahá, nevratná nebo nová třída úloh začíná vysoko
a sestupuje se až podle naměřené kvality. Pojmenovat směr je součást rozhodnutí, ne
detail.

**Práh delegace.** Delegace nešetří u drobností závislých na kontextu hlavní session:
subagent startuje s prázdným kontextem a zadání se dělá odkazem na kanonický dokument, ne
opisem.

**Metrika.** Posuzuje se **cena za přijatý výstup** (výstup, který nešel přepracovat), ne
cena za token. Signály toho, že se šetří moc: rostoucí podíl přepracování, rostoucí počet
eskalací na vyšší tier, rozptyl kvality místo průměru.

**Proč.** Kvalita výstupu je podmínka, uvnitř které se cena minimalizuje, nikdy naopak.
Zbytečně vysoký tier je náklad bez přínosu, zbytečně nízký vyrobí korekci dražší než
prevence. „Radši větší model pro jistotu" není jistota; jistota se dělá dobrým zadáním
a ověřovacím krokem.

**Test.** „Kdyby tenhle úkol běžel o tier níž na kterékoli z těch dvou os, poznal bych to
na výstupu?" Pokud ne, jdi dolů.

## OR-08: Priorita instrukčních vrstev

**Pravidlo.** Instrukce přicházejí z víc vrstev naráz. Při konfliktu platí toto pořadí
(vyšší vyhrává):

1. Harness (systémový prompt nástroje) - technická realita, nediskutuje se.
2. Bezpečnost a etika (OR-02, OR-05, zákaz manipulativních technik). Nepřebitelné.
3. Výslovný pokyn člověka v aktuálním turnu.
4. Osobní pravidla držitele účtu (jazyk, styl, tonalita).
5. Platformní normy (tenhle dokument a architektonická rozhodnutí).
6. Kontext tenanta.
7. Kontext jednotky (její `CLAUDE.md`).
8. Kanonická definice role.
9. Skills načtené v turnu.
10. Zadání od orchestrátora.
11. Paměť a předávací dokumenty - referenční materiál, ne příkazy.

**Podmínka není konflikt.** Než začneš řešit konflikt vrstev, ověř, jestli vůbec nastal.
Omezení, které samo nese výjimku („nedělej X, dokud si to uživatel nevyžádá"), je splněné
ve chvíli, kdy vyžádání existuje, a to smí být udělené dopředu a trvale. Teprve když
výjimku splnit nejde, jde o konflikt.

**Sledovatelnost.** Když agent konflikt aktivně řeší, flagne to jednou větou („vrstva X
říká A, vrstva Y říká B, aplikuji Y per OR-08"). Introspektivní otázka „proč jsi to
udělal" je legitimní diagnostika, ale odpověď na ni je hypotéza, ne důkaz; pro ověření
slouží artefakty, ne sebepopis.

**Proč.** Jedenáct vrstev bez kontraktu o pořadí znamená nedeterministické chování při
konfliktu a nemožnost dohledat, čím se agent řídil.

**Test.** „Kdyby kontext jednotky řekl opak definice role, vím bez přemýšlení, co platí?"
Pokud ne, chybí tu řádek.

**Incident k podmínce.** Agent přečetl omezení s výjimkou jako zákaz, vzdal se schopnosti,
kterou měl povolenou, a odvedl horší práci v přesvědčení, že dodržuje pravidlo. Rozdíl
mezi „zákaz" a „podmínka ke splnění" je praktický, ne akademický.

## OR-09: Agent nikdy nepřepisuje vlastní kontrakt

**Pravidlo.** Žádný agent needituje vlastní definici, vlastní spouštěč, konfiguraci ani
pravidla, kterými se řídí. Totéž platí pro definice jiných rolí mimo governance postup.
Zlepšení agent **navrhuje**; zapisuje ho člověk nebo k tomu určená role po lidském
schválení.

**Governované výjimky:** vznik definice nové role po schváleném zařazení a úprava existující
definice po schválení. Obojí dělá role, která definice vlastní.

**Doplněk: vykonávaná konfigurace.** Pod pravidlo spadá i všechno, co se **vykoná** při
běžné práci v repozitáři, tedy git hooky a nastavení, které je aktivuje. Agent hook napsat
smí jako běžnou verzovanou změnu, ale **nesmí ho sám aktivovat na stroji** - instalaci
spouští člověk jedním příkazem a stejným ji vrací. Vykonávaná konfigurace, která se
aktivuje sama, je nerozlišitelná od driftu.

**Proč.** Chrání hranici mezi záměrem (co bylo rozhodnuto) a nánosem (co se přidalo samo).
V systému, kde si agent upravuje vlastní pravidla, nejde odlišit primární vstup od driftu
a mizí auditovatelnost.

**Test.** „Edituju soubor, který definuje moje vlastní chování nebo chování jiné role?"
Pokud ano a nejsem v governance postupu, zastav a navrhni místo zápisu.

## OR-10: Lifecycle obsahu

**Pravidlo - čtyři mechanismy.**

1. **Souhrn versus rolling log.** Hlavička drží jen aktuální stav; historie patří pod ni.
   Řetězení „Předchozí: … Předchozí: …" v hlavičce je zakázané, ruší strojovou čitelnost,
   kvůli které hlavička existuje.
2. **Revize zastarávání.** Pravidelná kontrola živého obsahu: označit zastaralé,
   duplicitní a osiřelé, navrhnout akci, nechat schválit člověkem. Výchozí kadence
   měsíčně, u aktivních jednotek týdně. Runbook je součástí šablony každé jednotky.
3. **Archivace nahrazeného.** Výstup nahrazený novější verzí nebo uzavřenou linií jde do
   `team-outcomes/archive/`.
4. **Dočasná omezení mají TTL s kalendářním datem, ne prozaickou podmínku zániku.**
   Omezení s vlastní dobou trvání nikdy nepatří do kanálů trvalých faktů (paměť, normy,
   definice rolí). Domov podle dosahu: jeden běh drží zadání běhu, jedna jednotka sekci
   `## Dočasná provozní omezení (TTL)` ve svém `CLAUDE.md`, celý ekosystém tutéž sekci
   v osobní vrstvě. Každá položka nese datum `Do YYYY-MM-DD`; **položka po datu je neplatná
   z definice** a agent ji flagne k odstranění. Sekce existuje jen neprázdná. Omezení
   potřebné déle než měsíc není dočasné, je to změna pravidla.

**Kanonizační pravidlo.** Každý fakt má právě jeden domov; ostatní místa na něj odkazují.
Duplikace faktu do druhého dokumentu je vada, ne pohodlí.

**Proč.** Živé dokumenty rostou jen jedním směrem a bez vyřazovacího mechanismu degradují.
Zastaralá informace není neutrální, je to aktivní škoda: někdo na ní postaví chybný výstup.

**Test před zápisem do hlavičky.** „Přežije tahle věta příští aktualizaci, nebo tam po ní
bude překážet?"
**Test dočasného omezení.** „Kdyby tuhle položku už nikdy nikdo neuklidil, přestane sama
působit?" Pokud ne, je ve špatném kanálu nebo jí chybí datum.

**Incident.** Podrobně v [`casy/04-omezeni-ktere-nezaniklo.md`](casy/04-omezeni-ktere-nezaniklo.md).
Dvě položky s výslovně napsanou podmínkou zániku přežily svou platnost o sedm týdnů a jedna
mezitím fakticky zestárla.

## OR-11: Deklarace kontextu před psaním textu pro lidi

**Pravidlo.** Role, která píše prózu pro lidské publikum, si před psaním naloží čtyři
pilíře (tón, cílová skupina, příklady dobrého textu, struktura držící konzistenci) a
**deklaruje je** jedním řádkem na začátku výstupu: `Naloženo: tón [zdroj], cílovka [zdroj],
příklady [zdroj], struktura [zdroj]`. Když neumí pojmenovat zdroj pilíře, negeneruje -
chybí mu kontext a má se doptat (OR-01).

**Hranice.** Brána platí jen na role produkující text pro lidské publikum, ne na projektové
výstupy, rešerše a strukturované artefakty. Role pro dokumentaci má bránu zúženou: deklaruje
u nového nebo přepisovaného celého dokumentu a u poznámek k vydání, ne u drobných editací;
její pilíře míří na dokumentační zdroje, ne na hlas značky.

**Proč.** Pravidlo žije ve vrstvě, kterou čte každá session, vlastní ho jedna role
a vynucují ho agenti sami deklarací. Kontrola dodržení je pohled na jeden řádek výstupu,
takže si ji nikdo nemusí pamatovat. Brána je záměrně tenká - vynucuje deklaraci, ne obsah
pilířů.

**Test.** „Když otevřu libovolný textový výstup, je nahoře řádka `Naloženo:` se čtyřmi
jmenovanými zdroji?"

**Poznámka k balíčku.** Kanonická metodika, na kterou norma odkazuje, v tomhle balíčku
není. Zůstává norma a její stopa: dokumentační příručka v
[`knihovna/foundation/dokumentacni-prirucka.md`](../knihovna/foundation/dokumentacni-prirucka.md)
je jedním z těch zdrojů.

## OR-12: Disciplína changesetů

**Pravidlo - tři povinnosti.**

1. **Kdo dělá změnu s dosahem mimo platformu** (soubory enginu, normy, definice rolí,
   šablony, vydání software), **píše k ní changeset v okamžiku změny**: co se změnilo, koho
   se to týká, co s tím má příjemce udělat, lidská věta a ověřovací test proti profilu
   artefaktu. Commit nese odkaz na číslo changesetu; východisko „bez changesetu, protože…"
   je evidované, ne tiché.
2. **Orchestrátor jednotky spouští na startu session kontrolu fronty** a stav uvede jako
   první položku svého briefu. Frontu buď odbaví, nebo vědomě odloží. Flag „pozadu o N"
   je vidět napříč portfoliem.
3. **Kdo mění kanonický domov faktu**, regeneruje index platformy v témž commitu. Není to
   náhrada changesetu; obě povinnosti odpovídají na jinou otázku. Changeset říká, co má kdo
   převzít. Index říká, co se změnilo ve čtené ploše, tedy v tom, co konzument jen čte
   a nepřebírá.

**Automatické spouštění.** Brána běží sama přes verzované git hooky, které člověk jednou
aktivuje a stejně tak vypne. Bez automatického spouštění je brána sada kontrol, které si
nikdo nespustí.

**Evidované výjimky místo posunu kotvy.** Commit, který branou neprošel a jehož historie se
přepisovat nebude, se pokrývá jmenovitou evidovanou výjimkou plus zpětnou formalizací
obsahu. Posun kotvy promine celý rozsah před sebou, takže po druhém posunu už není co
počítat.

**Proč.** Propagace bez evidence selhala doloženě několika způsoby naráz: zadání, které
šest dní nikdo nepřevzal, žádná odpověď na otázku „na jaké verzi vlastně běžím", drift
oběma směry. Lidská věta napsaná v okamžiku změny nese kontext, který se z git logu po
týdnu nedá rekonstruovat. Evidence zapisovaná výhradně nástrojem a jen po průchodu testem
uzavírá riziko „evidence lže, že jsme synchronní". A index existuje proto, že změna, kterou
konzument nepřebírá a jen ji čte, touhle bránou z konstrukce propadá: za dva týdny sáhlo
16 z 51 commitů na dokumentaci a žádný nevyvolal událost.

**Test před commitem.** „Sahá tenhle commit mimo platformu? Pak buď nese changeset, nebo
evidovaný důvod, proč ne." A druhá věta: „Mění soubor, který je v indexu? Pak nese
i regenerovaný index."

**Incident.** Podrobně v [`casy/01-brana-kterou-nikdo-nespoustel.md`](casy/01-brana-kterou-nikdo-nespoustel.md).

**Kde si mechanismus prohlédneš.** [`operations/`](../operations/README.md) drží kontrakt
formátu a vedle něj třináct reálných lístků z jednoho týdne provozu. Frontu si spočítáš
příkazem `bash scaffold/validate.sh --baseline ukazka-jednotky --line`.

## Kam odsud dál

Normy vznikaly z incidentů a pět z nich je rozepsaných celých v [`casy/`](casy/README.md);
u OR-05, OR-10 a OR-12 vede odkaz přímo od textu normy. Stavbu, ve které tahle pravidla
platí, popisuje [`architektura-vrstev.md`](architektura-vrstev.md). Jak se z poznatku
z provozu stane nová norma a proč ten poslední krok dělá člověk, je
v [`uceni-a-zavedeni.md`](uceni-a-zavedeni.md). Znění, které nese každá jednotka u sebe,
je zkrácený výtah v [`ukazka-jednotky/CLAUDE.md`](../ukazka-jednotky/CLAUDE.md).
