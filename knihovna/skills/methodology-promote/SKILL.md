---
name: methodology-promote
description: Promotion gateway pro candidates z per-deployment retros do agent persona / methodology core. Quentin META agresivně pre-filtruje pro krátké lidské review. Součást self-learning smyčky - judgment compression mechanism (kurátorem je člověk, NE auto-apply).
---

# Methodology Promote - promotion gateway pro Stanislavovo weekly review

## Účel

Quentin META **agresivně pre-filtruje** retro candidates z per-agent retros (výstup sondy A) → krátké lidské review dávky top 3-5 promotion candidates → approve / reject / refine → integrace do persona / methodology core.

**Princip:** judgment compression, NE substitution. Člověk zůstává primary decider, žádný auto-apply.

## Kdy spustit

**Cadence:** týdně, jeden krátký slot.

**Trigger:**
- Manuálně Quentin META při weekly batch.
- Output volně positionovaný v `<projekt platformy>/team-outcomes/_promotion-queue/<YYYY-WW>.md`.

## Workflow (Quentin META)

### 1. Sběr retro candidates (5 min)

Skenovat `<all-projects>/team-outcomes/retro-*.md` produkované za týden.

```bash
find "$KOREN_PROJEKTU" -path "*/team-outcomes/retro-*.md" -newer <last-week-marker> -type f
```

### 2. Aggressive pre-filtering (5 min)

Per candidate from each retro **sekce 4 (persona) + sekce 5 (methodology core)**, filtruj:

**KEEP** pokud:
- Multi-deployment relevance (ne tactical jednorázová detail).
- Foundation citation possible (per WWHTBT gateway - pokud Foundation < 80% articulated, flag pro Foundation audit).
- High-impact (changeover má real value, ne kosmetika).
- Cross-agent applicability (bonus signal).

**DROP** pokud:
- Tactical detail jen pro daný deployment.
- Foundation citation nelze sestavit (Foundation gap → flag, NEcommitnout).
- Kosmetika (formátování, drobné wording).
- Duplicate s existing pattern.
- Ambiguous value (drift to next week pro re-evaluation).

**Threshold:** top 3-5 candidates per týden. Víc znamená dávku, kterou už člověk v jednom krátkém slotu neprojde.

### 3. WWHTBT scoring per candidate (3 min)

Per kept candidate add:

```markdown
**WWHTBT (co by muselo být pravda, aby fungovalo napříč deployments):**

1. <hypothesis 1>
2. <hypothesis 2>
3. <hypothesis 3>

**Verifiability:** High / Medium / Low
**Risk:** High / Medium / Low
**Foundation citation:** "<konkrétní Foundation princip / Pillar>"
```

### 4. Bundling related candidates (2 min)

Pokud 2+ candidates dotýkají stejnou doménu (např. naming conventions across agenty), bundle do single decision package - efficient pro Stanislavova review.

### 5. Output do promotion queue

```markdown
# Promotion Queue: 2026-WW (week of <date>)

## Lidské review

Slot: Po ráno / Ne večer (per Stanislavova preference).

## Candidate 1: <stručný název>

**Source retro:** `<project>/team-outcomes/retro-<agent>-<date>.md`
**Target:** persona / methodology core (per `~/.claude/foundation/<agent>-patterns-core.md` nebo `~/.claude/agents/<agent>.md`)
**Type:** add / refine / remove

### Proposed change

(Konkrétní diff nebo nová sekce.)

### WWHTBT

(Hypotézy + risk + verifiability.)

### NSL Foundation citation

"<Foundation princip / Pillar>"

### Stanislav decision

[ ] APPROVE - integrate as proposed
[ ] APPROVE WITH REFINE - Stanislav přidá note
[ ] REJECT - log důvodu (template kalibrace signál)
[ ] DEFER - dat to next week

## Candidate 2: ...

(Stejný format.)

## Reject log (pokud REJECT v předchozím týdnu)

(Reasons → feedback signal pro retro template kalibraci.)
```

### 6. Krátký lidský slot

Stanislav otevře file, prochází 3-5 candidates, marks decision.

### 7. Quentin META post-decision (2-3 min)

- APPROVED → integrate (edit persona / methodology core file directly + git commit).
- APPROVE WITH REFINE → integrate per Stanislavova note.
- REJECT → log důvodu v promotion-queue archive.
- DEFER → next week's queue.

## Anti-pattern

- **Quentin META "yes-man" filtering** - propustí všechny candidates, batch over 5 = Stanislav neúnosně. **Aggressive filter musí survive.**
- **Foundation citation fabrication** - pokud nelze citovat, flagne (Foundation gap), NEnafabricuje pretext.
- **Auto-apply candidate** bez Stanislavova review - anti-pattern per Decision 1 (judgment substitution). NIKDY.
- **Bundling unrelated candidates** - bundle jen pokud doménově související. Force-bundling pro batch size = noise.

## Wave 0 success criteria

Per konsolidační výstup k self-learning smyčce (2026-05-07), Sonda A:
- Min 3 actionable insights z prvních 9 retros = "Stanislavova judgment 'tohle bych jinak neviděl'".
- Pod práh = ritual zatím nehodnotný, kill / iterate decision po 3 týdnech.

## Reference

- Konsolidační výstup k self-learning smyčce (2026-05-07): rozhodnutí 1 a 3, sonda A.
- Skill `agent-retro` - upstream source candidates.
- Per-agent methodology core (`~/.claude/foundation/<agent>-patterns-core.md`) - promotion target.
- Per-agent persona (`~/.claude/agents/<agent>.md`) - alternative promotion target.
