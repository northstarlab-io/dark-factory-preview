# Vlastní pohled na provoz, postavený za jeden běh

**Kdy:** 5. srpna 2026, jeden souvislý běh
**Kde:** naše vlastní prostředí, nástroj běží lokálně
**Typ práce:** postavení interního nástroje od zadání po dokumentaci, včetně verifikace

## Zadání

Stav provozu se dal zjistit jen čtením souborů a doptáváním. Každá jednotka o sobě hlásí
stav v pevné hlavičce, takže data existovala, jen je nikdo nesčítal. Zadání znělo postavit
nástroj, který ty soubory přečte z disku a zobrazí je: co je pozadu, co chce pozornost, jak
je systém poskládaný a co čeká na rozhodnutí člověka.

Podmínka, která zadání celé určila: **nástroj nesmí být druhý zdroj pravdy.** Nesmí si nic
ukládat stranou, nesmí nic dopočítávat a nesmí předstírat, že ví, co neví.

## Jak se práce rozdělila

Orchestrátor jednotky rozdělil práci do tří vln a celkem 32 běhů specialistů.

- **Návrh:** datová a bezpečnostní architektura, doménový model, informační architektura,
  komponentní rozvržení, verzování a hranice vůči produktu, ze kterého se přebíral kód.
- **Stavba:** server a bezpečnostní hranice na vyšším nastavení, sběrače dat nad zamrzlými
  rozhraními na nižším. Zamrzlá rozhraní jsou podmínka, ne detail; kdyby syntéza nezapsala
  tvary dat doslova, levnější běhy si je vymyslí po svém a paralelní práce se nesejde.
- **Verifikace:** čtyři nezávislé lupy naráz (bezpečnost, poctivost dat, empirie,
  srozumitelnost), zadané tak, aby hledaly selhání, ne potvrzení.

## Co odvedla agentní vrstva

Sedm obrazovek, 17 rozhraní, žádná runtime závislost. Čerstvý klon do dočasného adresáře
naběhl za jednu sekundu bez instalace balíčků a bez sítě a vracel stejná data jako běžící
instance. K tomu čtrnáct dokumentů: uživatelských, provozních, technických.

Nejcennější věc z toho běhu není obrazovka, ale pravidlo zapsané do kódu. **Každý údaj nese
obálku kvality s pěti hodnotami: měřeno, odvozeno, proxy, návrh, neznámo.** Neznámo se nikdy
nezobrazí jako nula a nula sečtená s neznámem dává neznámo. Každý blok čísel nese cestu ke
zdroji a čas čtení.

Ta obálka hned první den něco stála. Zadání chtělo ukazovat vytíženost rolí. Sběr zjistil,
že na disku pro to nejsou data: žádný log spuštění, žádné měření času. Náhradní ukazatel
z počtu výskytů jmen v souborech byl zamítnutý, protože autorské hlavičky mají pokrytí
kolem poloviny i v nejlépe vedeném adresáři, takže by to bylo číslo s tváří měření
a s obsahem dojmu. Nástroj místo čísla ukazuje výčet nalezených souborů a otevřeně píše,
že se to nemění.

## Kde do toho vstoupil člověk

Zadal, převzal a rozhodl tři věci, které agent rozhodnout neměl.

- **Označení vydání.** Politika ho váže na průchod testem, ten prošel, a přesto tag nevznikl.
  Agent to zdůvodnil tím, že označení vydání je jednosměrné a člověk ten nástroj ještě
  neviděl. Tohle považuju za správnou hranici, ne za opatrnost.
- **Přihlašování.** Nástroj běží lokálně bez přihlášení a vidí všechno na tomtéž disku.
  Pro lokální běh je to vědomě přijaté a napsané nahlas; jakékoli vystavení mimo ten
  počítač je rozhodnutí člověka a vlastní vrstva, která neexistuje.
