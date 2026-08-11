# Casy

Pět reálných incidentů z provozu. Žádný z nich není postavený kvůli téhle prohlídce a
žádný nekončí pointou o tom, jak jsme chytří. Vybrané jsou tak, že u čtyř z pěti šlo
o vadu na naší straně a pátý je vada, kterou jsme si sami napsali do dokumentu, který
před ní varuje.

Tahle složka je nejspodnější patro dokumentace: doklad pod pravidly, ne jejich výklad.
Pravidla samotná stojí v [`../normy.md`](../normy.md) a u OR-05, OR-10 a OR-12 vede odkaz
sem přímo od textu normy.

Každý case má stejnou stavbu: **co se stalo**, **jak se to projevilo**, **co to stálo**,
**co se z toho stalo za pravidlo**, **jak se to hlídá dnes** a **co na tom pořád není
dořešené**. Poslední oddíl je tam schválně u každého - pravidlo bez zbytkového rizika
obvykle znamená, že se to riziko jen nehledalo.

| # | Case | O čem to je |
|---|---|---|
| 1 | [Brána, kterou nikdo nespouštěl](01-brana-kterou-nikdo-nespoustel.md) | Kontrola hlásila chyby, které nikdo neviděl, protože ji nic nespouštělo |
| 2 | [Výčet zakázaného je vždycky o krok pozadu](02-vycet-zakazaneho-je-o-krok-pozadu.md) | Oprávnění stála na seznamu zakázaného a nestíhala tomu, kdo přidává |
| 3 | [Odpojené databáze ve vlastní znalostní bázi](03-odpojene-databaze.md) | Strukturní operace poslala evidenci do koše, zjistilo se to za dva dny |
| 4 | [Omezení, které nezaniklo](04-omezeni-ktere-nezaniklo.md) | Napsaná podmínka zániku není mechanismus zániku |
| 5 | [Číslo verze psané rukou](05-cislo-verze-psane-rukou.md) | Druhý domov čísla driftuje i uvnitř dokumentu, který před tím varuje |

## Co je v casech anonymizované a co ne

Ven nejdou jména: žádný zákazník, žádná osoba, žádný název cizího systému ani produktu.
Místo jmen jsou role a domény.

Ven jdou čísla, pokud nikoho neidentifikují. Kolik souborů bylo zasažených, jak dlouho
to trvalo, kolikátý den se to našlo, jaký byl rozdíl v diffu - to všechno zůstává, jinak
by z casu zbyla historka. Naopak tu nenajdeš nic o rozsahu portfolia ani o velikosti
týmu; k mechanismu to nepřidává nic a ven to nepatří.

Ke každému casu je připsané, **kde si tvrzení ověříš přímo v tomhle repu**. Když se
odkaz týká něčeho, co v balíčku není, je to u toho napsané.

## Druhá řada, jiný předmět

Vedle téhle složky stojí [`docs/pripady-pouziti/`](../pripady-pouziti/README.md). Rozdíl je
v předmětu: tady jsou **incidenty platformy samotné**, tedy co se pokazilo uvnitř systému
a jak se to našlo. Tam jsou **projekty, na kterých se pracovalo**: co se zadalo, jak se
práce rozdělila, kde vstoupil člověk a co z toho vzniklo. Pravidla anonymizace platí pro
obě řady stejně.

## Kam odsud dál

Nahoru: [`../normy.md`](../normy.md) pro pravidla, která z těchhle pěti incidentů vznikla,
a [`../architektura-vrstev.md`](../architektura-vrstev.md) pro stavbu, které se týkají.
Na stejné úrovni: [`../pripady-pouziti/`](../pripady-pouziti/README.md). Úplně zpátky na
začátek vede [`../CO-JE-DARK-FACTORY.md`](../CO-JE-DARK-FACTORY.md).
