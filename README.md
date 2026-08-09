# Dark Factory

Systém pro provoz práce s agenty v Claude Code: šablona jednotky, definice rolí jako kontraktů, zapsané normy a mechanické brány, které ty normy vynucují. Tenhle balíček je výřez, ne celý stack.

- **Chci vědět, co to je** -> [docs/CO-JE-DARK-FACTORY.md](docs/CO-JE-DARK-FACTORY.md)
- **Radši se podívám** -> [docs/PROHLIDKA.md](docs/PROHLIDKA.md), pět míst v repu, patnáct minut, nic nemusíš spouštět
- **Chci vědět, jak se to udržuje** -> [docs/normy.md](docs/normy.md), dvanáct provozních norem, u každé incident, který ji odhalil; vrstvy a architektonická rozhodnutí v [docs/architektura-vrstev.md](docs/architektura-vrstev.md)

Co v balíčku je:

| Složka | Co v ní najdeš |
|---|---|
| `docs/` | vysvětlení, prohlídka, normy, architektura, mapa verzí, hranice balíčku, pět casů |
| `knihovna/` | definice rolí, metodické soubory, na které odkazují, a skilly |
| `scaffold/` | engine: validátory, sdílené funkce, hooky, testy, šablona jednotky |
| `ukazka-jednotky/` | šablona zkopírovaná a vyplněná, na které validátor projde |
| `operations/` | reálné changesety z jednoho týdne provozu a zachycené výstupy nástrojů |

Co s balíčkem smíš: [NOTICE.md](NOTICE.md). Co v něm běží, co je tu jen ke čtení a co tu vědomě chybí: [docs/hranice-baliku.md](docs/hranice-baliku.md).

Repo je bez historie a bez klientských dat, protože vzniklo vydělením, ne klonem. `git log` proto ukáže jeden commit; důvod je v [docs/CO-JE-DARK-FACTORY.md](docs/CO-JE-DARK-FACTORY.md), sekce „Co dnes nefunguje".
