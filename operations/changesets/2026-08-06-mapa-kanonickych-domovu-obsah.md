# Mapa kanonických domovů: obsahová část a srovnání evidence mechanismů

**ID:** 2026-08-06-mapa-kanonickych-domovu-obsah
**Osa:** A
**Vydáno:** 2026-08-06
**Autor:** role pro informační architekturu (obsah mapy a nálezy), zadal Quentin META per rozhodnutí Stanislava 6. 8.
**Závažnost:** běžná
**Zdroj:** META 90b36c6 | GLOBAL 6018074 (mapa se GLOBAL vrstvy nedotkla)
**Platforma:** 2.4.0
**Týká se:** vse
**Dosah:** dokumentace
**Akce konzumenta:** žádná; index je zatím položka výrobce se stavem `navrh-obsahu` a žádný nástroj z něj nečte.

## Co se změnilo

Deklarace kanonických domovů `scaffold/platform-index-config.json` naplněna obsahem: zhruba 60 tříd faktů se vzorem cesty, vlastníkem, polem `zapisuje` (`clovek` / `nastroj:X` / `agent:X`), povolenými kopiemi a konzumenty. Popisuje třídy, ne instance jednotek, takže při běžném scaffoldu nezestárne. Pole `rozsah_ocekavany` je kontrolní deklarace slučitelná s funkcí `scopeOf()` z bezpečnostního posudku, ne druhá klasifikace. Doplněny dvě položky, které v seznamu chyběly: deklarační soubor sám a generátor indexu. Generovaný výstup `project-init/platform-index.json` vyrábí `scaffold/gen-platform-index.sh` (mechanismus Humble) - ruční zásah do něj nepatří.

`automation/inventory.md` srovnán se skutečností: evidence skillů tvrdila zlomek toho, co je na disku. Doplněny chybějící položky včetně osobní vrstvy a sdílené knihovny, nález runtime logů uvnitř adresáře definic, a věcné vysvětlení, proč jsou tabulky hooks a commands prázdné (oba adresáře fyzicky neexistují).

## Lidská věta

Od teď je na jednom místě napsané, kde který fakt o platformě bydlí a kdo do něj smí sáhnout rukou - a evidence skillů poprvé za tři měsíce odpovídá tomu, co je na disku.

## Verifikace

```verify
dokumentace    file_exists   scaffold/platform-index-config.json
dokumentace    grep          scaffold/platform-index-config.json   index-platformy-deklarace
dokumentace    grep          automation/inventory.md   pp-retro
```

## Poznámky

- Plný soupis nálezů, návrhy znění pro manuály a normy a rozhodnutí pro Stanislava leží ve výstupu z 6. 8. 2026.
- Návrh mapy, ze kterého obsah vychází, i mechanismus a generátor leží ve výstupech z téhož dne.
- **Před commitem regenerovat index** (`scaffold/gen-platform-index.sh`) - deklarace se změnila, generovaný `project-init/platform-index.json` je proti ní pozadu o dvě položky.
- Dosah se změní na `runtime-pull` v okamžiku, kdy z indexu začne číst validátor nebo kokpit. Do té doby je to položka výrobce.
- Adresáře `~/.claude/commands/` a `~/.claude/hooks/` se vědomě nezakládají prázdné (rozhodnutí v 042 sekce B1). V hlídaných cestách brány zůstávají.
