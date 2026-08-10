# Changesety - evidence propagace platformních změn

> Jednotka propagace platformní změny do jednotek a tenantů. Jedna evidence, dvě rozlišené osy.
> **Vlastník mechaniky:** Humble (release engineering). **Vlastník obsahu changesetů:** autor změny.
> **Zavedeno:** 2026-08-03 per B-065, návrh `team-outcomes/024-f3-b065-changeset-baseline-navrh-2026-08-03.md`, oponentura Quentina META.

**Brána platí od:** META `6203423` / GLOBAL `6018074` (META kotva posunuta 2026-08-05, původně `9c2b511` z 2026-08-03)

Commity před tímhle cutoffem se bránou neposuzují. Zavedení je forward-only, historie se retroaktivně nerekonstruuje.

> Posun META kotvy 2026-08-05: commit `77e9a67` (policy blok konfiguračního souboru tenanta, z tenant session, s konsentem Stanislava) vznikl bez changesetu i traileru. Obsah je zpětně formalizován samostatným changesetem; commit samotný se nepokrývá (historie se nepřepisuje, OR-10), kotva se posouvá za něj tímto evidovaným zápisem. Commity mezi původní a novou kotvou byly auditovány: všechny ostatní nesou trailer.

## K čemu to je

Pull model bez evidence má šest doložených selhání (CR 29. 7.): brief bez konzumenta, žádná odpověď na „na jaké verzi běžím", normy, které se z principu nepropagují, dvě nedeklarované propagační cesty, verifikační test nesplnitelný z konstrukce a drift oběma směry. Changeset je adresovaná fronta s testem, ne zpráva v inboxu.

Tři otázky, na které tenhle adresář odpovídá:

1. Co se v platformě změnilo a koho se to týká.
2. Co s tím má jednotka udělat.
3. Jak se pozná, že to udělala.

## Identita a umístění

`operations/changesets/YYYY-MM-DD-<slug>.md` v METĚ.

**ID changesetu je jméno souboru bez přípony.** Žádný druhý tvar identity, žádný prefix `CS-`. Jeden fakt, jeden domov (OR-10). Pole `ID` v hlavičce se musí rovnat jménu souboru, jinak je changeset neplatný.

Slug je krátký, bez diakritiky, malými písmeny, slova spojená pomlčkou.

## Hlavička

Hlavička je pole ve stylu OR-03 (tučný název, dvojtečka, hodnota). Strojově čitelný tvar, který v platformě už žije, takže nezavádí druhou konvenci ani YAML frontmatter s `---` proti NSL stylu.

| Pole | Povinné | Hodnoty |
|---|---|---|
| `ID` | ano | musí se rovnat jménu souboru bez `.md` |
| `Osa` | ano | `A` (agenti, normy, šablony) nebo `B` (software kokpitu) |
| `Vydáno` | ano | `YYYY-MM-DD` |
| `Autor` | ano | kdo změnu udělal, ne kdo ji zapsal |
| `Závažnost` | ano | `běžná` (default) nebo `blokující`; blokující nepřevzatý changeset shodí bránu jednotky, běžný se jen počítá |
| `Zdroj` | ano | commit META a commit GLOBAL v okamžiku vydání changesetu; u osy B navíc tag |
| `Platforma` | ano u osy A | hodnota `scaffold/VERSION` po změně |
| `Týká se` | ano | `vse`, `studio`, `tenant-harness`, `rendered-cockpit`, nebo `jen: <slug>,<slug>` |
| `Dosah` | ano | čárkami oddělené tokeny z pěti vrstev níže |
| `Akce konzumenta` | ano | jedna věta v rozkazovacím způsobu, u vrstvy `sablona` včetně konkrétního příkazu; `žádná` je legitimní hodnota |

Changeset osy B nese navíc `**Vydání:** <repozitář kokpitu> v<X.Y.Z> (tag v<X.Y.Z>)` a v sekci „Co se změnilo" jednu větu s odkazem na Release, ne kopii changelogu. Obsah vydání žije v `CHANGELOG.md` kokpitu; changeset ho nedubluje.

**Granularita se mezi osami liší a je to záměr:** osa A má jeden changeset na jednu platformní změnu, osa B jeden changeset na jedno vydání. Kdyby do METY tekly jednotlivé změny kokpitu, vznikne druhý changelog, který se rozejde s prvním.

Strojové tokeny (`Dosah`, `Týká se`, vrstvy ve `verify`) jsou bez diakritiky, protože je parsuje shell po polích. Lidský text diakritiku má.

## Verze platformy (osa A)

Fronta se počítá v changesetech, ale člověk potřebuje jedno číslo. To už existuje: **`scaffold/VERSION` je verze platformy osy A a je jediný zdroj pravdy o něm.**

- **Bump jde vždy s changesetem**, nikdy samostatně. Číslo bez doprovodné položky ve frontě nikomu nic neřekne a nikdo podle něj nic neudělá.
- **MINOR** když se mění tvar engine souborů nebo kontrakt validátoru, **PATCH** u obsahových změn. MAJOR je rozbití kontraktu jednotek, tedy poslední možnost, ne známka pokroku.
- **Ostatní místa číslo čtou, nedrží.** `validate.sh` ho zapisuje do baseline při převzetí, `render.js` do obou manifestů jako `platform_version`. Jediná druhá kopie je `scaffold_version` v `scaffold/manifest.json` - statický JSON jiný soubor přečíst neumí - a shodu obou míst hlídá kontrola (10) ve `validate-platform.sh`. Ruční synchronizace čísla ve dvou souborech selže při prvním spěchu.

Dvě čísla, která se pletou a **nejsou totéž**: `**Platforma:**` v baseline jednotky je verze v okamžiku posledního převzetí (co jednotka převzala), `platforma_meta` ve strojovém řádku je verze v METĚ teď (kde platforma je). Starší baseline bez druhého čísla vypadá jako aktuální stav.

