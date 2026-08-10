# Dark Factory

Systém pro provoz práce s agenty v Claude Code: šablona jednotky, definice rolí jako kontraktů, zapsané normy a mechanické brány, které ty normy vynucují. Tenhle balíček je výřez, ne celý stack.

- **Chci vědět, co to je** -> [docs/CO-JE-DARK-FACTORY.md](docs/CO-JE-DARK-FACTORY.md)
- **Radši se podívám** -> [docs/PROHLIDKA.md](docs/PROHLIDKA.md), pět míst v repu, patnáct minut, nic nemusíš spouštět
- **Chci vědět, jak se to udržuje** -> [docs/normy.md](docs/normy.md), dvanáct provozních norem, u každé incident, který ji odhalil; vrstvy a architektonická rozhodnutí v [docs/architektura-vrstev.md](docs/architektura-vrstev.md)
- **Chci vidět, z jakých projektů se to skládá** -> [docs/mapa-projektu.md](docs/mapa-projektu.md), páteřní projekty jmenovitě s tím, co má který na starosti, a co by se stalo, kdyby chyběl; byznysová vrstva po kategoriích
- **Chci vidět, co ten systém dělá za práci** -> [docs/pripady-pouziti/](docs/pripady-pouziti/), čtyři případy z reálných projektů včetně toho, co se v nich předělávalo; incidenty platformy samotné jsou vedle v [docs/casy/](docs/casy/)
- **Chci vědět, kde data bydlí** -> [docs/datove-vrstvy.md](docs/datove-vrstvy.md), dvě osy rozhodování o umístění, zavedená podoba PARA a čtyři místa, kde to dnes drhne
- **Chci vědět, jestli se to učí a jak se to zavádí u lidí** -> [docs/uceni-a-zavedeni.md](docs/uceni-a-zavedeni.md), co se sbírá automaticky, kde je člověk povinně v cyklu a proč, a šest kroků od zadání k tomu, že to tým používá

Co v balíčku je:

| Složka | Co v ní najdeš |
|---|---|
| `docs/` | vysvětlení, prohlídka, normy, architektura, mapa projektů, datové vrstvy, učení a zavedení, mapa verzí, hranice balíčku, pět casů o incidentech a čtyři případy z projektů |
| `knihovna/` | definice rolí z platformní knihovny, metodické soubory, na které odkazují, a skilly |
| `scaffold/` | engine: validátory, sdílené funkce, hooky, testy, šablona jednotky |
| `ukazka-jednotky/` | šablona zkopírovaná a vyplněná, na které validátor projde |
| `operations/` | reálné changesety z jednoho týdne provozu a zachycené výstupy nástrojů |

Co s balíčkem smíš: [NOTICE.md](NOTICE.md). Co v něm běží, co je tu jen ke čtení a co tu vědomě chybí: [docs/hranice-baliku.md](docs/hranice-baliku.md).

Repo je bez historie a bez klientských dat, protože vzniklo vydělením, ne klonem. `git log` proto ukáže jeden commit; důvod je v [docs/CO-JE-DARK-FACTORY.md](docs/CO-JE-DARK-FACTORY.md), sekce „Co dnes nefunguje".
