# Číslo verze psané rukou

**Kdy:** 5. a 9. srpna 2026
**Kde:** vlastní platforma a její dokumentace
**Třída vady:** druhý domov téhož faktu

## Co se stalo

Při založení nové jednotky se do jejího kořene kopírovaly dva soubory platformy, mezi nimi
ten s číslem verze. Kopie vznikla jednou a dál se neaktualizovala. Každá jednotka,
kde ten soubor byl, tak nesla číslo z doby svého založení, zatímco platforma byla o dvě
vydání dál a evidence jedné z nich říkala ještě třetí číslo.

Nikomu to nevadilo, protože podle toho čísla nikdo nic nerozhodoval. Jenom tam bylo.
To je na téhle třídě vad to nepříjemné: nefunguje to jako porucha, funguje to jako tichý
posun důvěry v soubory, které se tváří jako zdroj.

## Jak se to projevilo

Dvakrát, nezávisle na sobě.

**Pátého srpna** při kontrole seznamu, který řídí upgrade jednotek. Ukázalo se, že ten
soubor je v seznamu vedený, ale v šabloně nikdy nebyl - upgrade by tedy kopíroval
neexistující zdroj. Mrtvá deklarace stála v seznamu od prvního vydání.

Tatáž kontrola odhalila horší věc, která z toho plynula. V repozitáři, kde se vydává
software někomu ven, znamená soubor téhož jména číslo vydání toho softwaru. Upgrade řízený
tím seznamem by druhé straně přepsal číslo vydání jejího nástroje číslem naší platformy.
Byla to jediná cesta, jak se dvě nezávislé řady čísel mohly potkat, a od té doby je
zavřená.

**Devátého srpna** na dokumentu, který o číslech verzí je. Vznikl 7. srpna a dva dny nato
tvrdil o platformě číslo o tři vydání pozadu, protože ho tam jeho vlastní autor napsal
rukou. Dokument, který varuje před druhým domovem čísla, se stal druhým domovem čísla.

Měřením se u téhož dokumentu ukázalo, že zastaralé číslo nebylo jediné. Jednotky,
o kterých text tvrdil, že ten soubor nesou, ho už neměly. Nástroj, o kterém text tvrdil,
že nemá tag, ho mezitím měl. Výčet datových schémat měl sedm položek, měření jich najde
třináct. Ani jedna z těch vět nevznikla ve zlé víře; všechny zestárly stejným způsobem.

## Co to stálo

Nic, co by se dalo vyčíslit v čase nebo penězích. Cena je v důvěryhodnosti: dokument,
který má být odpovědí na otázku „jaká čísla platí", byl po dvou dnech nespolehlivý, a to
právě u toho čísla, kvůli kterému ho člověk otevře.

## Co se z toho stalo za pravidlo

**Jedno číslo, jeden domov.** Verzi platformy drží jediný soubor a ostatní místa ji čtou.
Co jednotka převzala, drží její evidence, do které zapisuje výhradně nástroj a jen po
průchodu testem; ruční editace té evidence je lež o synchronizaci.

**Do prózy dokumentace se živé číslo nepíše.** Kde je potřeba, stojí cesta ke zdroji
a příkaz, kterým si ho čtenář přečte. Historické číslo se odlišuje typograficky předponou
`v`, aby šlo rozeznat doklad o minulosti od živého údaje, a to i strojově.

## Jak se to hlídá dnes

Tři kontroly, každá na jinou část problému:

- Mrtvou deklaraci v seznamu i opačnou díru (soubor v šabloně bez zařazení) hlásí kontrola
  seamu jako FAIL.
- Živé číslo psané rukou v mapě verzí hlásí samostatná kontrola. Vzniklo k ní zjištění
  z ostrého běhu, ne z úvahy: první verze hlásila jako číslo verze i adresu `127.0.0.1`
  ve větě o portu, takže se čtyřdílné adresy před posouzením odstraňují.
- Verifikační jazyk changesetů dostal sloveso pro „tenhle soubor už tam nesmí být". Do té
  doby neměla akce typu „smaž soubor" žádný test a v evidenci vypadala jako hotová, aniž
  ji kdo ověřil.

Kontrola čísla míří schválně jen na jeden dokument. Plošné pravidlo nad dokumentací by
hlásilo desítky legitimních kotev do minulosti. Kontrola typu „číslo se musí rovnat
zdroji" by měla obrácenou polaritu: byla by zelená přesně ve chvíli, kdy dokument lže
starým číslem, a červená po každém vydání.

## Co na tom pořád není dořešené

Kontrola hlídá tvar čísla v jednom dokumentu, ne pravdivost tvrzení v ostatních. Věty typu
„tenhle nástroj zatím nemá tag" nebo „schémat je sedm" žádná kontrola nechytí; ty stárnou
dál a jediná obrana je psát je jako příkaz k přeměření místo jako údaj. Přesně to ten
dokument dnes dělá, ale je to disciplína, ne brána.

Druhá zbytková vada je v tomhle balíčku vidět: jsou v něm dvě čísla, jedno pro balíček
a jedno pro platformu, ze které je vyříznutý. Není to dvakrát totéž, jsou to dvě osy, a je
to napsané na třech místech, aby si toho čtenář všiml dřív, než se zeptá.

## Kde si to v tomhle balíčku ověříš

- `operations/changesets/2026-08-09-mapa-verzi-ukazuje-na-zdroj.md` - včetně poznámky, proč
  se kontrola dělá jen nad jedním souborem a proč šla verze nahoru v MINOR, ne v PATCH.
- [`docs/mapa-verzi.md`](../mapa-verzi.md) - výsledný dokument. Čísla v něm nenajdeš,
  najdeš příkazy.
- `scaffold/VERSION` a `VERSION` v kořeni: dvě čísla, dvě osy, obojí vysvětlené
  v `CHANGELOG.md`.