**Rozdíl obou čísel bez čekajícího changesetu je očekávaný stav a neplyne z něj žádná akce.** Typicky nastane, když se od posledního převzetí vydaly jen changesety s dosahem, který je pro tuhle jednotku `neaplikovatelne` - platforma se posunula, jednotky se to netýká, a číslo v baseline se proto dorovná až při nejbližším převzetí, které se jí opravdu týká. Jednotka, která má co dělat, to pozná podle `stav=pozadu` a `lag`, ne podle rozdílu verzí.

Verze platformy nemá nic společného s `VERSION` v kořeni jednotky kokpitu - to je verze vydání software kokpitu (osa B, dnes `1.x`). Stejné jméno souboru, jiná věc.

## Pět vrstev dosahu

Každá vrstva má jeden motor, jednu akci konzumenta a jedno místo, kde se ověřuje.

| Token | Co to je | Motor | Akce konzumenta | Kde se testuje |
|---|---|---|---|---|
| `runtime-pull` | Jednotka čte kanonické definice, skills a foundation přímo z `~/.claude` za běhu | `git pull` platform library | zpravidla žádná, projeví se při příští session | proti `$HOME/.claude/...` |
| `rendered` | Jednotka konzumuje build artefakt v `<jednotka>/.claude/agents/` | `scaffold/render/render.js` plus instalace | re-render, instalace, commit do tenant repa | proti `render-manifest.json` |
| `sablona` | Jednotka drží kopii engine souboru ze scaffoldu (seznamy `engine` a `engine_tenant` v `scaffold/manifest.json`) | kopie engine souboru při upgradu | zkopírovat konkrétní soubor, příkaz je v changesetu | proti souboru v jednotce |
| `dokumentace` | Manuály NSL (`docs/TECHNIKA.md`, `NAVOD.md`, `SLOVNIK.md`) a produktová dokumentace | ruční zápis v METĚ | žádná, je to položka výrobce | v METĚ, do fronty jednotek nevstupuje |
| `release-kokpitu` | Software kokpitu vydaný z repozitáře kokpitu (osa B) | vydání a konzumace v instanci | aktualizace kokpitu po kliknutí uživatele | proti `cockpit/VERSION` v instanci |

Zdroj kopie u vrstvy `sablona` se nikde nemapuje: **cesta v šabloně je táž jako cesta v jednotce** (`engine` má zdroj v `scaffold/studio-template/`, `engine_tenant` v `scaffold/tenant-template/`). Manifest klasifikuje cesty jednotky, není to kopírovací skript - kdo potřebuje jiný cíl, přesune soubor v šabloně. Obě strany hlídá kontrola (9b) ve `validate-platform.sh`: engine cesta bez souboru v šabloně i soubor v šabloně bez zařazení jsou FAIL.

**Vrstva `dokumentace` se od 6. 8. 2026 opravdu vyhodnocuje.** Do té doby ji `cs_unit_profile()` nedala do profilu žádné jednotce, takže se každý dokumentační řádek vyhodnotil jako mimo profil - vrstvu neslo 9 z 19 changesetů a ani jeden její test se nikdy nespustil. Deklarace bez vynucení je horší než žádná: tvrdí kontrolu, kterou nikdo neprovádí. Nově je `dokumentace` v profilu jednotky, která má adresář `operations/changesets/`, tedy u výrobce (dnes META). Signál je vlastnost jednotky, ne stroje - stejná past jako u `runtime-pull` ve scaffold 2.1.0. Pro jednotky bez toho adresáře se nemění nic a jejich fronty zůstávají beze změny (ověřeno na nich před změnou i po ní).

Praktický důsledek pro autora: řádek `dokumentace no_test` je pořád legitimní, ale teď má smysl psát skutečný test (`grep <soubor v METĚ> <vzor>`). A pozor na uzavřený jazyk - vzor se vyhodnocuje jako rozšířený regulární výraz, takže závorky v textu je nutné escapovat. Prvním nálezem po zapnutí byl přesně takový řádek, který nemohl projít nikdy.

**Šum, který ta oprava odstranila, je změřený a je pryč.** Před 6. 8. 2026 se dokumentační řádky u jednotek vyhodnocovaly jako mimo profil, ale changesety, které vedle nich nesly i jiné neproveditelné testy, držely většinu jednotek v průřezovém stavu `nezjisteno` - report čtecí vrstvy portfolia to tehdy popsal jako šum, který vyrobila platforma. **Měření 9. 8. 2026 napříč všemi jednotkami** (`validate.sh --baseline <jednotka> --line`) vrací `nezjisteno=0` u každé z nich, bez výjimky, a `regrese=0`. Tvrzení z toho reportu tedy platilo do 6. 8. a od té doby neplatí; kdo na něj narazí, ať se řídí měřením, ne textem. Report samotný leží v cizí jednotce a nepřepisuje se - záznam okamžiku je záznam okamžiku, opravuje se novým měřením, ne přepsáním starého.

Poznámka k poslednímu kilometru: rendered artefakty se k uživateli dostávají skrz tenant repo, takže osa A sdílí poslední kilometr s osou B, i když má vlastní motor a vlastní evidenci. Akce konzumenta u vrstvy `rendered` proto zní „re-render plus instalace plus commit do tenant repa", ne jen „re-render".

## Verifikace

### Profil jednotky

Test se formuluje **proti tomu, co konzument opravdu má**, ne proti kanonickému zdroji. To je poučení z 28. 7.: test tehdy nešel splnit, protože hledaný text v osekaném artefaktu z konstrukce být nemohl.

Profil jednotky určuje, které testy se vůbec spustí. Neaplikovatelná vrstva se přeskočí jako `n/a`, nespadne. Profil se detekuje za běhu, nezapisuje se do baseline, aby nestárnul.

| Vrstva profilu | Detekce |
|---|---|
| `rendered` | existuje `<jednotka>/.claude/agents/render-manifest.json` (strana NSL) nebo `render-manifest.public.json` (stroj klienta) |
| `runtime-pull` | existuje `<jednotka>/CLAUDE.md` a jednotka **není** `rendered` |
| `sablona` | existuje `<jednotka>/operations/` nebo `<jednotka>/portfolio-status.md` |
| `release-kokpitu` | existuje `<jednotka>/cockpit/VERSION` nebo `<jednotka>/instance/` |

