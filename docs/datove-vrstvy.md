# Datové vrstvy

Kde data bydlí a podle čeho se rozhoduje, kam co patří. Dvě otázky se tu snadno slijí do
jedné a vyplatí se je držet oddělené: **jakého typu ten obsah je** (kdo je jeho zdroj pravdy)
a **v jaké je fázi** (pracuje se na něm, nebo už platí). První rozhoduje o médiu, druhá o
umístění uvnitř něj.

Patří do patra mechanismů a rozepisuje dvě architektonická rozhodnutí, která
[`architektura-vrstev.md`](architektura-vrstev.md) odbývá jedním řádkem v tabulce (AR-07
a AR-08). Číst se dá samostatně, nic si odjinud nepůjčuje.

## Dvě osy, čtyři místa

| Kde | Co v tom žije | Zdroj pravdy | Životnost |
|---|---|---|---|
| **Repozitář platformy** | engine, šablony, normy, definice rolí, metodická jádra, dokumentace | disk, verzovaný gitem | trvalá |
| **Repozitář jednotky** | kontext zadání, stav, backlog, rozhodnutí, rozpracované výstupy | disk, verzovaný gitem | do vydání výstupu |
| **Znalostní báze** | živý obsah firmy, vydané výstupy, evidence, dokumenty sdílené s lidmi | znalostní báze | trvalá |
| **Souborový trezor** | to, co není text: podklady, exporty, smlouvy v PDF, média | disk se synchronizací na cloud | podle obsahu |

**Osa typu obsahu (AR-08).** Implementační obsah (jak systém funguje) má zdroj pravdy na
disku a je verzovaný gitem. Živý obsah firmy (co firma ví a čím se řídí) má zdroj pravdy
ve znalostní bázi a do gitu nepatří.

**Osa fáze (AR-07).** Rozpracované je pracovní pamětí a bydlí v repozitáři jednotky.
Vydané je dlouhodobou pamětí a bydlí ve znalostní bázi. Repozitář si po vydání drží
nanejvýš odkaz, ne druhou kopii.

Osy jsou kolmé, ne dvě jména pro totéž: definice role zůstane na disku napořád, zákaznický
výstup se během života přestěhuje. Kdo je slije, skončí u pravidla „důležité věci do
znalostní báze" a to nerozhoduje nic.

## Proč hranice vede zrovna tudy

Původní rozhodnutí bylo opačné: zdrojem pravdy měla být znalostní báze a disk měl držet
jen kopii ke čtení. Obrátilo se ve chvíli, kdy se implementační obsah začal verzovat
gitem, a důvod je zapsaný, aby se to nezpochybňovalo dokola:

- **Nasazení klonem.** Když se systém rozjíždí naklonováním repozitáře, musí s ním jet
  i to, čím se řídí; závislost na externí službě znamená rozbité nasazení bez přístupu.
- **Verzování a větve.** Git má diff po řádcích a zkoušenou verzi norem udrží mimo živý
  prostor. Souběžnou editaci řeší merge, ne poslední zápis.
- **Nezávislost na dodavateli.** Nástroj se může změnit; disk plus git je celý u nás.

Opačným směrem platí totéž. Živý obsah firmy se mění s byznysem, ne s kódem, čtou ho lidé bez
terminálu, komentuje se a má vazby na evidenci; nic z toho soubor v repozitáři neumí. Hranice
nevede podle důležitosti, ale podle toho, **co se s tím obsahem denně dělá**.

## PARA a jeho zavedená podoba

Struktura je postavená podle PARA (Tiago Forte) a nosná věta je jedna, všechno ostatní z ní
plyne: **třídí se podle akcionability, ne podle tématu.** Rozhoduje, co s tou věcí dělám, ne
čeho se týká; téma je osa kolmá, a když se zakóduje do umístění, přestane jít kombinovat.
Na disku má trezor čtyři kbelíky a číslice v názvu drží pořadí, aby ho nepřerovnala abeceda:

```
<kořen trezoru>/
├── 1-Projects/<skupina>/<projekt>/   práce s koncem a s výsledkem
├── 2-Areas/<oblast>/                 trvalá odpovědnost bez konce
├── 3-Resources/<téma>/               reference, ke které nemám závazek
└── 4-Archives/<...>/                 dokončené a spící; nic se nemaže, jen se stěhuje
```

