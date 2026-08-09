# Kontrola 12 umí read-purposes/v2: vzor účelu nese zástupný symbol

**ID:** 2026-08-08-kontrola-12-read-purposes-v2
**Osa:** A
**Vydáno:** 2026-08-08
**Autor:** Ariadne (nález a návrh v session kokpitu), Humble (implementace v METĚ)
**Závažnost:** běžná
**Zdroj:** META (tento commit) | GLOBAL 48f06eb
**Platforma:** 2.11.0
**Týká se:** vse
**Dosah:** dokumentace
**Akce konzumenta:** Žádná. Kontrola 12 běží jen v METĚ nad repozitářem kokpitu.

## Co se změnilo

Kokpit exportuje čtecí registr ve schématu **`read-purposes/v2`**. Proti v1 se změnilo jedno pole a jeho význam:

- **`cteni[].vzor` a `vypisy[].vzor` jsou kotvené na absolutní cestu** (začínají `^`) a místo domovské cesty nesou zástupný symbol `{KOKPIT}`, `{META}`, `{LIB}` nebo `{PROJEKTY}` - tutéž čtveřici, jakou už dnes používají klasifikační pravidla v `klasifikace.pravidla[].hodnota`.
- **Přibyl symbol `{KOKPIT}`** pro kořen běžící instance kokpitu. Pravidlo pro rozsah `vlastni` dřív neslo cestu k repozitáři kokpitu složenou ze symbolu kořene projektů; v klonu repa mimo ten kořen se z ní stala absolutní cesta klonu, export se rozešel s commitovaným souborem a server fail-closed nenastartoval (`DF_PURPOSE_EXPORT_STALE`). Se symbolem je export vlastnost kódu, ne stroje ani místa: v každém klonu vznikne bajt po bajtu stejný soubor.

Důvod je bezpečnostní, ne kosmetický: nekotvený vzor popisoval tvar cesty, ne její místo. Sonda s cestou, která tvar kořene projektů napodobovala uvnitř klientské jednotky, prošla účelem `unit-scan` s hloubkou `adresare`, přestože text výjimky u toho účelu tvrdil, že vzor nikdy nesahá dovnitř jednotky. Kotva to zavírá; do commitovaného popisu ale domovská cesta patřit nesmí (kontrakt C7), takže se nahrazuje symbolem.

**Kontrola 12 ve `validate-platform.sh` proti tomu dostala tři věci:**

1. Přijímá schéma `read-purposes/v2` vedle `read-purposes/v1`.
2. Rozvíjí zástupné symboly ve vzoru účelu i v hodnotě klasifikačního pravidla **předtím**, než vzor půjde do `grep -Eq`, toutéž náhradou, jaká ve skriptu byla u klasifikačních pravidel. Bez toho netrefí kotvený vzor nic a kontrola vypíše každý čitelný domov METY jako „bez účelu" - falešný poplach o dvaceti položkách.
3. Rozbaluje JSON escapy obecně (`\\` na jedno zpětné lomítko, teprve pak `\/` na lomítko), ne jen escapované lomítko. Dřívější jednoúčelová náhrada nechala ve vzoru `agent-stack\\.md` dvě zpětná lomítka, takže vzor hledal doslovné zpětné lomítko v cestě a účel `roster` netrefil nikdy nic. Naměřeno při implementaci: bez téhle opravy hlásila kontrola čtyři domovy bez účelu místo dvou.

**Symbol `{KOKPIT}` se nerozvíjí a nikdy nekončí jako nález.** Kořen instance kokpitu zná jen ta instance; META ho ze svého prostředí neodvodí a hádat ho podle jména adresáře by znamenalo vyrobit si druhý zdroj pravdy. Nahrazuje se cestou, která na disku nikdy neexistuje, takže větev vzoru se symbolem nikdy nic netrefí a nezapočítá se do parity. Prázdná náhrada je zakázaná: `s|{KOKPIT}||g` by z kotveného vzoru udělal vzor začínající `^/`, který trefí cesty od kořene disku.

**Zbylý neznámý symbol je `nezjištěno`, ne nález.** Když po rozvinutí zůstane ve vzoru nebo v hodnotě pravidla symbol, který META nezná, kontrola paritu vůbec neposoudí a ohlásí to jako nezjištěno se seznamem položek. Z toho, co neumím vyhodnotit, se nesmí stát tvrzení o cizím souboru - stejný fail-closed konec jako u neznámého schématu.

## Lidská věta

Kokpit si zpřísnil vzory, kterými pouští čtení souborů, a v exportu je píše se zástupným symbolem místo domovské cesty. Kontrola 12 v METĚ ten symbol nově rozvine, takže místo varování „umím jen v1" zase odpovídá na otázku, jestli má každý čtený domov platformy svůj účel.

## Verifikace

```verify
dokumentace   grep   scaffold/validate-platform.sh   read-purposes/v2
dokumentace   grep   scaffold/tests/fixtures/read-purposes-vzor-v2.json   \{KOKPIT\}
```

## Poznámky

- **Stav po zapnutí je dvě položky N1, a je to správný cílový stav, ne nedodělek.** `{LIB}/foundation/<slug>.md` a `{LIB}/foundation/<agent>-patterns-core.md` nemají v registru účel; čeká to na Stanislavovo rozhodnutí vedené v kokpitu jako B-02. Kontrola je poradní (vždy WARN), takže bránu neshazuje.
- **Návrh nesl PATCH, vydání je MINOR.** Změna sama je obsahová, ale jde ven v témž vydání platformy jako nová brána (17) a nová vyžadovaná cesta v tenant šabloně, tedy spolu se změnou kontraktu validátoru. Číslo platformy je jedno na commit; tvrdit PATCH by znamenalo tvrdit, že se kontrakt validátoru nezměnil.
- **Blok `verify` proti návrhu opraven.** Návrh z kokpitu měl řádek `sablona file_grep scaffold/validate-platform.sh ...` - sloveso `file_grep` jazyk nezná a vrstva `sablona` mířila na cestu, kterou má jen META (tatáž třída vady jako 7. a 8. 8.). Správný tvar je vrstva `dokumentace` se slovesem `grep`: vyhodnotí se v METĚ, ostatním jednotkám vyjde jako mimo profil. Návrh je návrh, ne vydaný changeset, takže se opravuje editací, ne dodatkem.
- Verdikt kontroly 12 zůstává poradní i po přijetí: shell vyhodnocuje textovou cestu bez `realpath`, kokpit klasifikuje až po rozbalení symlinku. Autorizuje vždycky allowlist v kódu.
- Podklad a plné odůvodnění leží ve výstupu session kokpitu z 8. 8. 2026 včetně návrhu tohohle changesetu.
