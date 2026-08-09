# Dočasné omezení se zapisuje s datem, ne s podmínkou zániku

**ID:** 2026-08-08-docasna-omezeni-ttl-or10
**Osa:** A
**Vydáno:** 2026-08-08
**Autor:** Quentin META (znění normy), návrh mechanismu Karpathy, propis do definic Panoš
**Závažnost:** běžná
**Zdroj:** META (tento commit)
**Platforma:** 2.10.1
**Týká se:** vše
**Dosah:** runtime-pull
**Akce konzumenta:** Žádná při převzetí. Uplatní se, až bude v jednotce potřeba zavést dočasné omezení - pak platí nový kanál a formát položky.
**Dodatek:** 2026-08-08, Quentin META, blok `verify` používal sloveso `meta_grep`, které verifikační jazyk nezná - všechny čtyři řádky by skončily jako NEZJISTENO a changeset by nešel přijmout.

## Co se změnilo

OR-10 (Lifecycle obsahu) dostalo **čtvrtý mechanismus: Dočasná provozní omezení - TTL s datem, ne podmínka zániku**. Omezení s vlastní dobou trvání (vyčerpaný limit modelu, výpadek modelu či služby, embargo do data, klientské okno) nepatří do kanálů trvalých faktů, tedy do memory, norem, agent definic ani watch-items. Domov se řídí dosahem: jeden běh drží brief běhu, jedna jednotka sekci `## Dočasná provozní omezení (TTL)` ve svém `CLAUDE.md`, celý ekosystém tutéž sekci v `~/.claude/CLAUDE.md`. Sekce existuje jen neprázdná, každá položka nese kalendářní datum `Do YYYY-MM-DD` a po datu je neplatná z definice.

Doplněno Why s doložením incidentu, druhý Test („Kdyby tuhle položku už nikdy nikdo neuklidil, přestane sama působit?") a rozšířené Center of expertise. Heslo `TTL sekce (dočasná provozní omezení)` přibylo do `docs/SLOVNIK.md` a heslo OR-10 tam bylo opraveno ze tří mechanismů na čtyři.

Kanonický rozbor včetně zamítnutých variant a měření: `team-outcomes/058-docasna-omezeni-kanal-a-expirace-karpathy-2026-08-08.md`.

## Lidská věta

Když někdy něco dočasně omezíme, třeba když dojde týdenní limit modelu, tak se to nově zapíše s konkrétním datem na jedno místo podle toho, koho se to týká, a po tom datu to samo přestane platit. Do paměti agentů to nepatří, protože právě odtud se dvě taková omezení sedm týdnů nikdo neodstranil, přestože u nich stálo, kdy mají skončit.

## Verifikace

```verify
runtime-pull    lib_grep agents/quentin.md Dočasná provozní omezení - TTL, ne memory
runtime-pull    lib_grep agents/orchestrator-tenanta.md Dočasná provozní omezení - TTL, ne memory
runtime-pull    lib_grep agents/quentin.md OR-10, mechanismus 4
runtime-pull    lib_grep agents/orchestrator-tenanta.md OR-10, mechanismus 4
```

## Poznámky

**Bez bumpu verze platformy.** Mění se znění normy a slovník, ne tvar engine souborů ani kontrakt validátoru. `scaffold/VERSION` zůstává 2.10.1.

**Původ.** Stanislav 8. 8. 2026 zrušil omezení používání modelu Fable, které vzniklo kvůli vyčerpanému týdennímu limitu, a vyžádal si propis napříč projekty. Sweep našel dvě živá místa, obě v memory dvou různých jednotek, z 16. a 17. 6. Obojí smazáno včetně řádků v indexu memory. Obě položky nesly explicitně napsanou podmínku zániku a přesto přežily svou platnost o sedm týdnů; druhá mezitím zestárla i fakticky, protože stála na tvrzení o defaultním modelu jedné role, které od OR-07 v3 (28. 7.) neplatí. Stanislav si na základě toho vyžádal pravidlo.

**Nález, který rozšířil záběr pravidla nad původní zadání.** Karpathy ověřil proti dokumentaci, že auto memory hlavní session se do subagentů nedědí. Omezení modelu zapsané v memory tedy nikdy nevidí právě ty spawny, kterých se týká - kanál byl špatný na obou koncích, nejen v tom, že nezaniká. Proto pravidlo memory pro tuhle třídu zápisů zakazuje kategoricky, ne jen podmíněně.

**Do `~/.claude/CLAUDE.md` se tímto commitem nezapisuje nic.** TTL sekce v USER vrstvě vznikne až s prvním živým omezením, zapisuje ji Stanislav. Prázdný stav stojí nula tokenů, protože sekce v souboru prostě není.

**Propis do definic obou orchestrátorů jde souběžně přes Panoše**, protože memory zapisuje jen hlavní agent session. Plošný rollout do všech definic Karpathy zamítl - specialisté auto memory nezapisují, takže by šlo o nájem bez rizika, které by kryl. GLOBAL commit má vlastní trailer a proběhne odděleně od tohoto commitu v METĚ.

**Evidovaný revisit trigger.** Varianta s vyhrazeným souborem a SessionStart hookem má garantované doručení a skutečnou nulu v prázdném stavu, ale zavádí nový mechanismus do ekosystému, který dnes běží na nula hoocích tohoto typu. Až hook infrastruktura vznikne, TTL sekce se do ní přestěhuje beze změny formátu položky.

**Známá mez.** Vestavěné agenty Explore a Plan `CLAUDE.md` hierarchii záměrně nenačítají. Pro ně platí, co platilo vždy: omezení musí nést brief od orchestrátora.

## Dodatky

**2026-08-08, Quentin META - blok `verify`.** Původní znění bloku:

```
runtime-pull    meta_grep CLAUDE.md Pravidlo - čtyři mechanismy
runtime-pull    meta_grep CLAUDE.md Dočasná provozní omezení - TTL s datem, ne podmínka zániku
runtime-pull    meta_grep CLAUDE.md Test dočasného omezení
runtime-pull    meta_grep docs/SLOVNIK.md TTL sekce (dočasná provozní omezení)
```

Sloveso `meta_grep` neexistuje. Verifikační jazyk zná `grep` a `not_grep` (míří do jednotky konzumenta), `lib_grep` a `lib_file` (míří do platform library), dále `file_exists`, `no_file`, `no_test`, `manifest_ge`, `manifest_has_agent`, `platform_version`, `version_ge` a `date`. Neznámé sloveso vrací `NEZJISTENO`, takže nic tiše neprošlo jako PASS - ale changeset by nešel přijmout, protože přijetí vyžaduje PASS.

Nové znění ověřuje propis v platform library, kde je pro konzumenta skutečně pozorovatelný. Kanonický text normy v METĚ ověřit nelze; verifikační jazyk pro METU sloveso nemá, protože changeset je z konstrukce určený konzumentovi a ten METU nečte. Je to obecná mez mechanismu, ne vada tohoto changesetu - platí pro každou změnu normy, jejíž propis nekončí v knihovně ani v jednotce. Předáno Humblovi jako podnět, mechanismus vlastní on.

Precedent stejné vady: `2026-08-06-jednotka-je-claude-projekt-ne-agent`, dodatek ze 7. 8. (nesplnitelný regulární výraz z nezaescapovaných závorek). Dvě vady verifikačních bloků ve třech dnech ukazují, že blok `verify` se dnes píše bez zpětné vazby - autor nemá jak zjistit, že řádek nefunguje, dokud ho někdo nespustí proti reálné jednotce.
