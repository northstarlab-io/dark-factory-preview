# Dark Factory

Systém pro provoz práce s agenty v Claude Code: šablona jednotky, definice rolí jako kontraktů, zapsané normy a mechanické brány, které ty normy vynucují. Tenhle balíček je výřez, ne celý stack.

Dokumentace jde odshora dolů: nejdřív co to je, pak jak to uvnitř funguje, pak důkazy a soubory. Každý dokument nahoře říká, kam patří, a dole, kam se z něj jde hlouběji, takže se dá číst i odjinud než odsud.

**Nejdřív big picture.** Tři texty, dohromady zhruba na půl hodiny; po prvním víš, o čem to celé je.

- [docs/CO-JE-DARK-FACTORY.md](docs/CO-JE-DARK-FACTORY.md) - co to je, čím se to liší od toho, co si postavíš sám, co z toho běží dnes a co nefunguje
- [docs/PROHLIDKA.md](docs/PROHLIDKA.md) - pět míst v repu v pevném pořadí, nic nemusíš spouštět
- [docs/mapa-projektu.md](docs/mapa-projektu.md) - z čeho se ten ekosystém skládá: páteř jmenovitě, byznysová vrstva po kategoriích

**Pak mechanismy.** Jeden dokument na jednu otázku, čtou se samostatně a v libovolném pořadí.

- [docs/architektura-vrstev.md](docs/architektura-vrstev.md) - čtyři vrstvy podle správy, jednotka jako atom, knihovna rolí, distribuce ven, propagace změn
- [docs/normy.md](docs/normy.md) - dvanáct provozních norem, u každé incident, který ji odhalil
- [docs/datove-vrstvy.md](docs/datove-vrstvy.md) - kde data bydlí, dvě osy rozhodování a čtyři místa, kde to dnes drhne
- [docs/uceni-a-zavedeni.md](docs/uceni-a-zavedeni.md) - co se sbírá samo, kde je člověk povinně v cyklu, a šest kroků od zadání k tomu, že to tým používá
- [docs/mapa-verzi.md](docs/mapa-verzi.md) - čtyři nezávislé řady čísel: co znamenají, kam se propisují a kam se vědomě nepropisují
- [docs/hranice-baliku.md](docs/hranice-baliku.md) - co tu běží zeleně, co je jen ke čtení a co tu vědomě chybí

**Nakonec důkazy a soubory.** Sem se prohrabeš, když ti předchozí patro nestačí a chceš to vidět na konkrétní věci.

| Kde | Co v tom najdeš |
|---|---|
| [docs/casy/](docs/casy/README.md) | pět incidentů platformy: co se stalo, co to stálo a co se z toho stalo za pravidlo |
| [docs/pripady-pouziti/](docs/pripady-pouziti/README.md) | čtyři případy práce z reálných projektů včetně toho, co se v nich předělávalo |
| [knihovna/](knihovna/README.md) | definice rolí z platformní knihovny, metodické soubory, na které odkazují, a skilly |
| [scaffold/](scaffold/README.md) | engine: validátory, sdílené funkce, hooky, testy, šablona jednotky |
| [ukazka-jednotky/](ukazka-jednotky/) | šablona zkopírovaná a vyplněná, na které validátor projde; začni [`CLAUDE.md`](ukazka-jednotky/CLAUDE.md) a `operations/status.md` |
| [operations/](operations/README.md) | reálné changesety z jednoho týdne provozu a zachycené výstupy nástrojů |

Kam to míří dál, je [docs/koncept-autonomie.md](docs/koncept-autonomie.md): návrhový koncept se třemi cestami k autonomnějšímu provozu, postavený na inventuře toho, co se v platformě zastavilo. Je to směr a názor autora, ne popis toho, co běží, a proto stojí až tady a ne v big picture.

Co s balíčkem smíš: [NOTICE.md](NOTICE.md). Co se v něm mezi verzemi měnilo: [CHANGELOG.md](CHANGELOG.md).

Repo je bez historie a bez klientských dat, protože vzniklo vydělením, ne klonem. `git log` proto začíná prvním vydáním tohohle balíčku a nic staršího v něm není; dál v něm přibývají jen jeho vlastní vydání. Důvod je v [docs/CO-JE-DARK-FACTORY.md](docs/CO-JE-DARK-FACTORY.md), sekce „Co dnes nefunguje".
