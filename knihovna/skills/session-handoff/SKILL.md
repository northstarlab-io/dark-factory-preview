---
description: Persist + resume session context napříč /clear cycles. Save mode (default) = session-end snapshot do <project>/operations/handoffs/ před /clear, target velikost < 3 KB. Load mode má 3 tiers (status / default / full) s smart fallback - umí rekonstruovat i bez prior save z OR-03 status.md + recent file activity. Per-projekt scope. Komplementární s OR-03 status.md (perma) a memory (trvalá fakta).
---

# Session Handoff

Persistence vrstva pro plynulé pokračování práce napříč `/clear` cykly. Stanislav používá pravidelně - před vyklírováním sessionu invokne save, v nové session invokne load a navazuje plynule.

## Kdy spustit

**Save mode** (default, `/session-handoff` bez args):
- Před plánovaným `/clear` v aktuální session.
- Před `exit` / restart Claude Code, pokud chceš seamless resume.
- Při natural pauze v práci (např. konec dne), abys měl artefakt pro budoucí já / agenta.

**Load mode** (`/session-handoff load`):
- V nové (vyklírované) session na začátku, pro rychlé navázání.
- Když potřebuješ recap toho, co bylo rozpracované před /clear.

**Nepoužívat pro:**
- Trvalá fakta o user / projektu → memory (`~/.claude/projects/<hash>/memory/`).
- Live perma stav projektu → `operations/status.md` OR-03 header (event-driven update, ne ephemeral).
- Cross-projektová reflexe na úrovni tenanta → deník orchestrátora tenanta (close-chat pattern).

## Komplementarita s ostatními persistence kanály

| Kanál | Co drží | Cadence | Scope |
|-------|---------|---------|-------|
| **`operations/status.md`** OR-03 header | Live perma stav (Last update / Klasifikace / Fáze / Health / Top 3 / Blokátory / Next milestone) | Event-driven update při state change | Per-projekt |
| **Memory** (`~/.claude/projects/<hash>/memory/`) | Trvalá fakta o user, projektu, feedback, references | Při learning event (novém faktu) | Per-projekt |
| **`operations/handoffs/`** (tato skill) | **Session-ephemeral snapshot** pro plynulý restart | Per /clear cycle nebo session end | Per-projekt |
| **Deník orchestrátora tenanta** (close-chat pattern) | End-of-session reflexe a meta | Na konci session orchestrátora tenanta | Scope tenanta |

Handoff je **most-recency-priority** kanál: poslední handoff přečte další session jako wake-up dokument. Nepřeklesá memory ani status.md - **pointuje** na ně + přidává session-specific delta.

## Save mode workflow

### Size discipline (hard rule)

**Target velikost handoff: < 3 KB (~500 slov).** Důvod: load mode čte handoff do context window, větší handoff = vyšší baseline v nové session = zaplevelení po /clear.

**Discipline pravidla:**
- **Pointery, ne embedded content.** Místo "do souboru X jsem zapsal: <celý snippet kódu>" → "do souboru `X` zapsán <stručný popis změny>". Detail je v souboru, nepiš ho dvakrát.
- **3-5 bullet pointů per sekce maximum.** Pokud se ti rozbíhá víc, je to znak pro detail patřící do status.md (perma) nebo memory (trvalá fakta), ne handoff.
- **TL;DR sekce = MAX 5 vět.** Tohle je hlavní orientation point, držet hodně lean.
- **Notes sekci používat sparingly** - jen pro nuance, které opravdu nejdou nikam jinam.
- **Pokud handoff > 5 KB** → flag Stanislavovi "handoff je velký (`<size>` KB), zvažni split nebo přesun detail do trvalých kanálů (status.md / memory)".

### Postup

