# Index platformy, automatické brány a vrstva dokumentace, která se poprvé vyhodnotí

**ID:** 2026-08-06-index-platformy-a-automaticke-brany
**Osa:** A
**Vydáno:** 2026-08-06
**Autor:** Humble
**Závažnost:** běžná
**Zdroj:** META (tento commit)
**Platforma:** 2.4.0
**Týká se:** vše
**Dosah:** dokumentace
**Akce konzumenta:** Žádná pro jednotky. V METĚ: kdo mění kanonický domov, regeneruje index v témž commitu (`bash scaffold/gen-platform-index.sh .`), a kdo chce bránu spouštět automaticky, zapne ji jednou příkazem `bash scaffold/install-hooks.sh --install`.

## Co se změnilo

**Index platformy.** Vznikl `scaffold/gen-platform-index.sh`, jediný zapisovatel dvou artefaktů: kanonického strojového `project-init/platform-index.json` (schéma `platform-index/v1`) a lidského rozcestníku `docs/index-platformy.md`, který je z něj odvozený. Vstupem je deklarace `scaffold/platform-index-config.json` - obsah mapy kanonických domovů drží role pro informační architekturu, tvar a kontrolu Humble. Index nese u domovů v METĚ otisk obsahu, takže změna dokumentace je nově měřitelná událost, i když k ní žádný changeset nevzniká. To je celý smysl: `docs/**` zůstává mimo hlídané cesty brány, protože šumící brána se vypne, ale zestárnutí čtené plochy přestává být neviditelné.

**Kontroly (11) a (12) ve `validate-platform.sh`.** (11) ověřuje shodu indexu s diskem; východisko je regenerace, ne výjimka. Váha se řídí polem `stav` v deklaraci - dokud není `platny`, je rozdíl WARN, protože závazně vynucovat text, který je pořád návrh, by znamenalo bránu nad cizím rozpracovaným rozhodnutím. (12) porovnává, co index tvrdí o čitelnosti domova, s tím, co o sobě exportuje čtecí vrstva kokpitu (`contracts/read-purposes.json`, schéma `read-purposes/v1` per `team-outcomes/041`). Je vždy WARN a nikdy nic nepovoluje: index vybírá, allowlist autorizuje.

**Vrstva `dokumentace` se poprvé vyhodnocuje.** `cs_unit_profile()` ji nedávala do profilu žádné jednotce, takže se každý dokumentační řádek vyhodnotil jako mimo profil - vrstvu neslo 9 z 19 changesetů a ani jeden její test se nikdy nespustil. Nově je v profilu jednotky, která má adresář `operations/changesets/`, tedy u výrobce. Fronty jednotek bez toho adresáře se nemění, ověřeno měřením před změnou i po ní.

**Automatické spouštění brány.** Dva verzované hooky ve `scaffold/hooks/`: `pre-commit` (spustí validátor, FAIL zastaví commit) a `commit-msg` (commit s dosahem mimo METU musí nést trailer). Aktivace je explicitní, jednorázová a per klon přes `scaffold/install-hooks.sh`; bez `--install` instalátor jen vypíše stav. Úniková cesta `--no-verify` zůstává a obejití chytne (8a) zpětně.

**Brána G3.** Validátor před každým sourcováním a spuštěním relativní cestou ověří `git ls-files --error-unmatch`. Bez toho by hook z konstrukce udělal vlastnost „umístit soubor do pracovního stromu způsobí spuštění shell kódu při příštím commitu" (nález Ariadne, `team-outcomes/041` sekce 5.1).

**Evidované výjimky brány.** Commit, který pokrytí nemá a mít ho už nemůže, se zapisuje jmenovitě do `operations/changesets/README.md` s odkazem na zpětnou formalizaci - místo druhého posunu kotvy, který by promíjel celý rozsah před sebou a nešel by spočítat.

## Lidská věta

Změna dokumentace platformy je nově měřitelná událost, takže se pozná, že podklad zestárl, a kontroly platformy se od teď spouští samy při commitu, ne až si na ně někdo vzpomene.

## Verifikace

```verify
dokumentace   file_exists   scaffold/gen-platform-index.sh
dokumentace   file_exists   scaffold/platform-index-config.json
dokumentace   file_exists   project-init/platform-index.json
dokumentace   file_exists   docs/index-platformy.md
dokumentace   file_exists   scaffold/hooks/pre-commit
dokumentace   file_exists   scaffold/hooks/commit-msg
dokumentace   file_exists   scaffold/install-hooks.sh
dokumentace   grep          scaffold/validate-platform.sh    tracked_in_git
dokumentace   grep          operations/changesets/README.md   Index platformy
```

## Poznámky

- Ověřeno průchodem, ne úvahou: dotek `docs/NAVOD.md` shodí `--check` na exit 1, návrat souboru ho vrátí na 0; dvojí běh generátoru za sebou dává bajtově shodný výsledek. Vlastní artefakty se proto neměří obsahem - první ostrý běh ukázal, že index měřil sám sebe a `--check` by se nikdy neshodl.
- Do indexu se nezapisuje poslední commit souboru. Hodnota se zjišťuje před commitem, takže by po commitu byla vždycky o krok pozadu - tatáž past jako u sebeměření.
- `team-inbox` generátor vynechá, i když ho deklarace zná: je to kanál obsahu cizího původu a index k němu nemá vodit pozornost session (posudek Ariadne 040, sekce 6.4). Vyloučení je hlasité a spočítané.
- První nález po zapnutí vrstvy `dokumentace`: changeset `2026-08-06-jednotka-je-claude-projekt-ne-agent` má řádek `grep … (w10) práva migrované jednotky`, kde nezaescapované závorky dělají z textu regulární výraz, který nemůže projít nikdy. Test je vadný, ne kód. Oprava patří autorovi changesetu, ne mně.
- Deklarace domovů má dnes `stav: navrh-obsahu`. Přepnutím na `platny` se (11) změní z WARN na FAIL; to je rozhodnutí vlastníka obsahu, ne mechaniky.