**Signál profilu je vlastnost jednotky, ne stroje** (oprava ve scaffold 2.1.0). Do 2.0.0 se `runtime-pull` poznával podle existence `$HOME/.claude/agents/`. Ta podmínka na stroji NSL platí vždycky, takže se vrstva přilepila i k jednotkám, které kanonické definice za běhu vůbec nečtou - rendered kokpit i META sama. Jejich testy pak procházely proti knihovně, kterou konzument nikdy neuvidí, a evidence tvrdila, že jednotka změnu má. Falešné PASS je horší než FAIL.

Rozlišení stojí na tom, **odkud jednotka bere definice agentů**: buď drží vlastní sadu artefaktů evidovanou manifestem (`rendered`, self-contained, knihovnu nepotřebuje), nebo je to Claude projekt bez vlastní sady, který je čte z platform library za běhu (`runtime-pull`). Obojí zároveň nedává smysl.

Chybějící knihovna na stroji profil **nemění**: runtime-pull jednotka zůstane runtime-pull a její testy skončí jako `NEZJISTENO`. „Nelze ověřit" a „netýká se mě" jsou dva různé stavy a nesmí splynout.

### Uzavřený jazyk

Blok `verify` je uzavřený jazyk, **žádný shell**. Řetězec z changesetu se nikdy nepředává shellu k vyhodnocení. Řádek má tvar `<vrstva> <sloveso> <cesta> [vzor]`; vzor smí obsahovat mezery a bere se jako zbytek řádku. Cesty jsou relativní ke kořeni jednotky, u sloves `lib_*` ke `$HOME/.claude`.

| Sloveso | Význam |
|---|---|
| `file_exists <cesta>` | soubor existuje |
| `no_file <cesta>` | soubor v jednotce NEexistuje (pro změny, které soubor odebírají; adresář na téže cestě se nepočítá za splněno) |
| `grep <cesta> <vzor>` | soubor obsahuje vzor (`grep -E`) |
| `not_grep <cesta> <vzor>` | soubor vzor neobsahuje (pro odstranění a přejmenování vzoru uvnitř souboru) |
| `lib_file <cesta>` | soubor existuje v platform library `$HOME/.claude` |
| `lib_grep <cesta> <vzor>` | soubor v platform library obsahuje vzor (`grep -E`) |
| `manifest_ge <klíč> <hodnota>` | render manifest: `platform_version` (semver) nebo `date` (ISO) je aspoň hodnota |
| `manifest_has_agent <jméno>` | manifest eviduje agenta daného jména |
| `version_ge <cesta> <semver>` | soubor s číslem verze je aspoň hodnota |
| `no_test` | vědomě bez testu, povoleno jen pro vrstvu `dokumentace` |

Jiné sloveso než z téhle tabulky se vyhodnotí jako `NEZJISTENO`, ne jako chyba parseru a ne jako PASS. Výčet sloves i vrstev má jeden domov - řetězce `CS_SLOVESA` a `CS_VRSTVY` v `scaffold/lib/changeset.sh`. Nové sloveso se přidává na tři místa naráz (výčet, `case` větev v `cs_eval_row`, tahle tabulka) a že se ta místa nerozešla, hlídá `scaffold/tests/verify-slovesa.sh`.

### Vada verify bloku se chytá u autora, ne u konzumenta

`NEZJISTENO` je správná odpověď na "nemám to jak ověřit". U autora je to ale díra: řádek s neznámým slovesem, s nezaescapovanou závorkou nebo s cestou ven z jednotky vrací `NEZJISTENO` **všude a navždy**, takže se changeset nedá přijmout a nikdo se to nedozví, dokud ho někdo nepustí proti reálné jednotce. Třikrát ve třech dnech to znamenalo opravu dodatkem k vydanému changesetu, tedy nejdražší možnou cestu:

| Kdy | Vada | Jak se projevila |
|---|---|---|
| 7. 8. 2026 | nezaescapované závorky ve vzoru | regulární výraz nesplnitelný z konstrukce, test nemohl projít nikdy |
| 8. 8. 2026 | sloveso `meta_grep`, které jazyk nezná | nic tiše neprošlo, ale changeset nešel přijmout |
| 9. 8. 2026 | `lib_grep` hledal formulaci, kterou pozdější změna přejmenovala | jednotky hlásily regresi, přestože knihovna byla věcně v pořádku |

Od scaffold 2.11.0 to zavírá kontrola **(17)** ve `validate-platform.sh`, tedy brána v okamžiku commitu:

- **(17a) tvar** - každý řádek musí být vyhodnotitelný: známá vrstva, známé sloveso, cesta relativní a bez `..`, vzor přeložitelný jako `grep -E`, `no_test` jen na vrstvě `dokumentace`, `manifest_ge` jen s klíčem `platform_version` nebo `date`. Fail-closed nad celým adresářem - vada v kterémkoli changesetu je vada evidence.
- **(17b) splnitelnost knihovních testů** - `lib_grep` a `lib_file` se vyhodnotí proti platform library. Knihovna je jedna a je to táž strana, kde změna vznikla, takže `FAIL` neznamená "konzument ještě nepřevzal", ale "test je vedle". Váha se liší podle toho, čí je to práce: co měřená plocha zakládá nebo mění, je **FAIL** (autor je u toho a oprava stojí minutu), vydaný changeset je **WARN** a opravuje se dodatkem, ne úpravou knihovny.

Co brána z principu nechytne: `grep` a `not_grep` proti jednotce. Tam je `FAIL` legitimní stav ("konzument to ještě nepřevzal"), takže z něj nejde udělat nález u autora.

### Změna, která zůstává v METĚ

Otázka, která vedla k vymyšlenému slovesu `meta_grep`: jak ověřit změnu, jejíž propis nekončí ani v knihovně, ani v jednotce - typicky znění normy, manuál nebo kontrakt mechanismu?

**Sloveso pro to nechybí a nepřidává se.** Cesty u sloves `grep`, `not_grep`, `file_exists` a `no_file` jsou relativní ke kořeni **vyhodnocované jednotky** a META je jednotka jako každá jiná - má `CLAUDE.md`, `operations/` i vlastní baseline. Vrstva `dokumentace` je navíc v profilu jen té jednotky, která má adresář `operations/changesets/`, tedy dnes výhradně METY. Řádek