1. **Detect aktuální projekt** z cwd (`pwd`) nebo z lokace `CLAUDE.md` (parent directory).
2. **Read baseline** z `<project>/operations/status.md` OR-03 header (Last update / Klasifikace / Fáze / Health / Top 3 / Blokátory / Next milestone). Tohle je perma stav, který handoff **doplňuje**, ne nahrazuje.
3. **Recap session** - na základě konverzačního kontextu identifikuj:
   - Co se v této session reálně událo (key events, rozhodnutí, milestones).
   - Které soubory byly editovány / vytvořeny (in-flight work).
   - Klíčová rozhodnutí, která musí přežít /clear.
   - Otevřené otázky / pending decisions.
   - Memory updates, které proběhly (které memory soubory byly napsané/změněné).
4. **Compose handoff dokument** ve struktuře níže (viz Output šablona). **Aplikuj size discipline** (< 3 KB target, pointery místo embedded content).
5. **Ensure `<project>/operations/handoffs/` exists** (create pokud chybí).
6. **Write** do `<project>/operations/handoffs/YYYY-MM-DD-HHMM-<short-slug>.md`. Slug = krátký topic identifier (max 50 znaků, kebab-case, např. `ar05-v4-paradigm-revize`, `b047-week2-build-prep`, `foundation-audit-trigger`).
7. **Check velikost** přes `wc -c <file>`. Pokud > 5 KB → flag Stanislavovi warning + návrh kondenzace.
8. **Update OR-03 status.md** pokud nastala state change v této session (per OR-03 event-driven rule). NE mechanicky - jen pokud reálná změna v Last update / Fáze / Health / Top 3 / Blokátory / Next milestone.
9. **Confirm Stanislavovi:**
   - Lokace handoff souboru + velikost (KB).
   - Slovní souhrn (3-5 vět) co byl persisted.
   - Doporučení: "Bezpečné spustit `/clear`. V nové session zavolej `/session-handoff load` (smart default) nebo `load status` (jen perma orientation, žádný handoff)."

### Output šablona

```markdown
# Session Handoff - YYYY-MM-DD HH:MM

**Project:** <project-name>
**Klasifikace:** META | Internal | Client | Personal (z OR-03 status.md headeru)
**Trigger:** pre-clear | pre-exit | natural-pause
**Persisted by:** Claude Code session (hlavní agent = <orchestrátor jednotky | orchestrátor tenanta | jiný>)

## TL;DR pro novou session (3-5 vět)

<Kde jsme, co se právě dořešilo, co dělat hned po /clear. Žádný recap, jen orientace + first action.>

## Co se v této session reálně událo

- <key event 1 + outcome>
- <key event 2 + outcome>
- <key event 3 + outcome>
- ...

## Klíčová rozhodnutí (musí přežít /clear)

- **Decision:** <co + rationale>. Reference: <kde to žije - status.md / memory / decisions log / docs>.
- ...

## In-flight work (rozpracované)

| Co | Soubor | Stav |
|----|--------|------|
| <work item> | `<file path>` | rozpracované / čeká na review / blocked na X |

## Open threads / pending decisions

- <thread 1>: <co čeká na rozhodnutí + kdo / kdy>
- <thread 2>: ...

## Next actions (konkrétní first-steps po /clear)

1. <action 1 + lokace / příkaz>
2. <action 2>
3. ...

## Reference na perma kanály (NE recap, jen pointer)

- **OR-03 status.md:** `<project>/operations/status.md` - autoritativní live stav (Last update / Klasifikace / Fáze / Health / Top 3 / Blokátory / Next milestone).
- **Memory updates v této session:** <list memory souborů, které byly napsané/změněné> nebo "žádné".
- **Klíčové artefakty z této session:** <list 3-5 nejdůležitějších souborů>.

## Notes / context, co se nikam nepropíše

<Volný prostor pro session-specific kontext, nuance, "in my head" detaily, které by mohly být cenné pro pokračování ale nepatří do perma persistence.>
```

## Load mode workflow (3-tier + smart fallback)

Stanislav má 3 explicit tiers, default = smart pick podle dostupnosti handoff. Skill NIKDY není závislý na handoff existenci - vždy dá _něco_ rekonstrukčně použitelného z perma kanálů.

### Watch items check (povinný krok, všechny tiers)

Před složením briefu zkontroluj `<project>/operations/watch-items.md`:

