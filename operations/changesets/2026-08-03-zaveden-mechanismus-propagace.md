# Platformní změny se propagují changesetem a jednotka o sobě eviduje baseline

**ID:** 2026-08-03-zaveden-mechanismus-propagace
**Osa:** A
**Vydáno:** 2026-08-03
**Autor:** Humble (mechanismus), Quentin META (oponentura a závazná rozhodnutí), Stanislav (schválení B-065)
**Závažnost:** běžná
**Zdroj:** META 9c2b511 | GLOBAL 6018074
**Platforma:** 2.0.0
**Týká se:** vse
**Dosah:** sablona, dokumentace
**Akce konzumenta:** založ ve své jednotce `operations/platform-baseline.md` podle šablony v `operations/changesets/README.md` (sekce Baseline jednotky) a zapiš do něj tenhle changeset jako převzatý

## Co se změnilo

V METĚ vznikl adresář `operations/changesets/` a s ním formát, kterým se od dneška deklaruje každá platformní změna s dosahem mimo METU. Changeset nese hlavičku ve stylu OR-03, jednu z pěti vrstev dosahu, akci konzumenta a blok `verify` s uzavřeným testovacím jazykem o třech výsledcích včetně `NEZJISTENO`.

Jednotka si nově eviduje **baseline** (`operations/platform-baseline.md`): které changesety převzala, na jaké verzi platformy stojí a kdy naposledy převzala. Z rozdílu mezi changesety v METĚ a baseline jednotky se počítá fronta ve čtyřech kategoriích (převzato, čeká, regrese, neaplikovatelné). Lag se měří v changesetech, ne v commitech.

Zavedení je **forward-only** s cutoffem META `9c2b511` / GLOBAL `6018074`. Změny platformy z 21. až 29. 7. se do fronty dostanou jen tehdy, když pro ně někdo changeset napíše; rozhodnutí o souhrnném changesetu za tu deltu patří Quentinovi META.

## Lidská věta

Od dneška se u každé změny platformy píše lístek s tím, koho se týká a co s tím má udělat, a každá jednotka si eviduje, které lístky už převzala. Odpověď na „na jaké verzi běžím a co mi uteklo" je nově jedno číslo, ne pátrání.

## Verifikace

```verify
sablona       file_exists   operations/platform-baseline.md
sablona       grep          operations/platform-baseline.md   ^\*\*Platforma:\*\*
dokumentace   no_test
```

Test je záměrně na existenci a tvar baseline, ne na obsah fronty: převzetí mechanismu znamená, že jednotka o sobě umí říct, kde stojí. Jednotka bez `operations/` (profil bez vrstvy `sablona`) se přeskočí jako `n/a`, nespadne.

## Poznámky

- **Verze platformy se dnes nebumpuje.** Návrh počítá se `scaffold/VERSION` 2.1.0 pro zavedení mechanismu, ale VERSION je jediný zdroj pravdy o čísle a bumpuje se v okamžiku, kdy se změní engine soubory a nástroje, ne dopředu. Do té doby by 2.1.0 v changesetu a 2.0.0 v souboru byly dvě verze na dvou místech. Bump patří ke kroku, který zapíše `scaffold/lib/changeset.sh`, režim `--baseline` a kontrolu brány.
- **Co dnes existuje a co ne.** Existuje formát (README) a dva seed changesety. Neexistuje parser, režim `validate.sh --baseline`, kontrola brány ve `validate-platform.sh` ani jediný baseline soubor. Do té doby se changesety čtou a baseline zakládá ručně; formát je stavěný na ruční provoz, takže nástroj se doplní bez změny formátu. Neověřeno průchodem: nic z mechanismu zatím neběželo.
- **Validátory jsou META nástroj, ne kopie v jednotce.** Proto changeset nese vrstvu `sablona` (jednotka zakládá vlastní soubor) a ne šestý token pro validátory. Nové kontroly poběží ze scaffoldu METY proti jednotce.
- **Závazná rozhodnutí oponentury Quentina META (3. 8. 2026),** která formát zavádí: baseline osy B se jmenuje `instance/cockpit-baseline.json`; model fronty je hybrid se čtyřmi kategoriemi včetně regrese; úniková cesta brány `Changeset: none (<důvod>)` je povolená a evidovaná; každá změna `~/.claude/agents/*.md` vyžaduje changeset; normy tenantního harnessu míří do `operations/00-normy.md`.
- **Kanonické texty AR-13 a OR-12 zapisuje Quentin META.** Tenhle changeset a README popisují mechanismus, ne normu. Bez always-loaded vrstvy (OR-12) se disciplína udrží řádově měsíc.
- Vazba: B-065, návrh `team-outcomes/024-f3-b065-changeset-baseline-navrh-2026-08-03.md`, koordinace s B-064 (pořadí: nejdřív engine lokace norem a kontrola parity, pak distilace META `CLAUDE.md`).