```
dokumentace   grep   CLAUDE.md   OR-12 v2
```

se proto vyhodnotí v METĚ proti souboru METY a všem ostatním jednotkám vyjde jako mimo profil (`n/a`), aniž by jim vstoupil do fronty. Přesně to je chování, které autor od „meta testu" čeká.

Proč se nepřidává `meta_*` sloveso: druhá cesta k témuž se rozejde s první (OR-10). Sloveso, které by mířilo na METU napevno, by navíc dávalo smysl jen na stroji, kde META leží - u konzumenta by vracelo `NEZJISTENO`, tedy šum v cizí frontě.

Praktické pravidlo pro autora: **vrstva `dokumentace` plus `grep` na soubor v METĚ**, ne `no_test`. `no_test` zůstává legitimní tam, kde se opravdu nedá co změřit; brána (17a) ho pustí jen na téhle vrstvě.

Obě `manifest_*` slovesa čtou **build manifest** `render-manifest.json`, a když na stroji není (typicky u klienta, kde je gitignorovaný), sáhnou po trackovaném `render-manifest.public.json`. Datum renderu drží build manifest pod klíčem `date`, public pod `rendered`; sloveso zná obojí.

### Tři výsledky, ne dva

`PASS`, `FAIL`, `NEZJISTENO`.

`NEZJISTENO` nastane, když soubor nejde přečíst, sloveso je neznámé, manifest chybí nebo je nečitelný, nebo platform library na stroji není. **Nikdy se nepočítá jako PASS** (fail-closed) a vykazuje se ve vlastní kolonce, aby se neschovalo do nuly. Je to ten stav, na který se zapomíná, a přesně ten nastane u jednotky na cizím stroji nebo u poškozeného manifestu.

Changeset bez bloku `verify` je neplatný a brána ho neuzná jako pokrytí. Prázdný changeset by z brány udělal razítko.

## Šablona changesetu

~~~markdown
# Krátký titulek v běžné češtině

**ID:** 2026-08-03-neco-se-zmenilo
**Osa:** A
**Vydáno:** 2026-08-03
**Autor:** Kdo změnu udělal
**Závažnost:** běžná
**Zdroj:** META <sha> | GLOBAL <sha>
**Platforma:** 2.1.0
**Týká se:** vse
**Dosah:** runtime-pull, dokumentace
**Akce konzumenta:** žádná

## Co se změnilo

Dvě až tři věcné věty. Bez marketingu, bez převyprávění normy.

## Lidská věta

Jedna věta pro člověka, který jednotku obsluhuje. Píše ji autor změny v okamžiku změny,
ne Humble při vydání. Šablonu pole (tři otázky pro autora) drží Komenský.

## Verifikace

```verify
runtime-pull   lib_file   agents/nekdo.md
dokumentace    no_test
```

## Poznámky

Volitelné. Vazby na backlog, rizika, co se vědomě neudělalo.
~~~

## Dodatek k vydanému changesetu

Changeset má dvě poloviny a každá má jiný režim. **Záznam** (co se v platformě stalo) je historie a je neměnný stejně jako vydaný tag. **Instrukce frontě** (co s tím má konzument udělat) je živá: popisuje práci, která u části jednotek teprve čeká, a když se svět mezitím posune, zůstane v každé nepřevzaté frontě stát nepravda.

Přesně to nastalo 6. a 7. 8. 2026 u changesetu o čtení znalostní báze orchestrátory: pole `Akce konzumenta` neslo větu „re-render u tenanta zatím nespouštěj", jejíž důvod (exact-match deny list) zanikl allowlistem ve scaffold 2.6.0. Věta zůstala v položce fronty a každý další konzument by ji řešil znovu.

**Proč ne novým changesetem.** Fronta je adresovaná a čte se položku po položce; nový changeset uvidí jen ten, kdo k němu dojde, a starou položku z jeho seznamu neodstraní. Konzument by musel u každé instrukce dohledávat, jestli ji něco pozdějšího neruší - a to je přesně ta práce, kterou má fronta ušetřit.

**Co se smí dodatkem změnit:**

| Pole | Smí | Podmínka |
|---|---|---|
| `Akce konzumenta` | ano | instrukce je neplatná nebo nebezpečná, ne „šla by napsat líp" |
| `Týká se` | ano | rozšíření rozsahu bez omezení; zúžení jen s důvodem, protože promíjí práci |
| `Závažnost` | ano | zpřísnění bez omezení; změkčení jen s důvodem |
| blok `verify` | výjimečně | jen test nesplnitelný z konstrukce (nemohl projít nikdy a nikomu). Změkčení testu, který někdy prošel, je zakázané - baseline by začala tvrdit převzetí, které se nestalo |

**Co se dodatkem změnit nesmí:** `ID`, `Osa`, `Vydáno`, `Autor`, `Zdroj`, `Platforma`, sekce „Co se změnilo" a „Lidská věta". To je záznam okamžiku a přepsat ho je totéž co přepsat vydaný tag (OR-10).

**Tvar.** Do hlavičky přibude pole `**Dodatek:** YYYY-MM-DD, <kdo>, <jedna věta proč` a na konec souboru sekce `## Dodatky` s původním zněním doslova. Pole je signál pro čtenáře fronty, sekce je stopa. Bez obojího dodatek neplatí a hlásí ho kontrola **(16)** ve `validate-platform.sh` (obě strany: pole bez sekce i sekce bez pole).

Dodatek nese vlastní changeset jen tehdy, když sám mění platformu. Oprava instrukce ve frontě je údržba evidence, ne nová platformní změna - jinak by každá oprava překlepu vyrobila položku, kterou musí odbavit každá jednotka.

## Baseline jednotky (osa A)

Soubor `operations/platform-baseline.md` v kořeni jednotky. Odpovídá na otázku „které platformní změny tahle jednotka převzala".

### Formát

~~~markdown
# Platform baseline - <slug jednotky>