- **Soubor neexistuje** → přeskoč, nehlas nic. Většina projektů ho mít nebude.
- **Soubor existuje** → přečti pole `**Nejbližší revize:**`. Je-li datum dnes nebo v minulosti, doplň do briefu krátkou sekci „Watch items k revizi" s počtem odložených položek, datem revize a nabídkou projít je. Je-li datum v budoucnu, **nehlas nic** - „revize za 12 dní" je šum, ne informace.

**Watch items nikdy nepovyšuj na next action sám od sebe.** Jsou to vědomě odložené věci s vlastní spouštěcí podmínkou; jediná legitimní akce je nabídnout jejich revizi, až termín nastane. Totéž platí pro thready označené v handoffu jako odložené nebo blokované.

### Tier 1: `/session-handoff load status` (minimal, ~2 KB)

**Co dělá:** JEN perma rekonstrukce, ŽÁDNÝ handoff read. Funguje i bez prior save / na fresh projektu.

**Postup:**
1. Detect aktuální projekt z cwd / CLAUDE.md location.
2. Read `<project>/operations/status.md` první ~30 řádků (OR-03 header).
3. Glob last 5 modified files v `<project>/operations/` + `<project>/team-outcomes/` (`ls -t | head -5`) - signál nedávné aktivity.
4. Brief Stanislavovi 3-5 vět:
   - Aktuální fáze + klasifikace + health.
   - Top 3 úkoly + blokátory + next milestone (z OR-03 header).
   - Recent activity pointer ("posledně se hýbaly tyto soubory: `<list>`").
5. Nabídka: "Pokračuji s `<next milestone z status.md>`, nebo chceš jiný směr?"

**Use case:** Rychlá orientace, nepotřebuješ session-specific kontext. Funguje vždy.

### Tier 2: `/session-handoff load` (default, smart, ~3-5 KB)

**Co dělá:** Smart auto-pick podle dostupnosti recent handoff.

**Postup:**
1. Detect projekt.
2. Glob `<project>/operations/handoffs/*.md`, sort by filename desc.
3. **Decision tree:**
   - **Latest handoff exists AND < 30 dní old** → "session resume" mode:
     - Selective read JEN sekcí "TL;DR pro novou session" + "Next actions" z handoff (přes sed nebo grep mezi heading markers).
     - Plus OR-03 status.md header brief.
     - Brief 3-5 vět + pointer na full handoff `<path>` pro deep detail.
   - **Žádný handoff exists OR latest > 30 dní old** → automatic fallback na Tier 1 (status mode):
     - Flag Stanislavovi "no recent handoff, reconstructing from perma".
     - Postup per Tier 1.

**Use case:** Denní default. Pokud máš čerstvý handoff, dostaneš orientation + session delta. Pokud ne, automatický fallback na perma rekonstrukci.

### Tier 3: `/session-handoff load full` (deep, ~5-10 KB)

**Co dělá:** Full read handoff + status.md + memory index.

**Postup:**
1. Detect projekt.
2. Read full latest handoff (cca celý soubor).
3. Read OR-03 status.md header (~30 lines).
4. Read `~/.claude/projects/<hash>/memory/MEMORY.md` index (auto-loaded sowieso, ale explicit acknowledge).
5. Brief Stanislavovi strukturovaně:
   - Last handoff datetime + slug + full content rekapitulace.
   - In-flight work tabulka.
   - Open threads / pending decisions.
   - Next actions s lokacemi.
   - Pointer na klíčové artefakty.
   - Notes / nuance z handoff "Notes" sekce.
6. Nabídka: "Načteno full kontext. Pokračuji s `<next action>`, nebo chceš jiný směr?"

**Use case:** Vracíš se k projektu po týdnu / delším odstupu, potřebuješ rekapitulovat všechen session-specific kontext + nuance.

### Edge cases (všechny tiers)

