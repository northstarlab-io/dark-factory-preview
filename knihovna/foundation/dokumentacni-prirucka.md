# NSL dokumentační příručka

> Registr žánrů, tonální pravidla, šablony a glosář pro veškerou dokumentaci, kterou čte uživatel produktu NSL. Je to zdroj, na který ukazují pilíře deklarace `Naloženo:` per OR-11 (zúžená brána Komenského).
>
> **Vlastník:** Komenský. Schvaluje Stanislav. Rozšiřuje se průběžně, ne najednou.
> **Status:** minimální verze, 3. 8. 2026. Co v ní zatím není, je vyjmenované na konci.
> **Kdo ji konzumuje:** Komenský před psaním nového dokumentu; kdokoli, kdo do produktové dokumentace zapisuje; orchestrátor při kontrole výstupu.
>
> `Naloženo: tón [definice kvality zadavatele, kompetenční mapa sekce 1 plus NSL styl], cílovka [profily čtenářů v sekci 2 této příručky], příklady [reálné nálezy v dokumentaci nasazené u klienta], struktura [Diátaxis plus kompetenční mapa sekce 3.11]`

## 1. Jak se příručka používá

Tři kroky, pokaždé stejné:

1. **Urči žánr** podle registru v sekci 2. Když dokument sedí na dva řádky tabulky, jsou to dva dokumenty.
2. **Vezmi šablonu** ze sekce 5. Nový dokument nikdy nezačíná prázdnou stránkou.
3. **Před odevzdáním projdi kontrolu** ze sekce 7.

Do/don't banka v sekci 4 není teorie k přečtení. Je to referenční materiál pro moment, kdy nevíš, jestli je věta dost dobrá. Najdi nejbližší pár a porovnej. V tomhle balíčku sekce 4 chybí, důvod je u jejího nadpisu.

## 2. Registr žánrů

Sedm žánrů, které v NSL reálně vznikají. Sloupec Diátaxis říká, ze kterého kořene žánr vyrůstá; sloupec Nikdy uvnitř je to, co dokument okamžitě rozbije.

| Žánr | Publikum | Otázka čtenáře | Diátaxis | Nikdy uvnitř | Šablona |
|---|---|---|---|---|---|
| **Instalační návod** | Koncový uživatel, netechnik, na vlastním Macu, poprvé nebo po přeinstalaci | "Jak to dostanu do počítače, aniž bych něco rozbil" | Tutorial | Volby a varianty, technické alternativy, teorie architektury | 5.1 |
| **Uživatelský manuál** | Koncový uživatel po instalaci, vrací se opakovaně | "Jak s tím pracuju den po dni" | How-to + reference | Instalační kroky, příkazy do Terminálu, konfigurační soubory | 5.1 pro postupové části |
| **Technický manuál pro správce** | Správce platformy u klienta, technik NSL, auditor | "Jak to funguje uvnitř a jak to rozšířím" | Reference + explanation | Cokoli, co potřebuje koncový uživatel (jinak to hledá na dvou místech) | vlastní, mimo tuto verzi |
| **Runbook** | Kdokoli uprostřed práce nebo uprostřed problému, často pod tlakem | "Provedeš mě tím teď hned" | How-to, provozní podoba | Vysvětlování mezi kroky, odrážky místo čísel | 5.2 |
| **Poznámky k vydání** | Koncový uživatel, který dostal novou verzi | "Co se mi změnilo a musím něco udělat" | Explanation krátce + how-to odkazem | Interní názvy souborů, funkcí a komponent; seznam commitů | 5.3 |
| **Texty stavů v produktu** | Uživatel, který právě něco vidí na obrazovce | "Co se stalo a co s tím" | How-to v miniatuře | Kód chyby v hlavní větě, technický žargon, vina uživatele | 5.5 |
| **Glosář produktu** | Oba předchozí plus agentní session | "Jak se to jmenuje a je to totéž co támhleto" | Reference | Instrukce, doporučení, postupy | sekce 6 |