**Jednotka:** <slug jednotky>
**Platforma:** 2.1.0
**META commit:** 9c2b511 (2026-08-03)
**GLOBAL commit:** 6018074 (2026-08-03)
**Poslední render:** 2026-07-29, platforma 2.0.0
**Převzato changesetů:** 3
**Poslední převzetí:** 2026-08-03, 2026-08-03-zaveden-mechanismus-propagace

## Převzaté changesety

| ID | Datum převzetí | Kdo | Ověření |
|---|---|---|---|
| 2026-08-03-zaveden-mechanismus-propagace | 2026-08-03 | orchestrátor tenanta | 2 testy PASS |

## Rolling log

(historie převzetí a poznámky, per OR-10 pod headerem)
~~~

Header je distilát, tabulka evidence, log historie. Stejná disciplína jako OR-03 a OR-10, takže se nemusí učit nic nového. Pole `Poslední render` je `n/a` u jednotky bez rendered profilu.

**Identitu jednotky v hlavičce (titulek i pole `Jednotka`) dorovnává nástroj sám při každém převzetí** (od scaffold 2.1.1 obojí, do 2.1.0 jen pole). Je odvozená z umístění souboru, takže o převzetí nic netvrdí a přepsat ji je bezpečné. Baseline založená přes relativní cestu (`--baseline .`) proto nepotřebuje ruční opravu - stačí ji nechat být do nejbližšího acceptu.

**Commity v headeru jsou kotvy okamžiku převzetí, ne jednotka lagu.** Rozdíl commitů mezi dvěma repozitáři se skoro celý skládá z commitů, které se dané jednotky netýkají. „Pozadu o 47 commitů" je šum, po kterém nikdo nic neudělá; „pozadu o 2 changesety" je věta, po které někdo něco udělá. Lag se počítá v changesetech.

### Čtyři kategorie fronty

Model fronty je hybrid evidence a stavu: k seznamu převzatých ID se při každém reportu doplní výsledek testů. Rozhodnuto v oponentuře Quentina META 3. 8. 2026.

| Kategorie | Podmínka | Význam |
|---|---|---|
| `prevzato` | je v baseline a všechny spuštěné testy PASS | v pořádku |
| `ceka` | není v baseline, nebo aspoň jeden test FAIL při chybějícím záznamu | čeká na akci konzumenta |
| `regrese` | je v baseline, ale test teď FAIL | někdo to vrátil zpátky, nebo re-render něco upustil |
| `neaplikovatelne` | changeset míří jen do vrstev mimo profil jednotky | do fronty nevstupuje, počítá se zvlášť |

K nim `nezjisteno` jako průřezový stav: aspoň jeden test skončil `NEZJISTENO` a žádný nespadl. Nikdy se nesčítá s nulou a má vlastní kolonku.

Kategorie `regrese` je to, co prostá evidence ID nikdy neuvidí: přepsaný engine soubor nebo render, který agenta upustil.

### Kdo smí do baseline zapsat

**Jen nástroj a jen po PASS testu.** Ruční editace baseline je technicky možná (je to Markdown), ale je to porušení disciplíny na úrovni ručního přepsání rendered artefaktu. Vázání zápisu na průchod testem je to, co uzavírá riziko „baseline lže, že jsme synchronní".

Když test projít nemůže (jednotka na cizím stroji bez platform library), výsledek je `NEZJISTENO` a převzetí se odmítne zapsat. Legitimní východisko je vynucené převzetí s povinným důvodem, které zapíše řádek s viditelnou poznámkou „ověření nezjištěno, převzato na slovo". Brána bez východiska se obchází celá a mlčky; brána s evidovaným východiskem nechá stopu.

### Založení baseline u jednotky, která ji nikdy neměla

Rozhodnuto 7. 8. 2026 (Humble), poprvé použito při zavedení evidence šestnácti jednotkám.

Jednotka bez baseline zdědí celou frontu od nuly. To je z konstrukce správně (`nikdy nedeklarováno` není totéž co `aktuální`), ale prakticky vzniká fronta desítek položek, ze kterých většina už je fakticky splněná - jednotka změnu má, jen o tom nemá papír. Takovou frontu nikdo neodbaví a neodbavená fronta je horší stav než žádná evidence.

**Pravidlo: baseline se zakládá měřením, ne dekretem.** Projdi frontu položku po položce a na každou pusť `--accept`. Nástroj sám zapíše jen to, co projde testem, a zbytek odmítne. Výsledná evidence tedy neříká „nasadili jsme tě na dnešní číslo", ale „tohle jsi měřitelně měl a tohle ti opravdu chybí".

```
for id in <ID z fronty>; do
  validate.sh --baseline <jednotka> --accept "$id" --kdo "Humble (založení evidence)"
done
```

Tři vlastnosti, kvůli kterým je to lepší než plošný cutoff k dnešní verzi:

- **Nelže.** Cutoff by zapsal i změny, které jednotka nemá; měření zapíše jen to, co projde týmž testem jako běžné převzetí. Vázání zápisu na PASS platí i tady, žádná zvláštní cesta do baseline nevzniká.
- **Nezametá práci.** Co neprojde, zůstane ve frontě jako skutečná položka k odbavení. Cutoff by ji utopil.
- **Nepotřebuje nový nástroj.** Je to smyčka nad existujícím `--accept`, takže neexistuje druhá cesta zápisu, kterou by bylo nutné hlídat.

**Pořadí má jedno pravidlo:** changeset `2026-08-03-zaveden-mechanismus-propagace` se přijímá jako poslední. Jeho test je existence a tvar baseline, takže projde teprve poté, co ji předchozí zápis založil. Při jiném pořadí zůstane trvale ve frontě.

Sloupec `Kdo` u takto vzniklých řádků nese `Humble (založení evidence)`, aby bylo z evidence poznat, že převzetí nebylo vědomý krok orchestrátora jednotky, ale doměřený stav. Nic to nemění na platnosti - měřený stav je stav.

**Kdy se pravidlo nepoužije:** u jednotky, která baseline má. Tam je běžná cesta odbavení fronty jediná správná, protože rozdíl mezi „nemám papír" a „nepřevzal jsem" je u takové jednotky reálný.

