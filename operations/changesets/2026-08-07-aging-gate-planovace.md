# Aging gate v plánovacích skillech: stáří jako brzda, ne akcelerátor

**ID:** 2026-08-07-aging-gate-planovace
**Osa:** A
**Vydáno:** 2026-08-07
**Autor:** Stanislav Skalický (autorská změna z dřívější session), Quentin META (evidence a commit)
**Závažnost:** běžná
**Zdroj:** META (tento commit) | GLOBAL 4bca1fc
**Platforma:** 2.7.0
**Týká se:** vše
**Dosah:** runtime-pull
**Akce konzumenta:** Žádná. Skilly jsou osobní vrstva Stanislava, jednotky je nekonzumují.

## Co se změnilo

`skills/pp-day/SKILL.md` (V0.12) a `skills/pp-week/SKILL.md` (V0.13) dostaly **aging gate**: položka starší šedesáti dní se v briefu neobjeví jako naléhavá, ale v sekci „Ještě platí?". Stáří tím přestává fungovat jako akcelerátor priority a stává se brzdou vyžadující potvrzení, že věc je pořád živá. Změna je párová, obě sekce šablony briefu jsou dorovnané a obě mají zápis ve version logu skillu.

Změna vznikla v dřívější session a **ležela v pracovním stromu knihovny nezacommitovaná**. Odhalil ji Humble 6. 8. při přípravě re-renderu k tenantovi: dokud jsou v knihovně rozpracované soubory, každý render nese `library_dirty: true`, tedy původ, který nejde zopakovat ze samotného commitu. Tenant by si takovou evidenci uložil do manifestu a nikdo by ji později nedokázal ověřit.

Vedle skillů ležel v témž stavu i `settings.json` se změnou modelu a effortu ze session. **Ten se nekomituje** - není to autorské rozhodnutí o výchozím tieru, je to stopa po jednorázovém přepnutí session, a vrátil se na `fable`/`xhigh` per rozhodnutí Stanislava ze 7. 8.

## Lidská věta

Denní i týdenní plánovač teď starou položku nepovažuje za urgentní jen proto, že je stará, a zeptá se, jestli ještě platí.

## Verifikační test

```verify
runtime-pull    lib_grep skills/pp-day/SKILL.md Ještě platí\?
runtime-pull    lib_grep skills/pp-week/SKILL.md Ještě platí\?
```