**Rozhodovací pravidlo, když si nejsi jistý.** Zeptej se, co čtenář dělá rukama ve chvíli, kdy text čte. Instaluje (instalační návod), pracuje (uživatelský manuál), řeší problém (runbook), právě aktualizoval (poznámky k vydání), kouká na obrazovku a je zaseknutý (text stavu), ověřuje si slovo (glosář). Když odpovědi vyjdou dvě, jsou to dva dokumenty.

**Profily čtenářů** pro pilíř cílovka v deklaraci `Naloženo:`:

- **Koncový uživatel u klienta.** Dospělý profesionál ve své profesi, netechnik. Nezná slovo repozitář. Má oprávněný strach, že když udělá něco špatně, přijde o práci nebo o data. Čte česky, skáče, nečte odshora.
- **Správce platformy u klienta.** Umí Terminál, nezná vnitřek našeho kódu. Potřebuje přesnost a úplnost, ne opatrné vysvětlování.
- **Technik NSL.** Zná ekosystém, hledá konkrétní fakt. Nejvíc mu pomůže přesný nadpis a odkaz na zdroj pravdy.

## 3. Tonální pravidla

### 3.1 Registr

Vědomě nudný a věcný. Dokumentace nic neprodává a nikoho nebaví.

- **Rozkaz ve druhé osobě množného čísla, aktivní rod.** "Klikněte na `Clone`." Nikdy "je třeba kliknout", "klikneme", "bude provedeno kliknutí".
- **Jedna věta, jedna informace.** Souvětí se třemi vloženými větami je hlavní důvod, proč čtenář nerozumí napoprvé.
- **Jeden termín pro jednu věc.** Střídání Cockpit / kokpit / platforma / přehled je pro netechnika signál, že jde o čtyři různé věci. Synonymum je v beletrii ctnost, v dokumentaci vada.
- **Nulová vata.** Ven jde jako první: úvod, který nic neříká ("V této kapitole se seznámíme s tím, jak…"); zdvořilostní vycpávka ("Nyní prosím pokračujte tím, že…"); zdůvodňování uprostřed kroku; opakování pro jistotu; "jak jsme viděli výše".
- **Druhý průchod je škrtací.** Nesmí skončit delším textem než první. Stavy selhání jsou ze škrtání vyjmuté.

### 3.2 Zjednodušuj předpoklady, ne identifikátory a ne dospělost čtenáře

Zjednodušuje se **předpokládaná znalost a délka věty**. Nikdy se nezjednodušuje:

- **Identifikátor.** Název tlačítka, cesta, příkaz a název souboru se píší doslova tak, jak je uživatel vidí na obrazovce, v kódovém stylu. Uživatel hledá očima shodu, ne překlad. "Klikněte na to modré nahoře" je srozumitelné a zároveň nepoužitelné.
- **Dospělost čtenáře.** Netechnik není dítě. Text, který se čte jako pohádka, ubere uživateli důstojnost a s ní důvěru v celý dokument.
- **Stav selhání.** Nejkratší verze návodu popisuje jen šťastnou cestu a je zároveň ta nejhorší.

**Test každého textu:** rozumí tomu člověk, který o tom nikdy neslyšel, a zároveň by se necítil trapně, kdyby mu někdo koukal přes rameno? Obojí musí platit současně.

### 3.3 Ubezpečení je funkce, ne vlídnost

Když krok vyvolává strach ze ztráty dat, přístupů nebo práce, patří k němu věta, která ten strach adresuje konkrétně. Ne "nebojte se", ale "co přesně se stane a co přežije". Bez ní se uživatel na kroku zastaví a zavolá.

### 3.4 NSL styl (platí bez výjimky)

