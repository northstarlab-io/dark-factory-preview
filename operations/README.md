# operations

Evidenční vrstva platformy. Dvě složky a obě jsou doklad, ne dokumentace.

Jsi v patře souborů. Mechanismus, jehož jsou tyhle lístky výstupem, popisuje
[`../docs/architektura-vrstev.md`](../docs/architektura-vrstev.md) v sekci o propagaci změn
a jako pravidlo OR-12 v [`../docs/normy.md`](../docs/normy.md); provedení v pevném pořadí má
čtvrtá zastávka v [`../docs/PROHLIDKA.md`](../docs/PROHLIDKA.md).

`changesets/` je výběr třinácti reálných lístků napříč jedním týdnem provozu, 3. až
9. srpna 2026; za ten týden jich vzniklo pětašedesát. Každý
popisuje jednu změnu platformy: lidskou větu napsanou v okamžiku změny, akci pro toho,
koho se to týká, a blok strojového testu, kterým se pozná, že to převzal. Nejsou psané
pro tebe, jsou psané pro naše vlastní jednotky, takže narazíš na odkazy do repozitářů,
které nemáš, a na commit hashe, které si neověříš. Nechali jsme je tak schválně; lístek
zbavený svých odkazů by byl retušovaný dokument.

`ukazky/` jsou zachycené výstupy nástrojů z tohohle balíčku. V hlavičce každého souboru
je příkaz, kterým si ho přehraješ, a poznámka, čím se tvůj výsledek bude lišit od našeho.

Kudy do toho, když si chceš přečíst jen jednu věc: `changesets/2026-08-03-zaveden-mechanismus-propagace.md`,
tedy lístek, kterým celý mechanismus vznikl. Kontrakt formátu je v `changesets/README.md`
a je to pět set řádků interního předpisu psaného pro toho, kdo lístky vydává. Otevírej ho
až ve chvíli, kdy tě zajímá, jak se taková věc definuje, ne abys pochopil, o co jde.

**Kam odsud dál.** Která čísla se tudy propisují a která ne, drží
[`../docs/mapa-verzi.md`](../docs/mapa-verzi.md). Proč tenhle mechanismus vznikl a co bez něj
selhalo, je v [`../docs/casy/01-brana-kterou-nikdo-nespoustel.md`](../docs/casy/01-brana-kterou-nikdo-nespoustel.md).
Druhou stranu evidence, tedy co jedna jednotka převzala, uvidíš
v [`../ukazka-jednotky/operations/platform-baseline.md`](../ukazka-jednotky/operations/platform-baseline.md).
