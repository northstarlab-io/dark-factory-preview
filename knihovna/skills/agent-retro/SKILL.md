---
name: agent-retro
description: Per-agent retrospective ritual po deployment / netriviálním task closure. Součást self-learning smyčky (sonda A). Output v project team-outcomes/. Trigger manuálně po dokončení deliverable nebo po incidentu.
---

# Agent Retro - strukturovaná retrospective po deployment

## Kdy spustit

**Wave 0 (selektivně, NE po každém nasazení - review kapacita člověka je úzké hrdlo):**

- Netriviální deployment (multi-agent, customer-facing, novel pattern).
- Incident / failure (auto-trigger pro retro).
- Stanislavem flagged ("tohle stojí za retro").
- Self-judge agent: "tohle mělo non-trivial signal worth review".

**NE spouštět** na každý drobný task. Agresivní prefiltering - Quentin META filtruje, člověk review jen top 3-5 candidates.

## Template (5 otázek)

Output v `<project>/team-outcomes/retro-<agent>-<YYYY-MM-DD>.md`.

```markdown
# Retro: <agent> - <project / task name>

**Datum:** YYYY-MM-DD
**Agent:** <name>
**Trigger:** netriviální deployment / incident / Stanislav flag / self-judge
**Deployment context:** <1-2 věty kontextu>

## 1. Co fungovalo

(2-4 bullets, konkrétní)

## 2. Co nefungovalo

(2-4 bullets, konkrétní + impact)

## 3. Co bych udělal jinak

(1-3 alternativní přístupy, ne abstract - konkrétní changes)

## 4. Promotion candidate pro persona

**Co bych chtěl změnit v `~/.claude/agents/<name>.md`:**

- (volitelné, max 2 candidates)
- Per candidate: WWHTBT - co by muselo být pravda, aby fungovalo napříč deployments?

**Pokud žádný:** "-"

## 5. Promotion candidate pro methodology core

**Co bych chtěl přidat / refine v `~/.claude/foundation/<name>-patterns-core.md`:**

- (volitelné, max 2 candidates)
- Per candidate: NSL Foundation citation (per Q6 / WWHTBT gateway) - který Foundation princip / Pillar tento pattern serves?

**Pokud žádný:** "-"

## Quentin META review note

(Quentin META filterující promotion candidates - krátký note pre-Stanislavova review.)
```

## Workflow

1. **Agent** dokončí netriviální deployment.
2. Agent self-judge: "stojí to za retro?" Pokud yes → run `/agent-retro` skill.
3. Skill vytvoří `team-outcomes/retro-<agent>-<date>.md` per template.
4. Agent vyplní 5 sekcí (sebe-reflexe, 5-15 min agent time).
5. **Quentin META** v rámci weekly review batch-prefiltruje retros → top 3-5 promotion candidates pro Stanislava.
6. **Člověk** v krátkém pravidelném slotu rozhodne approve / reject / refine per candidate.
7. Approved → updated v persona / methodology core. Reject → log důvodu (feedback signal pro template kalibraci).

## Anti-pattern

- **Pseudo-positivity** - retro říká "all worked" bez honest co failed. Sherlock kontroluje quality, reject low-quality.
- **Tactical detaily místo non-trivial insights** - retro produkuje noise. Min threshold "tohle stojí za promotion" musí přežít.
- **Template fatigue** - agenti začnou retro automaticky, bez signálu. Sonda A test odhalí.

## Wave 0 success criteria

Per konsolidační výstup k self-learning smyčce (2026-05-07), Sonda A:
- 3 retra po nadcházejících nasazeních (oba orchestrátoři).
- Min 3 z 9 actionable insights = "tohle bych jinak neviděl" (Stanislavova judgment).
- Pod práh = ritual zatím nedává hodnotu, **kill / iterate** decision po 3 retrach.

## Reference

- Konsolidační výstup k self-learning smyčce (2026-05-07): scope sondy A.
- Konsolidační výstup k self-learning smyčce (2026-05-07), sekce 4.1 - hypotéza sondy a práh.
- `~/.claude/foundation/<agent>-patterns-core.md` - methodology core (target promotion).
- Per-agent persona file - second target promotion.