## Rozlišení proti baseline instance kokpitu (osa B)

Jedna jednotka (kokpit nasazený u tenanta) ponese obě baseline zároveň, proto se nesmí jmenovat stejně.

| | Baseline jednotky (osa A) | Baseline instance kokpitu (osa B) |
|---|---|---|
| Soubor | `operations/platform-baseline.md` | `instance/cockpit-baseline.json` |
| Předmět | Claude projekt: jednotka a její provozní vrstva | nainstalovaný software kokpitu |
| Otázka | „Které platformní změny jsem převzal?" | „Které vydání kokpitu tady běží?" |
| Kdo zapisuje | validační nástroj po PASS testu | sync a aktualizační nástroj kokpitu |
| Formát | Markdown, header ve stylu OR-03 | JSON |
| Kde vzniká | při převzetí changesetu | při instalaci a při každé aktualizaci |

Jméno `instance/cockpit-baseline.json` je rozhodnutí oponentury Quentina META 3. 8. 2026 (rename z dřívějšího návrhu `instance/platform-baseline.json`). Soubor zatím neexistuje, propíše se do nástrojů osy B v F1.

## Brána v METĚ

Bez brány je changesetový model jen dražší varianta dnešního stavu.

### Hlídané cesty

Platform library `~/.claude`: `agents/*.md`, `skills/**`, `commands/**`, `hooks/**`, `foundation/**`, `nsl/**`.
Nehlídané tamtéž: `CLAUDE.md` (vrstva USER, nedistribuuje se), `settings.json`, `projects/**`, `todos/**`, credentials.

META (repozitář platformy): `scaffold/**`, `CLAUDE.md` (znění norem OR, always-loaded vrstva), znění AR rozhodnutí, konvence přenositelného Markdownu.
Nehlídané v METĚ: `operations/**`, `team-inbox/**`, `team-outcomes/**`, `docs/**`, `research/**`, `strategic/**`, `team/**`, `experiments/**`, `automation/**`.

**Každá změna kanonické definice agenta v `~/.claude/agents/*.md` vyžaduje changeset** (rozhodnuto v oponentuře). Je to přesně ta změna, která se má propsat do renderů; cena je jeden soubor navíc při hire i při úpravě persony.

`nsl/**` je domov odvozenin firemního obsahu (destilát Foundation per rozsudek Ariadne, `team-outcomes/046`). Do hlídaných cest přistál **dřív, než v něm vznikl první soubor** - opačné pořadí by znamenalo obsah mimo bránu, tedy přesně ten mezistav, kvůli kterému rozsudek vznikl. Na obsah adresáře se navíc dívá kontrola (13) ve `validate-platform.sh`: soubor pod `nsl/` musí v hlavičce nést režimní marker odvozeniny (`**Zdroj pravdy:** Notion`, `**Zapisuje:** nástroj`) a soubor pod `foundation/` ho nést nesmí. Klasifikaci tak nese obsah a cesta je tvrzení, které se proti němu ověřuje.

`docs/**` vědomě nehlídáme. Manuály jsou artefakt METY, ne jednotky; kdyby překlep v `NAVOD.md` vyžadoval changeset, brána začne šumět a šumící brána se do měsíce vypne. Dokumentace je v changesetu jako **dosah**, ne jako spouštěč.

### Dva režimy

**Pracovní strom (default).** Jsou-li v kterémkoli z obou repozitářů rozpracované, staged nebo neevidované změny pod hlídanými cestami a zároveň v pracovním stromu METY není nový ani změněný soubor `operations/changesets/*.md`, kontrola je FAIL se seznamem cest. Chytá autora před commitem.

**Rozsah commitů.** Pro každý commit v rozsahu, který sahá na hlídané cesty, je pokrytím buď changeset dotčený týmž commitem (jen v METĚ), nebo trailer v hlášce commitu. Slouží k retroaktivnímu auditu a je to hotový vstup pro budoucí běh na PR, až pro něj bude důvod.

### Co se počítá jako pokrytí

- V METĚ: commit sahá i na `operations/changesets/*.md`, nebo hláška nese trailer `Changeset: <ID>` odkazující na existující soubor.
- V platform library (jiný repozitář, changeset v něm ležet nemůže): jen trailer `Changeset: <ID>`.
- Changeset s neúplnou hlavičkou nebo bez bloku `verify` se jako pokrytí neuzná.
- Úniková cesta: `Changeset: none (<důvod>)`, důvod povinný a neprázdný. Překlep v komentáři changeset nepotřebuje. Východisko je **evidované** a dohledatelné v historii, což je celý jeho smysl.

### Evidované výjimky

Commit, který pokrytí nemá a mít ho už nemůže, protože se historie nepřepisuje (OR-10). Zapisuje se sem jmenovitě, ne posunem kotvy: kotva je jeden bod a každý její posun promine celý rozsah před sebou, takže by se z ní stal mechanismus výjimek - jenže neviditelný, protože po posunu už není co počítat. Jmenovitá výjimka je užší, spočitatelná a vypíše ji každý běh brány.

Podmínky, aby brána výjimku uznala: řádek má neprázdný důvod a sloupec formalizace odkazuje na platný changeset, nebo je v něm `-`. Neplatný odkaz výjimku ruší a commit zůstane nepokrytý (fail-closed).

| Repo | Commit | Důvod | Formalizace |
|---|---|---|---|
| META | `528cf68` | commit z 5. 8. sáhl na konfigurační soubor tenanta bez traileru i bez changesetu; zjištěno až zpětně, kdy pokrytí doplnit nejde | `2026-08-06-render-overlaydir-autorsky-domov` |

Tenhle jediný zápis je zároveň důvod, proč od 6. 8. 2026 existuje hook `commit-msg`: trailer se dá vynutit v okamžiku commitu, kdy je oprava levná. Kontrola (8a) ho umí posoudit jen zpětně.

## Kdo co vlastní

Mechanismus staví Humble, obsah do něj nepatří. Heuristika: potrubí, ne obsah.

