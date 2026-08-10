# Sken secretů má domov v METĚ a brána ho od teď spouští nad plochou commitu

**ID:** 2026-08-07-sken-secretu-do-mety-a-kontrola-14
**Osa:** A
**Vydáno:** 2026-08-07
**Autor:** Ariadne
**Závažnost:** běžná
**Zdroj:** META (tento commit)
**Platforma:** 2.8.0
**Týká se:** vše
**Dosah:** dokumentace
**Akce konzumenta:** Žádná pro jednotky. V METĚ: nic navíc, brána běží sama. Kdo dostane FAIL kontroly (14), ověří řádek u zdroje - pravý údaj se rotuje a maže z historie, doložený falešný poplach se umlčí komentářem `sken-secretu:povoleno` na témže řádku, a shodu, kterou vyrábí vzor sám, opraví ve vzoru.

## Co se změnilo

Tři věci, které spolu drží: nástroj dostal správný domov, jeden jeho vzor přestal šumět, a validátor ho začal volat.

**Nástroj se přestěhoval do METY.** `sken-secretu.sh` žil v repozitáři kokpitu, tedy v tenantním artefaktu, přestože ho používá celé portfolio. To je obrácený tok: META nemohla opřít vlastní bránu o skript v cizím repu, aniž by na tom repu závisela. Kanonický domov je od teď `scaffold/tools/sken-secretu.sh` a ke kokpitu odchází kopie vydáním, ne naopak. Zařazeno do indexu platformy jako položka `sken-secretu`; kopie u kokpitu je v ní deklarovaná jako povolená s důvodem (release volá sken nad payloadem, kontrakt K10).

**Vzor `sk-klic` dostal hranici slova.** Bez ní chytal každé slovo končící na „sk" následované pomlčkou - naměřené kontexty `task-`, `risk-`, `opendesk-`. Nad `team-outcomes/` celého portfolia to dělalo osm shod, všech osm tohoto druhu, nula pravých nálezů. Po opravě je jich **nula, měřeno stejnou plochou stejným nástrojem**, a čtyři vymyšlené tvary skutečného klíče se pořád poznají. Značka na tuhle třídu shody by byla špatná náprava: osm značek do cizích repozitářů místo jednoho řádku v registru. Zápis je přes `(^|[^A-Za-z0-9_-])`, ne přes lookbehind - `grep -E` je POSIX ERE a `(?<!...)` v něm neexistuje, takže by vzor na macOS tiše nematchoval nic. To je horší vada než ta původní: šum je vidět, mlčení ne.

**Kontrola (14) ve `validate-platform.sh`.** Měří stejnou dvojici ploch jako kontrola (11): ruční běh disk, režim `--hook` plochu commitu. Váha je FAIL od prvního dne, protože sken nad METOU je dnes ČISTO - pět doložených falešných poplachů (tři v newsletteru v `team-inbox/`, dva ve fixtuře S5 testu workspace) je označených. Jen zelená brána smí být tvrdá; kdyby startovala červená, první, co by kdokoli udělal, je `--no-verify`.

Aby kontrola unesla i ruční běh, dostal nástroj předfiltr: sjednocení všech devíti vzorů do jedné alternace, kterou soubor buď trefí, nebo se devět průchodů přeskočí naráz. Sken METY spadl z 8,2 na 2,6 sekundy při **doslova identickém výstupu** (ověřeno diffem proti verzi bez předfiltru). Brána, kterou lidi obcházejí kvůli čekání, je stejně mrtvá jako brána, kterou obcházejí kvůli šumu.

## Lidská věta

Sken secretů je teď nástroj platformy, ne kokpitu, přestal hlásit každé slovo se „sk" uprostřed, a validátor se ho ptá při každém commitu - takže „secret nikdy v gitu" už nestojí na tom, že si to člověk v pravou chvíli vzpomene.

## Verifikační test

```verify
dokumentace     file_exists     scaffold/tools/sken-secretu.sh
dokumentace     file_exists     scaffold/tests/sken-vzory.sh
dokumentace     grep    scaffold/validate-platform.sh   \(14\) sken secretů
dokumentace     grep    scaffold/validate-platform.sh   SKEN_TOOL="scaffold/tools/sken-secretu.sh"
dokumentace     grep    scaffold/tools/sken-secretu.sh  KANONICKÝ DOMOV
dokumentace     grep    scaffold/tools/sken-secretu.sh  PREDFILTR
dokumentace     grep    scaffold/platform-index-config.json     "id": "sken-secretu"
dokumentace     version_ge      scaffold/VERSION        2.8.0
```

## Poznámky

- Ověřeno průchodem, ne úvahou. `scaffold/tests/sken-vzory.sh` měří čtyři vlastnosti: falešné kontexty shodu nevyrábějí, skutečný tvar klíče se pozná ve čtyřech obalech, značka umlčí právě svůj řádek, a plocha commitu nese jen staged soubor, takže cizí rozpracovaná práce commit nezastaví. Fixtury drží vymyšlené tvary na jednom označeném řádku každý - jinak by test sám shazoval bránu, kterou testuje.
- Kopie v repozitáři kokpitu je zatím starší verze bez opravy vzoru a bez předfiltru. **Návrh Humblemu, neprovádím sama** (cizí repo, osa B): odstranit ji a nechat ji vznikat vydáním z METY. Do té doby platí, že `release.sh` skenuje starším registrem - to není díra v detekci, jen šum navíc.
- Rozšíření registru o další prefixy tokenů a o přihlašovací údaje v URL (nález R-02 ze session kokpitu) je vědomě až po tomhle kroku. Opačné pořadí sečte nový šum se starým a brána se do měsíce vypne.
- Kontrola (14) posuzuje METU, ne knihovnu ani ostatní projekty. Commit v `~/.claude` ani v jednotkách touhle branou neprochází a projít nemůže - hook je v METĚ. Rozšíření skenu na `scaffold/validate.sh` (a tím na všechny jednotky) je otevřená položka, ne opomenutí.
- Dva nezávislé registry vzorů v ekosystému (tenhle a scrubber kokpitu v `app/lib/security.mjs`) nejsou a nemají být v paritě - jiný účel, jiný práh, jeden rediguje a druhý blokuje. Nově to stojí napsané v indexu u položky `sken-secretu`, aby se rozdíl v jejich výsledcích nečetl jako chyba.
