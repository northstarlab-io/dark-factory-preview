# Odpojené databáze ve vlastní znalostní bázi

**Kdy:** 31. května 2026, zjištěno 2. června
**Kde:** naše vlastní znalostní báze, ne prostředí zákazníka
**Třída vady:** destruktivní strukturní operace bez ověření po provedení

## Co se stalo

Migrace uvnitř vlastní znalostní báze přesouvala kontejnerové stránky a přepisovala jejich
obsah. Jedna z nich nesla vnořené databáze, ve kterých žila obchodní evidence: účty,
kontakty, příležitosti, nabídky. Přepis obsahu kontejnerové stránky ty databáze odpojil.
Odpojený objekt skončil v koši i se všemi řádky.

Mechanismus je nudný a přesně proto nebezpečný: nový obsah stránky musí zachovat značky
vnořených objektů. Když je nezachová, objekt nezůstane stát vedle, ale ztratí rodiče
a odejde s ním.

## Jak se to projevilo

Za dva dny a náhodou. Zápis do jedné z těch databází selhal hláškou o archivovaném
předkovi. Agent, který migraci prováděl, hlásil hotovo a integritu během práce kontroloval
bodově; v postupu nebylo nic, co by se po dokončení série podívalo na celý zasažený strom.

## Co to stálo

Dva dny práce nad daty, o kterých nikdo nevěděl, že jsou v koši. Obnovu z historie verzí
a z koše a k tomu ruční obnovení vazeb mezi databázemi. Ztraceno nebylo nic, ale to je
vlastnost nástroje, ne zásluha postupu. Kdyby ta znalostní báze historii verzí neměla,
je to případ na obnovu ze zálohy, kterou před tou operací nikdo neudělal.

## Co se z toho stalo za pravidlo

Trojice bez výjimky: **soupis před operací** (všechny vnořené objekty a jejich
identifikátory), **operace**, **ověření hned po operaci** proti soupisu. Chybí-li po
operaci cokoli ze soupisu, zastavit a obnovit. Před destruktivním krokem záloha.

K tomu druhá, samostatná brána: kdo sérii takových operací zadával, dělá po jejím konci
kontrolu celého zasaženého stromu proti výchozímu soupisu. Integrita prostředí, na kterém
záleží, nesmí stát jen na tom, co o sobě hlásí agent, který operaci provedl. Jeho
průběžné kontroly byly korektní a přesto to prošlo.

O sedm týdnů později se pravidlo rozšířilo z jednoho nástroje na jakýkoli zásah do
prostředí, které nevlastníme (cizí znalostní báze, CRM, souborový systém, cloudová
konfigurace, cizí repozitář): plán se suchým výpisem toho, co se změní, výslovný souhlas
člověka, provedení, ověření proti plánu. **Agent připravuje, člověk spouští.**

Obecnější věta, kterou z toho používáme dál: čtení před zápisem bez symetrického ověření
po zápisu je půlka bezpečnostní smyčky. Ta chybějící půlka se pozná jen tím, že ji někdo
udělá.

## Jak se to hlídá dnes

Nehlídá to stroj a je poctivé to napsat rovnou. Je to postupová norma, kterou vynucuje
disciplína a kontrola po sérii, ne brána. Ze všech pěti casů je tenhle jediný, kde se
z pravidla nestala mechanická kontrola, protože soupis potomků umí jen ten nástroj, který
pro to má rozhraní, a ne každý ho má.

Jedinou tvrdou oporou je hranice práv: v prostředí, které nevlastníme, agent destruktivní
akci sám spustit nemůže, takže krok „člověk spouští" nevynucuje text, ale oprávnění.
Tatáž hranice je vidět i v tomhle balíčku na jiném místě - instalátor bran tu není a hooky
se samy neaktivují, protože zapnout vykonávanou konfiguraci na cizím stroji smí jen jeho
majitel.

## Co na tom pořád není dořešené

Ověření po operaci je krok v runbooku. Kdo ho vynechá, nic ho nezastaví a pozná se to až
při dalším zásahu, který nemusí přijít brzy. Záloha před destruktivním krokem je taky
pokyn, ne automatika. Obojí je vědomý dluh: mechanizovat to jde jen per nástroj a dnes to
nemá návratnost, kterou by šlo obhájit.

## Kde si to v tomhle balíčku ověříš

- [`docs/normy.md`](../normy.md), OR-05 včetně doplňku o cizím prostředí.
- `ukazka-jednotky/operations/runbooks/kb-staleness-sweep.md`, krok 4 - runbook, který ten
  postup používá jako podmínku před destruktivním zásahem.
- `ukazka-jednotky/CLAUDE.md` - zkrácený výtah norem, který nese každá jednotka, aby
  pravidlo bylo v kontextu i tam, kde nikdo nečte plné znění.
