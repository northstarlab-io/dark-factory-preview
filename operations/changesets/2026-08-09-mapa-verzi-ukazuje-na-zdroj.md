# Mapa verzí ukazuje na zdroj čísla, neopisuje ho

**ID:** 2026-08-09-mapa-verzi-ukazuje-na-zdroj
**Osa:** A
**Vydáno:** 2026-08-09
**Autor:** Humble
**Závažnost:** běžná
**Zdroj:** META (tento commit) | GLOBAL 48f06eb
**Platforma:** 2.14.0
**Týká se:** vse
**Dosah:** dokumentace
**Akce konzumenta:** žádná; kdo hledá dnešní číslo kterékoli osy, najde v `docs/mapa-verzi.md` příkaz, kterým si ho přečte, místo čísla psaného rukou.

## Co se změnilo

`docs/mapa-verzi.md` přestal držet živá čísla. Kde dřív stálo dnešní číslo osy, stojí teď cesta ke zdroji a příkaz; nový blok „Jak si dnešní čísla přečteš" má šest příkazů pro všechny čtyři osy včetně výčtu souborů `VERSION` a výčtu schémat. Sloupce „Dnes" a „Číslo dnes" ze dvou tabulek zmizely, protože jejich obsah byl z konstrukce odsouzený k zastarání.

**Vada, která to spustila.** Dokument vznikl 7. 8. 2026 a 9. 8. tvrdil, že osa A je na `v2.10.1`, zatímco platforma byla o tři vydání dál. Druhý domov čísla driftuje i uvnitř dokumentu, který před druhými domovy čísel varuje - to je ta nejlevnější možná ukázka, že apel na pečlivost mechanismus nenahradí.

**Měřením se ukázalo, že zastaralé číslo nebylo jediné.** Tři jednotky, o kterých text tvrdil, že nesou v kořeni `VERSION`, ho už nemají. Kokpit, o kterém text tvrdil, že nemá tag, ho mezitím má. Výčet schémat osy D obsahoval sedm položek, zatímco měření jich najde třináct. Osa C byla popsaná jako „dnes jeden nástroj" a mezitím přibyl druhý. Žádná z těch vět nebyla napsaná ve zlé víře, všechny čtyři zestárly stejným způsobem.

**Historické číslo se odlišilo typograficky, aby šlo rozlišit strojově:** doklad o minulosti a horizont odstranění se píše s předponou `v` (`v2.0.0`), živé číslo v dokumentu být nesmí vůbec. Dokument to o sobě říká v nové sekci „Proč tu skoro nejsou čísla", takže pravidlo se čtenář dozví na místě, kde ho potřebuje.

**Nová kontrola (18) ve `validate-platform.sh`** to drží: nad `docs/mapa-verzi.md` hlásí číslo verze psané rukou bez předpony `v`. Adresy typu `127.0.0.1` se před posouzením odstraní, jinak by kontrola padala hned na větě o portu kokpitu.

## Lidská věta

Mapa verzí už neříká, jaká čísla dneska platí, ale kde si je přečteš. Kdo potřebuje aktuální hodnotu, zkopíruje si příkaz z bloku „Jak si dnešní čísla přečteš"; číslo v textu tam zůstalo jen tam, kde popisuje minulost, a pozná se podle `v` na začátku.

## Verifikace

```verify
dokumentace   grep   scaffold/validate-platform.sh   V18_SOUBORY
dokumentace   grep   docs/mapa-verzi.md   Jak si dnešní čísla přečteš
dokumentace   not_grep   docs/mapa-verzi.md   Dnešní stav
```

## Poznámky

**Ostatní manuály tuhle vadu nemají, a je to změřené, ne odhadnuté.** `docs/TECHNIKA.md`, `docs/NAVOD.md` a `docs/SLOVNIK.md` nesou dohromady 31 výskytů čísla verze a všechny jsou kotvy do minulosti nebo horizonty odstranění („od platformy 2.6.0", „ve scaffold 2.3.0", „odstranění ve scaffold 3.0.0"). Ani jeden neříká, kde platforma je teď. `docs/index-platformy.md` číslo nese, ale píše ho generátor, takže zastarat nemůže. NAVOD má dokonce hotovou formulaci téhož principu („číslo si přečti v souboru, tenhle manuál ho vědomě neopisuje") - ta věta byla vzorem pro dnešní opravu.

**Proč kontrola jen nad jedním souborem.** Plošné pravidlo nad `docs/` by hlásilo těch 31 legitimních kotev a vnucovalo pravopisnou konvenci autorům textů, které nevlastním. Kontrola postavená na „číslo se musí rovnat `scaffold/VERSION`" by měla obrácenou polaritu: byla by zelená přesně v okamžiku, kdy dokument lže starým číslem, a červená po každém vydání. Zbývá kontrola tvaru nad jedním dokumentem, jehož tématem jsou čísla, a ta má nulovou falešnou pozitivitu (měřeno nad výsledným textem).

**Vyzkoušené naostro, ne jen promyšlené.** Detekce běžela proti fixtuře s živým číslem, s adresou `127.0.0.1` a s historickým `v2.0.0`: nález právě jeden, ten správný. Falešný poplach na adrese portu se našel při tomhle běhu, ne v úvaze, a je to důvod, proč v kontrole je odstranění čtyřdílných adres.

**Verze 2.13.0 na 2.14.0 (MINOR), ne PATCH.** Přibyla kontrola, takže repo, které včera prošlo, dnes projít nemusí. Že jde věcně o dokumentaci, na tom nic nemění - číslo je signál o riziku pro toho, kdo bránu spouští.

**Co tenhle commit vědomě nedělá.** Nesahá na politiku verzování v repozitáři kokpitu, kde tabulka „Tři čísla verze, tři domovy" zůstává druhým domovem téhož faktu - cizí jednotka, patří to do její session. A do `docs/TECHNIKA.md` přidává jednu větu, ne přepis: výčet kontrol v sekci 4a končil u (14) a byl tím pádem už dřív druhý domov, který zaostává. Věta říká, že výčet je zkratka a kanonický seznam drží nápověda `--help`. Rozhodnutí, jestli ten výčet z manuálu úplně zmizí, patří Quentinovi METY, ne mně.
