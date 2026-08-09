# Index eviduje sekční profil renderu a náhrady za vypuštěné sekce

**ID:** 2026-08-07-index-render-profil-a-nahrady
**Osa:** A
**Vydáno:** 2026-08-07
**Autor:** Quentin META
**Závažnost:** běžná
**Zdroj:** META (tento commit)
**Platforma:** 2.9.0
**Týká se:** vše
**Dosah:** dokumentace
**Akce konzumenta:** Žádná.

## Co se změnilo

Dva soubory, které rozhodují o obsahu artefaktu doručeného tenantovi, dosud neměly v indexu platformy kanonický domov: `scaffold/render/section-profiles.json` (co z definice smí projít) a `scaffold/render/section-replacements.json` (co se za vypuštěnou sekci doplní a proč se u které nedoplní nic). Mezera je starší než dnešek, upozornil na ni Humble při zavedení náhrad.

Obě položky nesou různé vlastníky záměrně: profil je Humbleho mechanismus, náhrady jsou Panošovo posouzení schopnosti a jeho text. Oddělení souborů kopíruje hranici OR-09 a index ji teď eviduje, místo aby ji bylo nutné dovozovat.

Regenerace přitom vypsala dvě věci, které nechávám otevřené vědomě: `render-nahrady-vypustek` je ručně psaná odvozenina profilu (může tiše zestárnout, hlídá to kontrola (15) při commitu), a deklarace pořád nese pole `kontrakt` a `vnejsi_puvod`, která generátor nečte. Buď je začít číst, nebo je vyhodit; mrtvá deklarace tvrdí kontrolu, kterou nikdo nedělá.

## Lidská věta

Index teď ví i o dvou souborech, které rozhodují, co se z našich agentů dostane ke klientovi.

## Verifikační test

```verify
dokumentace     grep project-init/platform-index.json render-sekcni-profil
dokumentace     grep project-init/platform-index.json render-nahrady-vypustek
```
