# Tenhle balíček, tedy případ, který držíš v ruce

**Kdy:** 9. a 10. srpna 2026, dodělávky bezprostředně po nich
**Kde:** naše vlastní prostředí, výstup jde ven
**Typ práce:** vydělení části vlastního systému ke sdílení mimo firmu

## Zadání

Dát člověku mimo firmu k přečtení, co tenhle systém je, aniž by s tím odešlo cokoli, co
patří zákazníkům nebo nám. Zadání znělo na první poslech jako kontrola („mrknu, jestli tam
nejsou klientská data") a při prvním měření se ukázalo, že je to stavba: ve zdrojovém
repozitáři je jméno jednoho zákazníka ve víc než stovce souborů.

Ten posun je celý důvod, proč tenhle case píšeme. Rozdíl mezi „projít a začernit"
a „postavit nový artefakt z vybraných částí" je rozdíl mezi hodinou a dvěma dny, a pozná
se jen tak, že to někdo změří dřív, než slíbí termín.

## Jak se práce rozdělila

Čtyři nezávislé pohledy nejdřív, teprve pak stavba.

| Kdo | Co dodal |
|---|---|
| Bezpečnostní role | inventura zdroje: co smí ven, co se přepisuje, co zůstává doma |
| Role kontextu a knihovny | výběr definic rolí a soubor po souboru zdůvodněný verdikt |
| Role vydání | struktura balíčku a spustitelný postup sestavení |
| Dokumentační role | audit dokumentace: co jde ven beze změny, co se přepíše, co se napíše znovu |
| Orchestrátor | sjednocení do jednoho závazného stavebního plánu, včetně rozsudků tam, kde si čtyři vstupy protiřečily |

Teprve pak sestavení, a po něm čtyři verifikační lupy, které četly hotový balíček proti
plánu. Dokumenty z první fáze **ven nejdou** a je to napsané v jejich hlavičce: nesou
počty, jmenné seznamy a mapu citlivého, tedy přesně to, co balíček nemá obsahovat.

## Co odvedla agentní vrstva

**Balíček vznikl vydělením, ne klonem.** Klon by přinesl celou historii včetně klientské
stopy v každém starším commitu; začernění v posledním stavu s tím nic neudělá. Git se
zakládal až nad obsahem, který prošel verifikací, takže neočištěný stav v historii nikdy
neexistoval. Proto `git log` začíná až prvním vydáním balíčku a nic staršího v něm není;
další commity jsou už jen jeho vlastní vydání. Proto je to napsané rovnou v úvodu.

**Inventura našla tři třídy, které stavební plán vůbec neměl.** První: identifikátory naší
znalostní vrstvy v souborech, které strojová klasifikace vedla jako čisté; kvůli nim
přibyla čtvrtá lupa. Druhá: soubory s nulovou strojovou stopou a plnou citlivostí, třeba
doslovné citace návrhu od třetí strany nebo hodnocení produktu jiného dodavatele; kvůli
nim se dokumentace nečetla grepem, ale celá a ručně. Třetí: **odvoditelné počty**, kde
nejzrádnější tvar neobsahuje číslo ani slovo, o které jde. Věta „dva audity měsíčně, každá
role jednou za čtvrtletí" dává čtenáři šest rolí, aniž by tam šestka stála, a to číslo
navíc nebylo pravdivé.

**Verifikace hledala selhání, ne potvrzení.** Čtyři lupy naráz: čistota, identifikátory,
počty a čtenářský test. Nálezy se pak neopravovaly automaticky, ale posuzovaly: 21
opravených, 4 zamítnuté jako falešný poplach nebo jako vědomé rozhodnutí. Druhý den, když
se balíček na pokyn člověka rozšířil o zbytek definic rolí, běhla verifikace znovu a přinesla
dalších 14 oprav a 6 zamítnutí.

## Kde do toho vstoupil člověk

Rozhodl, co jde ven. To je první ze šesti míst, ze kterých se člověk neplánuje odstranit
(výčet je v [`docs/CO-JE-DARK-FACTORY.md`](../CO-JE-DARK-FACTORY.md), sekce „Kde zůstává
člověk"), a tenhle případ ukazuje proč: **obor zákazníka se do textu vrátil oklikou
dvakrát** a člověk
ho oba dny vrátil zpátky. Nešlo o neposlušnost, šlo o to, že se ta informace neskládá
z jedné věty a lupa hledá věty.

Druhý zásah člověka byl změna zadání: původně šla ven necelá polovina definic rolí, pak
padlo rozhodnutí poslat ven všechny. Tím se hranice posunula a s ní i to, co je citlivé,
takže se verifikace musela zopakovat celá. Rozšířit rozsah je levné rozhodnutí, jehož cena
je celá v ověření.

## Co z toho je

To, co držíš: engine ke spuštění, šablona jednotky, vyplněná ukázka, definice rolí, výběr
reálných lístků z jednoho týdne provozu a dokumentace včetně casů. Bez historie, bez
klientských dat, s vlastní řadou verzí, aby se nepletla s verzí platformy.

## Co bylo těžké a co se předělávalo

**Strojový sken byl čistý a nic to neznamenalo.** Sken hledá tvary přístupových údajů.
Jméno firmy žádný tvar nemá, obor už vůbec ne. Kdyby se stavba opřela o zelený výstup
nástroje, odešlo by ven jméno zákazníka ve víc než stovce souborů.

**Nejtvrdší nález nebyla věta, ale osa.** Obor zákazníka nebyl nikde napsaný. Skládal se
z výčtu systémů v jedné definici, z příkladu v šabloně, z jednoho vzoru cesty v runbooku
a z formulace hranice mezi dvěma rolemi. Žádné z těch míst samo o sobě neidentifikuje
nikoho. Dohromady vzniká obrázek. Opraveno sedm míst v sedmi souborech, druhý den dalších
pět, z toho dvě neohlásila ani jedna lupa a našly se vlastním měřením.

**Něco přežilo čtyři lupy.** Dvě místa, kde bylo naše cílové publikum popsané číslem,
prošla celou první verifikací a našla se až druhý den. Čtyři nezávislé pohledy jsou lepší
než jeden a pořád to není důkaz.

**Zachycené výstupy nástrojů zestárly dřív, než se stačily přečíst.** Snímek skenu tvrdil
jiný počet souborů, než vracel živý běh, a po rozšíření balíčku se to zopakovalo. Oprava
není lepší číslo, ale hlavička, která říká, že rozhoduje slovo `[ČISTO]`, ne to číslo za ním.

**Prohlídka slibovala výsledek, který u čtenáře nevyjde.** Jedna zastávka stavěla na výpisu
pořízeném v prostředí, které cílový čtenář nemá. Změřilo se to ve třech různých prostředích
a ukázalo se, že čtenáři místo ukázkového stavu vyjde zeď chybových řádků, protože jeho
stroj nemá naši knihovnu. Opravilo se to **dokumentací, ne kódem**: změkčit fail-closed
chování kontroly kvůli tomu, aby prezentace vypadala lépe, je přesně ta vada, před kterou
varuje case o patro vedle. Výpis se pořídil znovu v prostředí čtenáře a text ho na chybové
řádky předem připraví.

**Drobnost, na které je vidět, že se testovalo jinak, než se používá:** přiložené testy
neměly nastavený spustitelný bit. Uvnitř našeho prostředí je nikdo nespouštěl přes `./`.

**A věc, kvůli které tahle složka vůbec existuje.** Plán běhu nepokryl celé zadání. Úkol
měl v naší evidenci pětipoložkový seznam, plán z něj postavil část a zbytek se dodělával
v následujících dnech. Tenhle text je jedna z těch dodělávek. Kontrola „splnil plán zadání?"
v tom běhu nebyla, protože se všichni dívali na to, jestli plán běží dobře, ne na to,
jestli je celý.

## Kde si to v tomhle balíčku ověříš

- `git log` - historie začíná prvním vydáním balíčku, nic staršího v ní není. Důvod je
  v [`docs/CO-JE-DARK-FACTORY.md`](../CO-JE-DARK-FACTORY.md), sekce „Co dnes nefunguje",
  bod 1.
- [`docs/hranice-baliku.md`](../hranice-baliku.md) - co tu běží, co je jen ke čtení a sedm
  věcí, které tu vědomě chybí, včetně poznámky o chybových řádcích ve frontě.
- `operations/ukazky/` - zachycené výstupy nástrojů i s hlavičkou, která říká, jak se čtou
  a co se v nich smí rozejít s živým během.
- `scaffold/tools/sken-secretu.sh` - pusť si ho: `bash scaffold/tools/sken-secretu.sh .`
  Uvidíš, co hledá, a tím pádem i to, co z tohohle casu nemohl najít.
- [`docs/casy/02-vycet-zakazaneho-je-o-krok-pozadu.md`](../casy/02-vycet-zakazaneho-je-o-krok-pozadu.md) -
  pravidlo, podle kterého se balíček skládal: dovnitř jde jen to, co má vlastní řádek
  v plánu, protože výčet zakázaného je vždycky o krok pozadu.
