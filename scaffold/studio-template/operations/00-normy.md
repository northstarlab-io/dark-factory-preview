# Provozní normy platformy - výtah pro STUDIO jednotku

**Zdroj:** META {{SHA}}, {{DATUM}}, platforma {{VERZE}}

> Razítko původu na řádku výše zapisuje kopírovací krok, ne ruka. Podle něj se pozná drift bez porovnávání celého textu.

## Co je tenhle soubor

Strojově uchopitelná lokace pro výtah platformních norem. Vznikla proto, že norma zapsaná uvnitř `CLAUDE.md` se do jednotky mechanicky dostat nemohla - `CLAUDE.md` je **state** a state se při upgradu z principu nepřepisuje. Tenhle soubor je **engine** (viz `scaffold/manifest.json`), takže ho upgrade platformy smí přepsat celý.

**Needituj ho lokálně.** Změna provedená tady se při dalším upgradu ztratí. Když ve výtahu najdeš chybu nebo díru, hlásíš ji do METY (Quentin META vlastní znění norem per OR-09 a hranici mezi normou a mechanismem) - neopravuješ ji na místě.

`CLAUDE.md` jednotky na tenhle soubor jen odkazuje jedním řádkem. Jeden fakt, jeden domov (OR-10) - norma nesmí mít dva domovy, jinak se za měsíc rozejdou.

## Odkud se plní

| Co | Kanonický zdroj |
|---|---|
| Operativní znění norem OR-01 až OR-NN | `docs/normy.md`, sekce „Provozní pravidla orchestrátorů (OR-XX)" |
| Architektonická rozhodnutí AR-01 až AR-NN | `docs/architektura-vrstev.md` |
| Reference traily a incident historie norem | `docs/normy.md`, sekce „Reference" u každé normy |

Výtah **píše a udržuje Quentin META**. Zde uvedená struktura je mechanismus (kam se to zapisuje a jak se to doručuje), ne obsah. Při jakékoli nejasnosti čti kanonický zdroj - výtah je orientační, ne náhrada.

## Výtah norem

Vyplní Quentin META. Jeden řádek na normu, thin forma plus pointer; pořadí podle čísla normy.

| Norma | Thin forma (jedna až dvě věty) | Kanonický text |
|---|---|---|
| {{OR-NN}} | {{krátké operativní znění}} | META `CLAUDE.md`, sekce {{OR-NN}} |

Výčet identifikátorů `OR-NN` v tomhle souboru musí odpovídat výčtu nadpisů `### OR-NN` v META `CLAUDE.md`. Paritu hlídá kontrola (9d) ve `validate-platform.sh` - porovnává se **výčet identifikátorů, ne znění**.

## Jak se sem změna dostane

Vrstvou dosahu `sablona` v changesetu. Postup je záměrně bez nového nástroje: changeset s dosahem `sablona` nese v poli „Akce konzumenta" konkrétní příkaz ke zkopírování tohoto souboru ze šablony v METĚ a blok `verify` s testem, který výsledek ověří. Po provedení akce se převzetí zapíše přes `validate.sh --baseline <jednotka> --accept <ID>`.

Spouštěč pro stavbu `upgrade-unit.sh` je pojmenovaný dopředu: až bude v jedné frontě víc než tři soubory k překopírování, nebo až se ruční kopie třikrát udělá špatně. Ne dřív - psát nástroj pro jedno `cp` je předimenzování.