Ve znalostní bázi je nad těmi čtyřmi ještě jedna vrstva, **pilíř**, protože kbelíky samy
neřeknou, čí ta práce je. Pilíř je doména s vlastníkem a teprve uvnitř něj se větví oblasti,
projekty, poznámky a archiv. Jak se ta sada jmenuje a kolik jich v ní je, sem nepatří;
přenositelné je pravidlo, kterým se drží pohromadě: **hranici mezi dvěma sousedy nedrží popis
pilíře, ale rozlišovací test.** Popis odpovídá na otázku „co sem patří" a u sporného záznamu
mlčí. Test odpovídá na otázku „kam z těch dvou", a to je ta, která se v provozu doopravdy
pokládá. Dva anonymizované příklady tvaru:

| Sporná dvojice | Rozlišovací test |
|---|---|
| Doména „co a proč" versus doména „jak se to dělá" | Mění ta práce záměr, nebo způsob? Způsob patří k provozu. |
| Vlastní schopnost versus zakázka | Komu ta věc zůstane, až skončí? Když druhé straně, je to delivery. |

Sfér je víc než jedna: vedle firemní stojí i ta mimo firmu, se stejným tvarem a vlastními
pilíři. Platí o ní jedno přenositelné pravidlo: **projekce je jednosměrná.** Odkaz smí vést
z osobní vrstvy do firemní, nikdy naopak, protože do firemního prostoru jednou vstoupí
cizí člověk.

**Pravidla zařazování, která se v provozu ukázala jako nosná:**