- Česká diakritika vždy.
- Krátká pomlčka `-` ve všech funkcích. Žádné em-dashe, žádné en-dashe. Je to vědomá odchylka NSL od ČSN 01 6910:2014, ne chyba k opravě.
- Žádný horizontální divider `---`. Sekce se oddělují nadpisem.
- Standardní Markdown, relativní odkazy, žádné wikilinks a transclusions per `project-init/04-ai-safe-vault.md`.
- **Zakázaná slova NSL** včetně odvozených tvarů: unikátní, jediný, nejlepší, revoluční, průlomový, transformativní, komplexní jako catch-all, enterprise jako adjektivum, interim / konzultant / poradce v materiálech pod NSL jménem.
- **Zakázaná měkkost:** stačí jen, jednoduše, prostě, snadno, rychle ve smyslu slibu. Uživateli, kterému to nejde, ta slova říkají, že je hloupý.
- **Anti-fear.** Žádná urgence, žádné strašení tím, co se stane, když uživatel neaktualizuje. Varování se píše věcně: co se stane a jak tomu předejít.
- **Žádný secret v textu**, ani jako příklad (OR-02). Token, heslo ani klíč v dokumentaci nemají co dělat.

### 3.5 Pravidla pro druhé publikum (agentní session)

- **Jeden fakt jeden domov, jinde odkaz** (OR-10).
- **Nadpis nese odpověď, ne téma.** "Když se instalace zastaví na přihlášení ke Claude" je lepší než "Řešení problémů".
- **Žádná informace jen v obrázku.** Screenshot je doplněk kroku, nikdy jeho nosič.
- **Sekce krátké a samostatně srozumitelné.** Čte se úryvek, ne celý soubor.

## 4. Do/don't banka

V tomhle balíčku sekce chybí a je to vidět schválně. Byla postavená z reálných vět v dokumentaci
nasazené u klienta - osm párů ve tvaru takhle ne, takhle ano, a proč. Anonymizovat by ji znamenalo
vymyslet náhradní příklady, a vymyšlený příklad nese pravidlo bez důkazu. Zbytek příručky
na ni odkazuje; ten odkaz je ponechaný, aby bylo zřejmé, co tu není.

## 5. Šablony

### 5.1 Krok instalačního návodu nebo postupové části manuálu

```markdown
N. **<Akce jednou větou v rozkazu, druhá osoba množného čísla>.** <Jedna doplňující
   věta, jen když bez ní krok nejde provést.>

Ověření: <co uživatel vidí na obrazovce, když krok proběhl. Konkrétní, viditelné,
ne "instalace proběhla úspěšně">.
Když to nevyjde: <co uvidí místo toho> - <co má udělat>.
```

Pravidla:

- Jeden krok = jedna akce. Krok se dvěma akcemi se v půlce přeruší.
- Identifikátory doslova a v kódovém stylu: název souboru, popisek tlačítka, cesta ve složkách.
- Žádné vysvětlování mezi kroky. Kontext patří nad seznam do dvou vět nebo do odkazu.
- Řádek `Když to nevyjde:` se u kroku, který může selhat, nevynechává ani při škrtání.
- Sekce "Když něco selže" na konci dokumentu sbírá jen to, co se nedá přiřadit k jednomu kroku.

### 5.2 Runbook

```markdown
# <Situace čtenáře, ne název procesu>

**Použijte, když:** <vstupní podmínka, jedna věta>
**Hotovo, když:** <výstupní stav, který jde ověřit očima>
**Trvá:** <odhad>
**Bezpečně přerušit můžete:** po krocích <čísla>
**Opakování kroku:** <bezpečné / nebezpečné u kroků N, M a proč>

1. **<Akce>.**
   Ověření: <...>
   Když to nevyjde: <...>

2. **<Akce>.**
   Pokud vidíte <A>, pokračujte krokem 3.
   Pokud vidíte <B>, jděte na krok 7.

3. ...
```

Pravidla:

- **Očíslované kroky, nikdy odrážky.** Číslo je adresa, na kterou se dá odkázat při dotazu.
- **Rozhodovací bod je samostatný řádek**, ne varianta schovaná v odstavci.
- **Vstupní podmínka a výstupní stav nahoře.** Bez nich čtenář přečte celý dokument, aby zjistil, že mu nepatří.
- **Žádná sekce "řešení problémů" na konci.** Stav selhání patří ke kroku, který selhal.

### 5.3 Zákaznické poznámky k vydání

```markdown
# Co je nového ve verzi <X.Y.Z> (<datum>)

## Co uvidíte jinak

- **<Změna očima uživatele>.** <Co to znamená v praxi, jedna věta.>
- **<Změna očima uživatele>.** <...>

## Co musíte udělat

<Nemusíte nic dělat.> NEBO <očíslované kroky nebo odkaz do návodu>

## Co se nemění

<Jedna až tři věty o tom, co zůstává stejné. Je to nejčastější nevyslovená otázka.>

## Změněné kapitoly návodu

- [<Kapitola>](cesta.md) - <co je v ní nově>
```

Pravidla:

- **Řazeno podle dopadu na uživatele**, ne podle typu commitu a ne podle velikosti změny v kódu.
- **Bez interních názvů** souborů, funkcí, komponent a čísel úkolů.
- **Sekce Změněné kapitoly návodu se nevynechává.** Distribuce klonem znamená, že uživatel má návod ve své verzi; bez tohoto seznamu je aktualizace dokumentace neviditelná.
- Rozhraní k Humblovi: vstupem jsou changesety, ne git log. Redakce je brána na vydání, ne přepis všeho.

### 5.4 Pole pro lidskou větu v changesetu

Vyplňuje **autor změny**, ne Komenský a ne Humble. Tři otázky, ne volné pole.

```markdown
### Pro uživatele

1. Co uživatel uvidí jinak?
   >
2. Musí kvůli tomu něco udělat?
   > Ne. / Ano: <co přesně>
3. Kterých obrazovek nebo kapitol návodu se to týká?
   >
```

Pravidla pro autora:

- Piš větu pro uživatele, ne pro tým. Bez názvů souborů, funkcí a čísel úkolů.
- **"Uživatel nic nepozná" je platná odpověď** na první otázku. Vnitřní změna bez viditelného projevu se do poznámek k vydání nedostane a je to v pořádku.
- Když neumíš odpovědět na otázku 3, pravděpodobně se změnil návod a nikdo o tom neví. Napiš to.

### 5.5 Text stavu a chybové hlášky

```
<Co se stalo.> <Co s tím udělat.>
```

Pravidla:

- **Maximálně dvě věty.** Fakt a akce. Třetí věta se přidává jen tehdy, když důsledek není z první věty zřejmý.
- **Technický detail za odkaz** (`Zobrazit detail`, `Zobrazit příkaz`), nikdy do hlavní věty.
- **Nikdy vina uživatele.** Ne "zadali jste špatnou hodnotu", ale "hodnota nesedí, očekává se <formát>".
- **Terminologie z glosáře**, totožná s manuálem.
- Tři typy, které se nejčastěji zapomínají: prázdný stav ("Tady zatím nic není. <Jak sem něco dostat.>"), stav čekání ("Pracuje se na tom. <Co uvidíte, až to doběhne.>"), stav "nepodařilo se zjistit" ("Nepodařilo se ověřit, jestli je k dispozici nová verze. Zkuste to za chvíli, nebo napište správci platformy.").

## 6. Glosář seed

Most mezi interním a klientským slovníkem. Zapsaný na jednom místě, jinak se interní pojem prosákne do klientského textu.