| Věc | Vlastník |
|---|---|
| Formát changesetu, baseline, fronta, brána, testovací jazyk | Humble |
| Obsah kanonických definic agentů | Panoš (OR-09) |
| Znění norem AR a OR, kanonické texty AR-13 a OR-12 | Quentin META |
| Šablona pole „Lidská věta" (tři otázky pro autora), redakce zákaznických textů | Komenský |
| Lidská věta ke konkrétní změně | autor té změny, v okamžiku změny |

Kanonické texty AR-13 (propagace platformních změn) a OR-12 (disciplína changesetů) zapisuje Quentin META. Tenhle README popisuje mechanismus, ne normu.

## Automatické spouštění brány

Brána, kterou nikdo nespouští, není brána. 6. 8. 2026 hlásil validátor platformy dva FAILy, které nikdo neviděl, protože ho od posledního ručního běhu nikdo nepustil. Proto jsou od téhle verze v repu dva hooky.

Kromě pokrytí (8a) posuzuje pre-commit brána i **obsah** verifikačních bloků: kontrola (17) zastaví commit s changesetem, jehož `verify` blok nejde vyhodnotit, a u knihovních testů rozliší rozpracované (FAIL) od vydaných (WARN). Detail v sekci „Vada verify bloku se chytá u autora" výš.

| Hook | Co dělá | Proč zvlášť |
|---|---|---|
| `scaffold/hooks/pre-commit` | spustí `validate-platform.sh`, FAIL zastaví commit | jedna odpovědnost, žádná vlastní logika |
| `scaffold/hooks/commit-msg` | commit sahající na hlídané cesty musí nést trailer `Changeset:` | pre-commit běží dřív, než zpráva existuje, takže chybějící trailer neumí vidět |

Hooky jsou **verzované soubory**, ne obsah `.git/hooks/`. Změna hooku je normální diff a nese changeset jako každý engine soubor; kdyby hook žil jen v `.git/hooks/`, spouštěl by se při každém commitu, nešel by diffnout a o jeho degradaci by se nikdo nedozvěděl.

Aktivace je jednorázová a explicitní, per klon: `bash scaffold/install-hooks.sh --install` (nastaví `core.hooksPath`). Bez `--install` instalátor jen vypíše stav. Zpět: `--uninstall`. Klonování repa nikomu nic nezapne.

Úniková cesta z obou hooků: `git commit --no-verify`. Obejití není tiché - kontrola (8a) chytne commit bez pokrytí zpětně při příštím běhu.

Dvě vlastnosti, které za tím stojí a jsou vědomé (posudek Ariadne, `team-outcomes/041` sekce 5.1): hook vykonává pracovní strom, který hlídá, a proto validátor před každým sourcováním i spuštěním relativní cestou ověří `git ls-files --error-unmatch` (brána G3) - vykoná se jen to, co je v gitu. Umístit soubor do stromu tedy nestačí k tomu, aby se při příštím commitu spustil.

## Index platformy

Vedle propagace do jednotek stojí druhá třída změn: **změna kanonického domova, kterou nikdo nepřebírá, ale čte ji čtecí vrstva** (kokpit, session). Changeset se za ni nevyžaduje - `docs/**` zůstává mimo hlídané cesty a šumící brána se vypne. Evidencí je index.

| Artefakt | Co to je | Kdo zapisuje |
|---|---|---|
| `scaffold/platform-index-config.json` | deklarace: co kanonický domov JE (schéma `platform-index-config/v1`) | člověk; obsah Quentin META, tvar Humble |
| `project-init/platform-index.json` | kanonický strojový index: deklarace plus měření disku (schéma `platform-index/v1`) | výhradně `scaffold/gen-platform-index.sh` |
| `docs/index-platformy.md` | lidský rozcestník, odvozenina téhož běhu | tentýž generátor |

Index je **index skutečnosti, ne evidence záměru**: ruční editace je neškodná právě proto, že regenerace přepisuje. Tím se liší od `platform-baseline.md`, kde je ruční editace lež. Bezpečnostní protějšek téže věty: výstup musí být reprodukovatelný z disku, protože rozdíl znamená ruční vsuvku a ruční vsuvka do indexu je neauditované řízení pozornosti session.

Tři hranice měření, aby index nešuměl a nelhal:

- Otisk obsahu se počítá jen u položek pod `{META}`. `{LIB}` nese jen existenci, ostatní kořeny ani to - brána METY nesmí padat na úpravu v cizím repu.
- Vlastní výstupy generátoru se neměří obsahem, jen existencí. Jinak by se `--check` nikdy neshodl sám se sebou.
- Poslední commit souboru se do indexu nezapisuje. Zjišťuje se před commitem, takže by byl vždycky o krok pozadu.

Kanál obsahu cizího původu (`team-inbox`) do indexu nepatří a generátor ho vynechá, i když ho deklarace zná. Vyloučení je hlasité a spočítané, ne tiché.

Kontroly ve `validate-platform.sh`: **(11)** shoda indexu s měřenou plochou (`gen-platform-index.sh --check`; východisko je regenerace, ne výjimka) a **(12)** parita s tím, co o sobě čtecí vrstva kokpitu exportuje. Váha (11) se řídí polem `stav` v deklaraci: dokud není `platny`, je rozdíl WARN - vlastník obsahu bránu zapne jedním slovem. (12) je vždy WARN a nikdy nic nepovoluje: index vybírá, allowlist autorizuje, nikdy naopak.

### Plocha commitu, když v repu pracuje víc agentů

Do 6. 8. 2026 měřila (11) vždycky pracovní strom. Na stroji, kde běží víc agentů naráz, to znamená dvě věci a obě jsou špatně: jedna rozdělaná změna v měřeném domově zablokuje commit každému dalšímu, i když se jí jeho commit netýká, a kdo index přegeneruje, zapíše do něj otisky obsahu, který v commitu není a nemusí být nikdy. První den ostrého provozu udělalo obojí - zablokované dva nezávislé commity a brána, kterou se začalo vyplácet obcházet.