- **`operations/handoffs/` neexistuje** → Tier 1 + Tier 2 (smart fallback) fungují. Tier 3 flag "no handoff available, fallback to Tier 1".
- **Latest handoff > 30 dní starý** → Tier 2 flag "⚠️ stale handoff, fallback to status mode". Tier 3 flag stale ale read full pokud explicit chce.
- **Multiple handoffs ve stejnou minutu** (edge race) → vezme alphabetically last by slug.
- **status.md neexistuje** (legacy projekt bez OR-03) → Tier 1 + 2 flag "no OR-03 baseline", brief jen z recent file activity. Tier 3 brief jen handoff content.

## Implementace

Žádné helper skripty - markdown skill workflow přes Bash (cwd, mkdir, date) + Read + Write + Glob.

**Time stamp generation:**
```bash
date +"%Y-%m-%d-%H%M"  # např. 2026-05-12-2245
```

**Project detection:**
```bash
pwd  # nebo find . -name CLAUDE.md -maxdepth 3 | head -1 | xargs dirname
```

**Save mode high-level steps:**
1. `project=$(pwd)` (assume cwd is project root) nebo derive z CLAUDE.md.
2. `timestamp=$(date +"%Y-%m-%d-%H%M")`
3. Read `$project/operations/status.md` (first 30 lines = header).
4. Compose handoff content (LLM work z konverzačního kontextu).
5. `mkdir -p $project/operations/handoffs`
6. `slug=<kebab-case-topic>` (Stanislav může explicit override přes args, default LLM-generated z dominant topic session).
7. Write `$project/operations/handoffs/$timestamp-$slug.md`.
8. Update status.md per OR-03 (jen pokud state change).
9. Confirm message.

**Load mode high-level steps:**
1. `project=$(pwd)`
2. `latest=$(ls -1 $project/operations/handoffs/*.md 2>/dev/null | sort -r | head -1)`
3. Read `$latest`.
4. Read `$project/operations/status.md` header.
5. Compose brief in chat.

## Args (overview všech invocations)

| Args | Mode | Tier | Footprint |
|------|------|------|-----------|
| `(no args)` | save | - | písemný handoff ~3 KB target |
| `save` | save explicit | - | písemný handoff ~3 KB target |
| `save <slug>` | save s explicit slug | - | písemný handoff ~3 KB target |
| `load status` | load | Tier 1 - perma only | čtený ~2 KB |
| `load` | load default (smart) | Tier 2 - handoff + perma, fallback Tier 1 | čtený ~3-5 KB |
| `load full` | load deep | Tier 3 - full handoff + status + memory | čtený ~5-10 KB |

## Retention policy

**V0 (now):** Keep všechno. Handoff files jsou malé (~3-10 KB per file), grow rate ~1-3 per den per active projekt = < 1 MB / měsíc / projekt. Bez problémů.

**V1+ trigger pro cleanup:** Když per-projekt handoffs folder přesáhne 100 souborů, případně kvartální retention review v rámci lintingu znalostní báze. Default retention = posledních 30 dní live + starší archive do `<project>/operations/handoffs/archive/YYYY-MM/`.

## Vztah k operations/wake-up-YYYY-MM-DD.md

`wake-up-*.md` byl ad-hoc precedent v `operations/` projektu platformy z 2026-05-11 (pre-clear persistence ručně). **Session-handoff skill = formalizace tohoto patternu** s strukturou + dedicated folder.

**Pravidlo:** nové handoff jdou do `operations/handoffs/`. Staré `wake-up-*.md` v root `operations/` zůstávají jako historie, není potřeba je migrovat.

## Když NEpoužívat

- Pro update OR-03 status.md (to dělej přímo, event-driven).
- Pro perma memory update (přímo do `~/.claude/projects/<hash>/memory/`).
- Pro end-of-session deník orchestrátora tenanta (má vlastní close-chat workflow).
- Pro per-deployment agent retro (skill `agent-retro` má dedicated lokaci v `team-outcomes/`).

## Reference

- OR-03 kontrakt: `docs/normy.md`, sekce „Provozní pravidla orchestrátorů".
- Wake-up precedent: `operations/wake-up-2026-05-11.md` v projektu platformy.
- Close-chat deníky orchestrátora tenanta v jeho harnessu.
- Memory pattern: `~/.claude/projects/<hash>/memory/MEMORY.md`.
