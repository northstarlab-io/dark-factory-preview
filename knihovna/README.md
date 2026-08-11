# knihovna

Platformní knihovna: to, co si session načítá. `agents/` jsou definice rolí, `foundation/`
metodické soubory, na které definice odkazují, `skills/` workflow postupy volané v turnu.

Jsi v patře souborů, tedy nejhlouběji, kam dokumentace vede. Nejlevnější cesta dovnitř je
druhá zastávka v [`../docs/PROHLIDKA.md`](../docs/PROHLIDKA.md): jedna dvojice definic
a hranice mezi nimi, přečtená z obou stran, zabere dvě minuty.

## Seznam rolí není úplný

V `agents/` je platformní knihovna celá, tedy všechny role, které se volají napříč
jednotkami. Úplný výčet rolí to přesto není. Vedle knihovny běžně existují definice vázané
na jednu jednotku nebo na jednoho tenanta: buď pojmenované nadstavby nad těmihle
definicemi, nebo role, které vznikly pro jeden kontext a mimo něj nedávají smysl. Ty jsou
lokální a v balíčku nejsou. Mechanika nadstaveb je popsaná
v [`../docs/architektura-vrstev.md`](../docs/architektura-vrstev.md), sekce Platformní
knihovna.

## Jak se definice čte

Každý soubor v `agents/` má dvě části.

**Frontmatter**, blok mezi `---` na začátku, je strojová část. `name` je jméno, kterým se
role volá. `description` je text, podle kterého orchestrátor pozná, kdy ji zavolat a kdy
ne, proto v něm bývá i výslovné „nevolej pro". `model` je výchozí model pro typickou práci
té role. `tools` je výčet nástrojů, které role smí použít; co v něm není, k tomu se
nedostane.

**Tělo** se roli vloží jako systémový prompt. Obsahem to ale není návod, co má psát, ale
kontrakt: doména, hranice vůči sousedním rolím, železná pravidla, anti-patterny a kritéria
kvality výstupu. Většina textu neřeší, co má role dělat, ale kde přestává a komu to
předává.

**Jak se role volá.** Orchestrátor ji spustí jako subagenta s vlastním zadáním a vlastním
kontextovým oknem. Historii session, ze které se volá, nevidí a nedostane nic než to, co
jí kdo napíše. Odtud povinnost kompletního zadání, norma OR-01 v
[`../docs/normy.md`](../docs/normy.md).

## Proč má každá role „v doméně" a „mimo doménu"

Jedna role napsaná samostatně vyjde dobře skoro vždycky. Problém začne u druhé: dvě si
sáhnou na totéž a ani jedna neví, kde má přestat, protože obě mluví jen o sobě. Výčet
„mimo doménu" je ta hranice napsaná adresně. Ne „tohle nedělám", ale „tohle dělá ta a ta
role". Táž hranice je vypsaná i v textu té druhé role, takže se dá číst z obou stran a
pozná se, když se rozejde. Mapa domén je ve
[`foundation/specialist-delegation-matrix.md`](foundation/specialist-delegation-matrix.md).

## Mění se to provozem

Definice není hotový dokument. Hranice se dopisují ve chvíli, kdy dvě role narazí na
totéž, železná pravidla přibývají po incidentech a kus textu občas zmizí, protože ho nic
nedrží. Kanonický domov těch souborů je mimo tenhle balíček a mění se jen schváleným
postupem, ve kterém agent svou vlastní definici needituje. Kopie tady je snímek k datu,
které nese hlavička každého souboru, zpátky se nesynchronizuje a od toho data zastarává.

## Jak si to zkusit u sebe

Zkopíruj soubor do `.claude/agents/` nebo `.claude/skills/` svého projektu. Nic se
neaktivuje samo, je to tvůj krok. Pole `model` nese alias platný v našem prostředí; ve svém
si ho přepiš na alias, který máš. Pole `tools` u některých definic jmenuje i konektory,
které máme připojené my. Co nemáš, škrtni, zbytek funguje.

Odkazy na dokumenty, které v balíčku nejsou, jsou ponechané schválně: ukazují, kde ten
fakt bydlí.

## Kam odsud dál

Nahoru vede [`../docs/architektura-vrstev.md`](../docs/architektura-vrstev.md), sekce
Platformní knihovna: jak se dělá lokální odchylka, kdy je to fork a jak se sada dostane na
stroj, který nespravujeme. Pravidlo, že si role vlastní definici nepřepisuje, je OR-09
v [`../docs/normy.md`](../docs/normy.md), a co s definicemi udělá tvoje prostředí, stojí
v [`../docs/hranice-baliku.md`](../docs/hranice-baliku.md).