Od scaffold 2.5.0 posuzuje (11) **plochu commitu**, když validátor běží pod `--hook`, a pracovní strom, když ho spustí člověk. Plocha není měkčí kritérium: chytne i částečný commit, který od sebe oddělí index a měřený obsah, což pracovní strom neumí (na disku sedí obojí, v commitu je jen půlka). Zbytkový rozdíl „disk se od indexu liší kvůli cizí nezacommitované práci" se hlásí jako poznámka s výčtem viníků a commit nezastavuje - cizí pracovní stůl není stav platformy a uklidí ho vlastní commit toho, kdo na něm pracuje.

Praktický důsledek pro autora: na stroji s víc agenty regeneruj index z plochy, ne z disku.

```
bash scaffold/gen-platform-index.sh . --plocha -- <cesty, které commituješ>
git add project-init/platform-index.json docs/index-platformy.md
git commit -m "..." -- <cesty> project-init/platform-index.json docs/index-platformy.md
```

Na klidném stroji zůstává `bash scaffold/gen-platform-index.sh .` správně - obojí dá stejný výsledek, jakmile je pracovní strom čistý.

## Nástroj

```
gen-platform-index.sh <kořen-META>            # zapíše index i rozcestník
gen-platform-index.sh <kořen-META> --check    # porovná s diskem, exit 1 při rozdílu
gen-platform-index.sh <kořen-META> --list     # strojový výpis položek
gen-platform-index.sh <kořen-META> --plocha [-- <cesty>]   # měří plochu commitu, ne disk

install-hooks.sh                              # stav bran, nic nemění
install-hooks.sh --install | --uninstall      # zapnutí a návrat

validate.sh --baseline <cesta-k-jednotce>                       # report a fronta
validate.sh --baseline <cesta-k-jednotce> --line                # jen strojový řádek
validate.sh --baseline <cesta-k-jednotce> --verify <ID>         # testy jednoho changesetu, nic nezapíše
validate.sh --baseline <cesta-k-jednotce> --accept <ID> --kdo "<jméno>"
validate.sh --baseline <cesta-k-jednotce> --accept <ID> --force --duvod "<věta>"
```

Zdroj changesetů: `$NSL_META_ROOT`, jinak `<kořen platformy>` odvozený od umístění skriptu. Když se META nenajde, výsledek je `nezjisteno` a návratový kód 3, nikdy tiché „aktuální".

### Strojový řádek je kontrakt, ne vlastnost implementace

Tady je jeho kanonický popis. Stojí na něm čtecí vrstva portfolia i startup check orchestrátorů, takže se s ním nezachází jako s výpisem, ale jako s rozhraním.

```
BASELINE jednotka=<slug> stav=<aktualni|pozadu|regrese|blokovano|nezjisteno> lag=<N> regrese=<N> nezjisteno=<N> blokujici=<N> vadne=<N> platforma=<verze|nezjisteno> platforma_meta=<verze|nezjisteno> profil=<a,b,c>
```

Pět bodů, které se nesmí porušit:

1. **Je to PRVNÍ řádek standardního výstupu, na každé cestě kódu** - i na chybové (nenalezená META, chybějící parser, chyba použití). Nic se před něj netiskne; proto režim `--baseline` netiskne ani úvodní hlavičku `Validace: ...`, kterou mají ostatní režimy.
2. **Pole se čtou podle klíče, ne podle pozice.** Přidat pole je aditivní změna, kterou konzument nepozná; odebrat nebo přejmenovat je rozbití kontraktu (MAJOR).
3. **Diagnostika jde na stderr**, nikdy na stdout před strojový řádek.
4. **S `--line` je ten řádek jediným výstupem** na stdout.
5. **Návratové kódy:** `0` aktuální nebo běžně pozadu (v pull modelu je být pozadu normální stav, ne poplach), `1` regrese nebo blokující changeset ve frontě, `3` nezjištěno, `2` chyba použití.

Význam polí: `lag` je počet nepřevzatých changesetů, `vadne` počet changesetů s neúplnou hlavičkou nebo bez bloku `verify` (do fronty nevstupují, patří k opravě u autora). `platforma` je verze zapsaná v baseline při posledním převzetí, `platforma_meta` (od scaffold 2.1.0) verze platformy v METĚ teď.

Kontrakt hlídá průchodem `scaffold/tests/strojovy-radek.sh` (od scaffold 2.11.0). Do té doby to byla vlastnost implementace: stačil jeden `printf` navíc před ten řádek a čtečky by tiše přestaly číst fronty - bez chyby, bez hlášky, jen s prázdnem tam, kde býval stav.

Přepínač `--take` je zastaralý alias `--accept`. Ohlášeno ve scaffold 2.1.0, odstranění nejdřív ve scaffold 3.0.0.

## Co ještě není postavené

Poctivý stav k 3. 8. 2026 večer (scaffold 2.1.0), aby se nikdo neopíral o něco, co neexistuje:

- Kontrola parity **(9c)** šablona proti knihovně - není (P3). Kontrola **(9b)** hotová ve scaffold 2.3.0, ale proti **šabloně**, ne proti referenční jednotce: šablona je zdroj, jednotka jeho kopie, a kontrolovat kopii dřív než zdroj chytá následek. Porovnání proti živé jednotce zůstává na `validate.sh --baseline`.
- Režim `validate-platform.sh --since` nad delší historií jako retroaktivní audit - přepínač existuje, systematicky proběhnutý není.
- Povýšení kontroly hashe artefaktu z WARN na FAIL - horizont scaffold 3.0.0, dnes se `output_sha256` proti disku neporovnává vůbec (drift se pozná jen přes `tools`).
- Baseline tenantního harnessu - nezaložena, fronta se mu počítá od nuly.
- Chování `--baseline` na stroji klienta - netestováno, mechanismus s tím nepočítá (fronta se pro nasazený kokpit počítá na straně NSL nad dev kopií).

Hotové a ověřené průchodem: brána (8a) a (8b), parita (9a), (9b) a (9d), kontrola verze (10), baseline platformy i baseline jednotek portfolia i kokpitu nasazeného u tenanta, sloupec Platforma ve čtecí vrstvě portfolia, detekce profilu podle vlastnosti jednotky a public manifest z renderu.
