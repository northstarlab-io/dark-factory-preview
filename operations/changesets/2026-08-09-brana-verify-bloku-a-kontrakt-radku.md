# Vadný verify blok neprojde commitem, strojový řádek je deklarovaný kontrakt

**ID:** 2026-08-09-brana-verify-bloku-a-kontrakt-radku
**Osa:** A
**Vydáno:** 2026-08-09
**Autor:** Humble (mechanismus), nálezy Quentin META a session kokpitu
**Závažnost:** běžná
**Zdroj:** META (tento commit) | GLOBAL 48f06eb
**Platforma:** 2.11.0
**Týká se:** vse
**Dosah:** dokumentace
**Akce konzumenta:** Žádná. Brána běží v METĚ při commitu, do fronty jednotek nic nevstupuje.

## Co se změnilo

Třikrát ve třech dnech vznikl changeset s verifikačním blokem, který nemohl projít nikdy a nikomu: 7. 8. nezaescapované závorky ve vzoru, 8. 8. sloveso `meta_grep`, které jazyk nezná, 9. 8. `lib_grep` hledající formulaci, kterou pozdější změna přejmenovala. Uzavřený jazyk je fail-closed a vrátil pokaždé `NEZJISTENO`, takže nic tiše neprošlo - ale changeset se nedal přijmout a nikdo se to nedozvěděl, dokud ho někdo nepustil proti reálné jednotce. Ve třetím případě to dvě jednotky držely ve stavu `regrese`, přestože knihovna byla věcně v pořádku. Oprava pak stojí dodatek k vydanému changesetu, tedy nejdražší možnou cestu.

**Nová kontrola (17) ve `validate-platform.sh`** to posouvá do okamžiku commitu:

- **(17a) tvar** - každý řádek `verify` musí být vyhodnotitelný: známá vrstva, známé sloveso, cesta relativní ke kořeni jednotky a bez `..`, vzor přeložitelný jako `grep -E`, `no_test` jen na vrstvě `dokumentace`, `manifest_ge` jen s klíčem `platform_version` nebo `date`. Fail-closed nad celým adresářem changesetů, v hooku měřeno proti ploše commitu.
- **(17b) splnitelnost knihovních testů** - `lib_grep` a `lib_file` se vyhodnotí proti platform library. FAIL u changesetů, které měřená plocha zakládá nebo mění (autor je u toho, oprava stojí minutu), WARN u vydaných (opravuje se dodatkem, ne úpravou knihovny). Chybějící knihovna na stroji je nezjištěno, ne v pořádku.

**Jazyk dostal deklarovaný výčet.** `CS_VRSTVY` a `CS_SLOVESA` v `scaffold/lib/changeset.sh` jsou jediný domov výčtu; `cs_eval_row` podle nich rozhoduje dřív než `case` větve a nová funkce `cs_row_problem` z nich odvozuje posouzení tvaru řádku. Brána tak nemá vlastní opsaný seznam, který by se rozešel s implementací (OR-10). Že se nerozešel ani ten deklarovaný, hlídá test.

**Strojový řádek `validate.sh --baseline` je nově deklarovaný kontrakt**, ne vlastnost implementace: první řádek výstupu na každé cestě kódu včetně chybových, pole podle klíče a ne podle pozice, diagnostika na stderr, s `--line` jediný výstup, definované návratové kódy. Stojí na něm čtecí vrstva portfolia i startup check orchestrátorů - dosud stačil jeden `printf` navíc před ten řádek a čtečky by tiše přestaly číst fronty.

**Testy:** `scaffold/tests/strojovy-radek.sh` (nový, kontrakt řádku), `scaffold/tests/verify-slovesa.sh` (tvar řádku a parita deklarace s implementací i s tabulkou v README), `scaffold/tests/index-a-brany.sh` (brána (17) průchodem nad kopií METY, obě váhy).

## Lidská věta

Changeset, jehož ověřovací test nejde spustit, se nově nedostane přes commit - dřív se na to přišlo až za pár dní u jednotky, které kvůli tomu svítila falešná regrese.

## Verifikace

```verify
dokumentace   grep   scaffold/lib/changeset.sh   ^CS_SLOVESA=
dokumentace   grep   scaffold/lib/changeset.sh   ^cs_row_problem\(\)
dokumentace   grep   scaffold/validate-platform.sh   \(17a\) tvar verify bloků
dokumentace   file_exists   scaffold/tests/strojovy-radek.sh
dokumentace   grep   scaffold/validate.sh   KONTRAKT STROJOVÉHO ŘÁDKU
dokumentace   grep   operations/changesets/README.md   Strojový řádek je kontrakt
```

## Poznámky

- **Co brána z principu nechytne:** `grep` a `not_grep` proti jednotce. Tam je FAIL legitimní stav („konzument ještě nepřevzal"), takže z něj nejde udělat nález u autora. Chytá se jen tvar řádku a knihovní testy, kde je knihovna jedna a je to táž strana, kde změna vznikla.
- **Mezera, kterou brána nezavírá a vědomě ji nezavírám novým slovesem:** ověření změny, která zůstává v METĚ. Sloveso pro to nechybí - vrstva `dokumentace` se vyhodnocuje proti kořeni jednotky, kterou je v tomhle případě META, a ostatním jednotkám vyjde jako mimo profil. Zapsáno do `operations/changesets/README.md`, sekce „Změna, která zůstává v METĚ", aby to příště nikdo nemusel hádat a nesáhl po vymyšleném slovesu.
- **Běh brány se prodloužil** o jeden průchod adresářem changesetů (dnes 60 souborů, 242 řádků) a v hooku o jednu materializaci plochy commitu. Naměřeno pod dvě vteřiny z necelých dvaceti; brána, kterou se vyplatí obejít kvůli délce, je horší než žádná, takže se to bude sledovat.