- **Projekt, nebo oblast?** Umím napsat výsledek v minulém čase („doručil jsem strategii")?
  Pak projekt. Rozvoj čehokoli je oblast, konkrétní iterace uvnitř ní je projekt.
- **Oblast, nebo zdroj?** Mám tam odpovědnost, nebo jen sbírám materiál? Sbírání je zdroj.
- **Jeden domov na entitu.** Jedna databáze projektů a jedna úkolů pro všechny sféry; doména
  je vlastnost záznamu, ne druhá databáze. Jinak má „co běží" tolik odpovědí, kolik domovů.
- **Zařazení je vazba na řádek, ne text**, a klíčuje se na identifikátor, ne na název.
  Názvy se přejmenovávají, identifikátory ne. Tím padá celá třída chyb z přejmenování.
- **Prázdná hodnota je platná hodnota.** Prázdné zařazení úkolu znamená „platí zařazení
  jeho projektu", ne chybějící data. Vyplňuje se jen výjimka.
- **Rozpočet hloubky jsou čtyři úrovně.** Hlubší cesta stojí na navigaci víc, než ušetří.

**Co se děje při uzavření.** Archiv je uzel, kam se stěhuje, ne kde se maže.

| Objekt | Kdy do archivu |
|---|---|
| Projekt ve stavu hotovo nebo zrušeno | 30 dní po posledním doteku |
| Pozastavený projekt | nikdy; pauza není konec, zůstává aktivní se stavem pauza |
| Úkol v zásobníku bez data déle než 90 dní | do archivu ne, do fronty k rozhodnutí |
| Stránka | když přestane platit nebo se přestane používat |
| Pilíř | nearchivuje se, přepne se stav řádku |

Archiv se staví i tam, kde je prázdný, a stojí za vyslovení proč: **prázdná stránka pilíře je
dluh, prázdný archiv je zpráva, že zatím nic neskončilo.** Rituál bez cíle nemá kam.

## Datové zdroje a přístup k nim

| Zdroj | Co v něm žije | Kdo do něj zapisuje | Jak se pozná, že je zastaralý |
|---|---|---|---|
| **Soubory v repozitáři** | engine, normy, definice, kontext a stav jednotek, rozpracované výstupy | agenti přes běžné souborové nástroje, změna s dosahem ven nese changeset | git log, otisk v indexu platformy, fronta nepřevzatých changesetů |
| **Znalostní báze přes konektor** | živý obsah firmy, vydané výstupy, evidence | role pro informační architekturu strukturně, role pro provoz obsahově, člověk kdykoli | datum poslední úpravy plus revize zastarávání; stroj to nehlídá |
| **Souborový trezor** | podklady, exporty, smlouvy, média | člověk, agenti výjimečně | podle kbelíku: co je v archivu, zastarat nemůže |
| **Externí zdroje** | rešerše, primární prameny, sledování oboru | jen role pro rešerši, a to zápisem do repozitáře, ne odkazem | datum sběru u citace; zdroj se necachuje |

Ke znalostní bázi se přistupuje **konektorem, ne exportem** (u nás Notion; role, které s ním
pracují, ho jmenují ve svých definicích, viz [`knihovna/agents/tiago.md`](../knihovna/agents/tiago.md)).
Export by založil druhou kopii a ta se do měsíce rozejde. Strukturní zásah tam má povinný
třídílný postup podle OR-05: přepis kontejnerové stránky nám jednou odpojil čtyři databáze
i s řádky, viz [`casy/03-odpojene-databaze.md`](casy/03-odpojene-databaze.md).

## Kde to dnes drhne

1. **Synchronizace mezi diskem a znalostní bází není automatická.** Obousměrný sync je
   popsaný jako záměr, mechanismus k němu neexistuje. Role bez konektoru tedy dostane pokyn
   „přečti si, čím se firma řídí", který pro ni splnitelný není. Ruční kopie to neřeší, jen
   přesune: kopie bez hlavičky se zdrojem a datem se do měsíce stane druhým zdrojem pravdy.
2. **Zastarávání hlídá rituál, ne stroj.** Na disku běží brána při každém commitu.
   Ve znalostní bázi neběží nic: existuje runbook, kadence a vlastník, ale žádná kontrola
   neřekne, že revize proběhla. Rozdíl je vidět na první pohled - frontu nepřevzatých změn
   spočítá příkaz, zastaralou stránku pozná jen ten, kdo ji otevře.
3. **Hranice mezi pracovní a dlouhodobou pamětí se v provozu rozostřuje.** Migrace hotového
   výstupu do znalostní báze je ruční krok bez spouštěče, takže se odkládá. Repozitář pak drží
   dokumenty, které tam nemají co dělat, a čtenář nepozná rozpracované od platného.
4. **Jedna složka drží obojí.** Metodická jádra rolí (zdroj pravdy disk) leží vedle odvozenin
   z živého obsahu firmy (zdroj pravdy znalostní báze) a rozlišují se obsahem, ne umístěním.
   To je přesně tvar, na kterém se někdo splete a začne editovat odvozeninu.

## Co tu vědomě není

Jména jednotek portfolia a jejich počet, jména zákazníků, obsah osobní sféry a **jmenný výčet
pilířů i jejich počet**; příklady cest a jmen jsou proto v lomených závorkách jako zástupné.
Struktura je popsaná úrovněmi, kategoriemi a pravidly zařazování. Výčet toho, co v nich
konkrétně leží, by o systému nic nedodal.

U pilířů to stojí za zvláštní zmínku, protože je to přesně ta past, kterou tenhle balíček
řeší jinde: každé jméno pilíře je samo o sobě běžný obchodní termín a vypadá neškodně.
Dohromady je z těch jmen mapa nejvyšší úrovně jednoho pracovního prostoru, a to je jiná
třída než součet jejích částí. Stejný tvar nálezu je rozepsaný
v [`pripady-pouziti/04-tenhle-balicek.md`](pripady-pouziti/04-tenhle-balicek.md).

## Kam odsud dál

Obě rozhodnutí, ze kterých tenhle text vychází, stojí v tabulce
v [`architektura-vrstev.md`](architektura-vrstev.md) jako AR-07 a AR-08. Pravidlo
o strukturních zásazích do znalostní báze je OR-05 v [`normy.md`](normy.md) a incident
za ním [`casy/03-odpojene-databaze.md`](casy/03-odpojene-databaze.md). Proč zastarávání
v bázi hlídá rituál a ne stroj, a co s tím,
rozvádí [`uceni-a-zavedeni.md`](uceni-a-zavedeni.md).