| Interní termín | Klientský termín | Definice pro klienta | Nikdy neříkat klientovi |
|---|---|---|---|
| STUDIO jednotka, průvodce | **asistent** | Parťák pro celou oblast; otevřete ho a pracujete s ním. Má vlastní kartu a tlačítko. | průvodce, jednotka, studio |
| agent (Claude Code agent uvnitř jednotky) | **specialista** | Odborník, kterého si asistent přizve na pomoc. Přímo ho nespouštíte. | agent, subagent |
| dávkový agent, skill vystavený tlačítkem | **automat** | Úkon, který na spuštění proběhne pokaždé stejně a doručí výsledek. | runbook, skill, dávka |
| skill | (nezobrazuje se) | Stavební část automatu. Uživateli se neukazuje. | skill |
| tenant | **platforma** | Vaše instalace se všemi asistenty a automaty. | tenant, instance |
| repozitář (repo) | **vlastní kopie ve vašem počítači** | Složka projektu s historií změn. Termín repozitář ukotvit jednou v glosáři dokumentu, dál nepoužívat. | repo bez ukotvení |
| klonovat | **stáhnout kopii** | Stáhnout kopii do svého počítače. V kroku, kde uživatel mačká konkrétní tlačítko, se jeho název píše doslova. | naklonovat bez vysvětlení |
| MCP server, konektor | **napojení na firemní paměť** | Bezpečné napojení asistenta na znalostní bázi. | MCP bez ukotvení |
| knowledge base | **firemní paměť (znalostní báze)** | Zápisy a znalosti firmy, ze kterých asistenti čtou. | KB jako zkratka bez rozepsání |
| workspace | **pracovna** | Místo, kde asistentovi leží podklady a výstupy. | workspace |
| session | **rozhovor** | Jedno okno rozhovoru s asistentem. Zavřením končí. | session |
| interní runbook | **postup (POS)** | Zapsaná procedura v sekci Provoz. | runbook |

**Kanonický zápis jména produktu patří do glosáře taky**, včetně velkého písmene, skloňování a názvů obrazovek. Bez toho se z jednoho produktu stanou v textech tři různě psané věci a uživatel nemá jak poznat, že jde o totéž. Ten řádek je vázaný na konkrétní nasazení, takže tady zůstává prázdný.

## 7. Kontrolní průchod před odevzdáním

Sedm otázek. Když některá vyjde špatně, text ještě není hotový.

1. Je to jeden žánr, nebo se mi tam vloudil druhý?
2. Má každý krok, který může selhat, popsané ověření a stav selhání?
3. Co z toho můžu vyhodit, aniž zmizí informace nebo ubezpečení?
4. Jsou identifikátory doslova tak, jak je uživatel vidí na obrazovce?
5. Používám pro každou věc stejné slovo jako na ostatních místech a sedí to s glosářem?
6. Prošel jsem tím postupem sám? Pokud ne, je v textu označené, co je neověřené?
7. NSL styl: diakritika, krátké pomlčky, žádný `---`, žádné měkké slovo, žádný slib, žádný secret?

Kde to jde, hlídá tohle stroj, ne pozornost. Vale styl NSL zatím neexistuje (viz odložené).

## 8. Co je odloženo do plné verze

Vědomě, ne opomenutím:

- **NSL styl pro Vale** plus `markdownlint` a kontrola mrtvých odkazů. Dokud neexistuje, drží body 5 a 7 kontrolního průchodu ruční disciplína, což je přesně ten stav, který má stroj nahradit.
- **Šablona technického manuálu pro správce** a šablona README repa jako rozcestníku.
- **Rozšíření do/don't banky** o páry z redakce poznámek k vydání a z očisty klientských specifik. Osm párů je seed, ne pokrytí.
- **Postup očisty klientských specifik** jako zapsaný pracovní list (čtyři třídy výskytů a mechanismus per třída). Dnes žije jen v definici Komenského.
- **Seznam otázek od klienta** jako artefakt zpětné vazby. Bez telemetrie nemá dokumentace jinou zpětnou vazbu o svých vadách.
- **Kontrola konzistence glosáře napříč sadou** a jeho vyčlenění z `navod-uzivatelsky.md` do vlastního souboru, aby sloužil víc dokumentům a byl zdrojem pro lint.