- **Vizuální kontrola.** V běhu nebyl k dispozici prohlížeč. Kontrasty jsou spočítané
  a doložené čísly, ale spočítat kontrast a vidět obrazovku není totéž, takže tahle část
  zůstala člověku a je to v reportu napsané.

## Co z toho je

Nástroj běží lokálně a čte stav z disku při každém načtení, takže nemůže tiše zestárnout.
Vedlejší produkt je cennější, než vypadá: poprvé vznikl souvislý záznam o tom, na jakém
nastavení který úkol běžel a proč. Do té doby by revize té volby běžela nad dojmy.

## Co bylo těžké a co se předělávalo

**První věta první obrazovky byla nepravdivá.** Souhrnný verdikt tvrdil, že je platforma
sladěná, přestože sladěná skoro žádná jednotka nebyla, a tvrdil to i ve chvíli, kdy ještě
nepřečetl jediný stav. Našla to adversariální lupa, ne autor. Vada je poučná tím, jak
vznikla: verdikt se počítal z dat, která ještě nedorazila, a výchozí hodnota byla „v pořádku".

**Bezpečnostní model sliboval víc, než kód dělal.** Čtení souborů obcházelo filtr a seznam
povolených cest na dvaceti místech. Statický server testoval umístění souboru na nerozbalené
cestě, takže odkaz mířící ven se vyservíroval. Obojí opraveno tak, že čtení vede jedinou
cestou a cesta se rozbaluje před testem, ne po něm.

**Další tři blokující nálezy ze stejné dávky.** Diagram ukazoval měřenou nulu tam, kde na
disku bylo víc než nula. Kontrola stavu z příkazové řádky padala, protože si pouštěla
vlastní nekešované podprocesy souběžně s hlavním sběrem; po opravě 4,46 s, z cache 18 ms.
Dokumentace tvrdila, že jedna evidence neexistuje, přestože fungovala.

Celkem **30 nálezů, 29 opravených, ani jeden falešný**. To poslední číslo je to podstatné:
lupy nehádaly.

**Test čerstvého klonu selhal napoprvé a stojí za to to napsat.** Klon proběhl dřív, než
byly opravy zacommitované, takže mu chyběl celý jeden blok. Kdyby se autor spolehl na to,
že „to přece běží", tvrdil by v reportu něco, co pro čerstvý klon neplatilo.

**Sebehlášení o zvolené náročnosti se ukázalo jako slabý signál.** Všech 32 běhů napsalo,
že nastavení sedělo. Nula doporučení nahoru i dolů znamená buď dokonalou kalibraci, nebo
signál bez informace; odůvodnění byla věcná, ale skoro vždy přidělené nastavení obhajovala
místo aby ho zpochybnila. Závěr do dalšího kola: pustit tentýž úkol na dvou úrovních
a porovnat výstupy, protože jinak se ze sebehlášení stane rituál.

**A jedna věc, která zůstala nedodělaná záměrně.** Verifikace byla adversariální, ne
regresní. Automatická testová sada neexistuje, takže první úpravu po tom běhu nemá co
zachytit. Je to zapsané jako první položka další verze, ne jako dokončená práce.

## Kde si to v tomhle balíčku ověříš

Sám nástroj tady není, takže z tohohle casu si nepřehraješ nic. Ověřitelný je vstup,
ze kterého čte, a pravidla, podle kterých vznikl:

- `ukazka-jednotky/operations/status.md` - hlavička v pevném tvaru, ze které se stav sbírá.
  Že sedí, si ověříš přes `bash scaffold/validate.sh ukazka-jednotky`.
- [`docs/normy.md`](../normy.md), OR-03 (kontrakt hlavičky) a OR-07 (volba modelu a náročnosti
  včetně sebehlášení, které tenhle case zpochybnil).
- [`docs/casy/05-cislo-verze-psane-rukou.md`](../casy/05-cislo-verze-psane-rukou.md) - proč
  se čísla čtou ze zdroje a nepíšou rukou. Nástroj z tohohle casu stojí na témž pravidle.
