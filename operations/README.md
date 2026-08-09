# operations

Evidenční vrstva platformy. Dvě složky a obě jsou doklad, ne dokumentace.

`changesets/` jsou reálné lístky z jednoho týdne provozu, 3. až 9. srpna 2026. Každý
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
