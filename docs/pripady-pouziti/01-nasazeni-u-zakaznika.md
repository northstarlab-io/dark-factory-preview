# Sada rolí nasazená u zákazníka a udržovaná vydáním

**Kdy:** 20. července až 9. srpna 2026, běží dál
**Kde:** stroj zákazníka, tedy prostředí, které nevlastníme
**Typ práce:** převzetí existujícího nasazení, sestavení sady rolí, distribuce a aktualizace

## Zadání

U zákazníka běží software, který jsme mu dodali, a v něm sada agentních definic. Vznikla
tak, jak taková sada vzniká vždycky: kopírováním z naší knihovny, jméno po jménu, ručně.
Fungovala. Zadání znělo dostat ji do stavu, kdy se aktualizace **vydává**, kdy je z jednoho
místa vidět, co u zákazníka smí která role dělat, a kdy se rozdíl mezi naší verzí a jeho
verzí dá přečíst jako číslo místo dohadu.

Audit na začátku našel jádro problému. Definice v klientském repozitáři měly stejná jména
jako naše kanonické, ale byly to samostatné kopie. Na zákazníkově stroji naše knihovna
neexistuje, takže je nešlo mechanicky převést na odkaz do knihovny; tím by se rozbily.
Zároveň se nedaly nechat být, protože kopie se od originálu vzdaluje každým dnem a nikdo
o tom neví.

## Jak se práce rozdělila

| Kdo | Co držel |
|---|---|
| Orchestrátor tenanta | koordinace napříč repozitáři, pořadí kroků, konsenty před zásahem do cizího |
| Bezpečnostní role | model distribuce, oprávnění nástrojů, hranice mezi naším a klientským |
| Role vydání | verzování, kontrakt kompatibility, vydání, protokol aktualizace, migrace a návrat |
| Dokumentační role | uživatelský návod, technický manuál pro správce, poznámky k vydání |
| Role návrhu definic | zápis do definic a jejich tenantních nadstaveb |
| Člověk | volba modelu distribuce, každý zápis do cizího repozitáře, administrátorské úkony |

Hranice mezi rolí vydání a dokumentační rolí se přitom nevymýšlela u tohohle projektu.
Byla vypsaná dřív, z obou stran, a je v tomhle balíčku k přečtení.

## Co odvedla agentní vrstva

**Model distribuce vznikl jako posudek se dvěma variantami, ne jako doporučení jedné.**
Instalovat naši knihovnu k zákazníkovi bylo doktrinálně jednodušší a bylo zamítnuto:
knihovna leží vedle osobní vrstvy držitele účtu a nese i role, které u toho zákazníka
nikdy nepoběží. Zvolilo se generování. Definice u zákazníka je od té doby build output,
ne ručně držená kopie; drift mezi nasazeními se maže tím, že se vygeneruje znovu.

**Oprávnění dostala vlastní vrstvu.** Co smí role u zákazníka volat, se přestalo dědit
z naší knihovny a začalo se rozhodovat na straně nasazení, jmenovitě a s odůvodněním
u každého zákazu. Ten příběh má vlastní case o patro vedle, včetně toho, jak se autorita
musela přesunout ze seznamu zakázaného na seznam povoleného.

**Aktualizace se vydává.** Vydání s číslem, s tagem, s poznámkami psanými pro uživatele
místo výtahu z historie commitů, a s protokolem, kterým si instalace u zákazníka umí říct,
že je pozadu. Průchod od detekce po převzetí se neodhadoval, prošel se ručně a zapsal.

**Dokumentace se psala pro člověka, který produkt používá.** Uživatelský návod, technický
manuál pro správce a šablona jednotky pro zákazníka bez našeho žargonu.

## Kde do toho vstoupil člověk

Na čtyřech místech a všechna zůstávají.

1. **Volba modelu distribuce.** Posudek nabídl dvě cesty s cenou obou; volba je rozhodnutí
   o tom, co dáváme z ruky.
2. **Každý zápis do klientského repozitáře.** Plán, výpis toho, co se změní, souhlas,
   provedení, ověření z čerstvého klonu. Agent připravuje, člověk spouští. Jeden den
   proběhly čtyři takové zápisy, každý stejným postupem.
3. **Administrátorské úkony na straně zákazníka.** Přejmenování repozitáře, klíč ke
   konektoru. Bez nich se dá práce dokončit jen po hranici cizího účtu.
4. **Ukázka zákazníkovi.** Tu nedělá software.

## Co z toho je

Sada u zákazníka běží v ostrém provozu a aktualizuje se vydáním. Jednotka ví, na jaké
verzi běží a kolik změn nepřevzala; číslo je součástí běžného výpisu, ne pátrání
v historii. V nejhustší den převzala evidence 34 lístků napříč jednotkami tenanta bez
jediného selhání testu.

