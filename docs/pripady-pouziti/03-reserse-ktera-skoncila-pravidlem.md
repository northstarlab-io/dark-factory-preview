# Rešerše, ze které vzniklo pravidlo, a měření, které skoro nevzniklo

**Kdy:** 28. července 2026, s dohrou do 9. srpna
**Kde:** naše vlastní prostředí
**Typ práce:** znalostní úloha od otázky přes rešerši a oponenturu k zapsanému pravidlu

## Zadání

Otázka zněla prakticky: podle čeho volit, na jak silném modelu a s jak velkým rozpočtem na
přemýšlení pustit konkrétní úkol. Do té doby se to dělalo zvykem, tedy skoro všechno jelo
nahoře, protože nahoře se člověk nespálí. To je obhajitelná politika a zároveň politika,
která nikdy nezjistí, kolik stojí.

Tenhle případ je tu proto, že vypadá jinak než dva předchozí. Nevzniká z něj software.
Vzniká z něj věta v normě, kterou pak stroj vynucuje, a měření, které tu větu má za rok
buď potvrdit, nebo poslat pryč.

## Jak se práce rozdělila

- **Rešeršní role, tři běhy paralelně,** nad vlastní sběrnou evidencí přečtených věcí:
  118 položek za tři měsíce, z toho 14 relevantních a 6 částečně, dvě duplicity. Vedle toho
  samostatná rešerše veřejných zdrojů, protože vlastní sbírka je zaujatá tím, co kdo četl.
- **Dvě strategické role psaly stanoviska nezávisle na sobě.** Ne pro pluralitu názorů, ale
  proto, že společné psaní vyrábí kompromis dřív, než je co porovnávat.
- **Orchestrátor** složil stanoviska a rozdíly nechal viditelné.
- **Role návrhu definic** zapsala výsledek do definic a norem. Agent svou vlastní definici
  needituje, a tohle pravidlo tu má praktický důsledek: změnu, která se dotýká chování rolí,
  napsal někdo jiný než ten, koho se týká.
- **Znalostní role** zaznamenala výstup a označila zpracované zdroje, s kontrolou po zápisu
  položku po položce.

## Co odvedla agentní vrstva

Pravidlo se dvěma nezávislými osami: **který model** a **kolik prostoru na přemýšlení**.
Do té doby se to bralo jako jedna osa, což je pohodlné a nepravdivé; levný model s velkým
prostorem na přemýšlení i drahý model s malým jsou legitimní kombinace a každá řeší jinou
třídu úloh.

K tomu tři věci, které z toho udělaly použitelné pravidlo místo doporučení:

- **Směr kalibrace podle rizika.** Levná a vratná práce začíná dole a stoupá podle
  sebehlášení. Drahá a nevratná začíná nahoře a sestupuje se až podle naměřené kvality.
  Pojmenovat směr je součást rozhodnutí.
- **Výchozí hodnota leží na straně ohraničené škody.** U orchestrace stojí zapomenutý
  downgrade peníze, tedy ohraničenou částku. Zapomenutý upgrade stojí kvalitu rozhodnutí,
  což je neohraničené a špatně vidět.
- **Metrika je cena za přijatý výstup**, ne cena za token. Výstup, který se musel
  přepracovat, byl drahý bez ohledu na to, jak levně se vyrobil.

Vedle toho se změřila jedna věc, o které se do té doby jen mluvilo: kolik z kontextu
spotřebují pravidla, která se načítají v každé session. Náklad tam není v penězích, ale
v místě, které pak chybí na práci.

## Kde do toho vstoupil člověk

Rozhodl alokaci a rozhodl proti jednomu z doporučení. Obě strategické role nezávisle na
sobě upozornily, že drahé výchozí nastavení bez měření vypíná kalibrační smyčku: nikdo
nikdy nezjistí, jestli by to šlo levněji, protože levnější varianta nikdy nepoběží.
Člověk drahý default u dvojice rolí ponechal, ale zároveň nechal založit slepé srovnání
s termínem a s pravidlem, kdy se smí sestoupit. To je poctivější výsledek než tichý souhlas
na jednu i druhou stranu.

## Co z toho je

Norma, která je v tomhle balíčku k přečtení, tabulka výchozích hodnot per role a slepé
srovnání s datem vyhodnocení. Součástí normy je test o jedné větě: „Kdyby tenhle úkol běžel
o stupeň níž na kterékoli z těch dvou os, poznal bych to na výstupu?"

## Co bylo těžké a co se předělávalo

**Norma si nařídila měření a to měření týden neexistovalo.** Pravidlo z 28. července říká,
že se každé spuštění zapisuje do provozního záznamu. V hlavní jednotce ten soubor nevznikl.
První tvrdá data přišla 5. srpna a odjinud, protože si je jiná jednotka založila sama při
vlastním běhu; v hlavní jednotce vznikl záznam až 9. srpna. Kdyby se to nechytilo,
vyhodnocení experimentu by běželo nad dojmy a vypadalo by přitom jako měření. Zapsané
pravidlo bez zapsaného mechanismu je přání.

**Sebehlášení agenta o vlastní náročnosti se ukázalo jako slabý signál.** V jednom
pozdějším běhu napsalo všech 32 spuštění, že nastavení sedělo. Nula doporučení v obou
směrech není kalibrace, je to ticho. Vlastní výkon posuzuje ten, kdo nemá s čím ho
porovnat.

**Plán prohrál s výchozí hodnotou v definici.** Devátého srpna předepsal plán běhu, že se
nejvyšší tier nepoužije. Tři spuštění na něm přesto běžela, protože orchestrátor u nich
model neuvedl výslovně a role si vzaly svůj vlastní default. Nikdo nic neporušil a pravidlo
stejně neplatilo. Věta, která z toho zbyla: **plán prohraje s definicí pokaždé, když se
mlčí.**

**A jedna nedodělaná věc, kterou je fér přiznat.** Metrika „cena za přijatý výstup" je
zapsaná, ale neměří se automaticky. Dnes se pozná zpětně z toho, co se muselo přepracovat.
Do vyhodnocení slepého srovnání je volba modelu poučený odhad, ne výsledek měření, a je to
tak napsané i v přehledu toho, co nefunguje.

## Kde si to v tomhle balíčku ověříš

- [`docs/normy.md`](../normy.md), OR-07 celé včetně tří vrstev rozhodování, směru kalibrace
  a testu na konci.
- `knihovna/agents/karpathy.md` - role, která tabulku alokace vlastní a je vědomě mimo
  delegační smyčku, aby neposuzovala vlastní zadání.
- `knihovna/agents/rezac.md` a `knihovna/agents/roger-m.md` - dvojice, které se to pravidlo
  týká nejvíc. V obou je zapsaná i sebekontrolní otázka, kterou si mají položit; napsal ji
  do nich někdo jiný, ne ony samy.
- [`docs/CO-JE-DARK-FACTORY.md`](../CO-JE-DARK-FACTORY.md), sekce „Co dnes nefunguje", bod
  o kvalitě měřené tím, na co se člověk zeptá.