## Co bylo těžké a co se předělávalo

**Dvě vady, které chytila vlastní verifikace.** První bylo rozšíření oprávnění při
generování: role dostala v cizím prostředí nástroje, které v ručně udržované kopii nikdy
neměla. Co se stalo, co to stálo a jak se ta třída hlídá dnes, je rozepsané
v [`docs/casy/02-vycet-zakazaneho-je-o-krok-pozadu.md`](../casy/02-vycet-zakazaneho-je-o-krok-pozadu.md);
sem to nepíšu podruhé. Druhá vada: kontrola driftu byla fail-open. Ručně dopsaný nástroj
v definici procházel, když se z manifestu nepodařilo přečíst seznam nástrojů. Opraveno na
fail-closed, tedy neověřitelné je neplatné, a doplněno jedenácti scénáři, které to zkoušejí
obejít.

**Poloviční změna.** Osmého srpna ležely v repozitáři nadstavby definic, které slibovaly
rolím plnou sadu nástrojů, zatímco tenantní politika přesně ta jména zakazovala. Kdyby se
tehdy generovalo, vznikla by definice, ve které role o sobě tvrdí schopnost, kterou jí
běhové prostředí zakáže. Nechytil to test, chytila to kontrola dosahu před generováním.
Půlka nasazení je horší stav než žádné.

**Role, která nedelegovala.** Vygenerovaná orchestrační role u zákazníka nepředávala práci
specialistům ani na výslovný pokyn. Hledalo se to v personě a v personě to nebylo:
v klientském výtahu norem chybělo pravidlo, které delegaci velí. Sepsané, ale nedoručené
pravidlo je totéž jako žádné. Pravidel delegace navázaných na konkrétní krok bylo v tom
výtahu nula, dnes je jich osm.

**Návod sliboval něco, co evidence neumí.** Text tvrdil, že nový záznam ponese určité
označení. Cílová evidence ta pole nemá, takže po prvním ostrém běhu by uživatel viděl
záznam bez slíbené značky a musel by řešit, jestli je rozbitý on, nebo my. Opravil se text,
schéma na straně zákazníka se nezasáhlo. Slib „zakládá se k odsouhlasení, schvaluje člověk"
zůstal, jen se přestal vázat na jména polí jedné databáze.

**Dva odkazy v manuálu, které fungovaly a přitom byly rozbité.** Uvnitř produktu se
otevíraly, protože si prohlížeč dokumentů dohledává soubor podle jména. Na webu
repozitáře vracely 404. Jeden text, dvě plochy, a testovala se jen jedna.

**Cizí administrátorský úkon zablokoval dodávku dvakrát.** Konektor do systému zákazníka
nebyl připojený 30. července a znovu 7. srpna. Nebyla to vada našeho kódu a stejně to byl
náš problém, protože plán stál na kroku, který nemůžeme udělat ani vynutit. Dnes je to
vedené jako riziko s vlastní řádkou, ne jako předpoklad.

**Kdo měří ostatní, sám se neměří.** Jednotka, ze které se celý tenant koordinuje, byla
sedmého srpna sama pozadu o osm změn platformy a jedna z nich byla blokující. Držela tím
v kontextu pravidlo, které už přebilo pozdější rozhodnutí. Tenhle vzorec se v provozu
zopakoval na třech různých místech a je to nejlevnější argument pro to, aby fronta byla
vidět jako číslo.

**Rozdíl mezi „instalace je rozbitá" a „rollout není dokončený".** Instalace u zákazníka
nesla jednotky ze starší šablony. Nebyla to vada instalátoru; čerstvý klon věrně zrcadlí
repozitář a migrace jednotek zbývala. Z pohledu uživatele vypadají obě situace
stejně, takže to musel někdo doopravdy zjistit, ne odhadnout.

## Kde si to v tomhle balíčku ověříš

- `knihovna/agents/humble.md` a `knihovna/agents/komensky.md`, obojí sekce o poznámkách
  k vydání. Dělba mezi mechanikou vydání a textem pro zákazníka je tam vypsaná z obou
  stran, se stejným datem rozhodnutí.
- [`docs/casy/02-vycet-zakazaneho-je-o-krok-pozadu.md`](../casy/02-vycet-zakazaneho-je-o-krok-pozadu.md) -
  týž projekt z druhé strany, oprávnění.
- [`docs/normy.md`](../normy.md), OR-05 včetně doplňku o cizím prostředí a OR-12
  o evidenci změn.
- [`docs/hranice-baliku.md`](../hranice-baliku.md), bod 5. Distribuční mechanismus ani
  konfigurace konkrétního nasazení tu nejsou, takže tenhle case si nepřehraješ. Zůstává
  z něj postup a jeho stopa jinde.
