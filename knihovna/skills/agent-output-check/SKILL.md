---
name: agent-output-check
description: Self-healing layer prototype pro agent outputs. 5 detection signals + 3 healing strategies + 4-tier routing (ACCEPT / HEALED_ACCEPT / FALLBACK / DISCARD). HEALED_ACCEPT log = primary feedback signal. Wave 0, sonda D, testbed na jedné pilotní roli.
---

# Agent Output Check - self-healing layer prototype

## Účel

Deterministický **integrity check + repair pipeline** mezi agent output a final delivery (Stanislavovi nebo klientovi). 

**Princip:** judgment compression (člověk reviewuje HEALED_ACCEPT patterns), NE substitution (žádný auto-apply persona/core change).

**Wave 0 testbed:** jedna pilotní role (nižší riziko, právě refaktorovaná).

**Inspirace:** *"RAG Hallucinates: I built a self-healing layer that fixes it in real-time"* (towardsdatascience.com, 2026-05-07).

## Kdy spustit

**Wave 0 (pilotní role):**
- Po výstupu pilotní role v nasazení (pre-delivery check).
- 2 týdny.
- Práh signál: HEALED_ACCEPT rate < 30% = healthy, > 50% = systematic problem.

**Wave 1+ (po validaci):** rozšířit na další agenty s per-agent threshold presets.

## Workflow (V0 minimal - 3 detection signals)

V0 NEimplementuje všech 5 signals z článku. Minimal subset pro Wave 0 sonda:

### Signal 1: Faithfulness vs. methodology core

Check claim alignment s `~/.claude/foundation/<agent>-patterns-core.md`.

**Heuristika:** Per non-trivial claim v output, search methodology core pro relevant decision rules. Pokud claim contradicts core rules → flag.

**Threshold:** ≥ 1 contradiction = flag.

### Signal 2: Contradiction vs. NSL Foundation

Check claim vs. NSL Foundation principles (per AR-08 v2; kanonický domov Foundation je mimo tenhle balíček).

**Heuristika:** Per major decision / recommendation, check zda neporušuje Foundation principles (anti-AI styl, anti-manipulace, hybrid real-world + tech, atd.).

**Threshold:** ≥ 1 violation = flag.

### Signal 3: Entity hallucination

Check zmiňované agenty / nástroje / MCP servery / klient názvy proti existující registry.

**Heuristika:**
- Agenty: jen `~/.claude/agents/*.md` plus per-projekt overlaye v jednotce.
- MCP servery: jen reálně nastavené v `~/.claude.json`.
- Klient názvy: per-projekt CLAUDE.md (recognized klienti).

**Threshold:** ≥ 1 nonexistent entity = flag.

## 3 healing strategies (priority order)

### Strategy A: Methodology core substitute

Pokud Signal 1 fail (contradiction vs. core):
1. Identify správnou heuristiku z methodology core.
2. Replace contradicted claim s core-aligned formulation.
3. Confidence recalibrate +0.10 (cap 0.80).

### Strategy B: Entity scrub

Pokud Signal 3 fail (entity hallucination):
1. Remove sentence containing nonexistent entity.
2. Append transparency note: "*[Reference na neidentifikovanou entitu byla odstraněna - Quentin META verifikace]*".
3. Confidence × 0.85.

### Strategy C: Foundation regenerate

Pokud Signal 2 fail (Foundation violation):
1. Flag + log violation type.
2. Regenerate dotčenou pasáž s explicit Foundation citation.
3. Confidence re-run signal check.

## 4-tier routing

| Tier | Trigger | Action |
|------|---------|--------|
| **ACCEPT** | All 3 signals pass | Pass output through unchanged |
| **HEALED_ACCEPT** | 1 signal failed + healing strategy applied successfully | Pass healed output. **Log to `~/.claude/foundation/<role>-healing-log.md`** |
| **FALLBACK** | 2+ signals failed nebo healing failed | Return safe message: "Vyžaduje Stanislavovo review - flagged signal: <type>" |
| **DISCARD** | Critical violation (e.g. fabricated entity in client-facing deliverable) | Hard stop, escalate Stanislavovi immediately |

## HEALED_ACCEPT log format

`~/.claude/foundation/<role>-healing-log.md`:

```markdown
## YYYY-MM-DD HH:MM [project]

**Signal failed:** Faithfulness vs. core / Contradiction vs. Foundation / Entity hallucination
**Healing strategy:** A / B / C
**Original claim:** <truncated, if not sensitive>
**Healed claim:** <truncated, if not sensitive>
**Confidence before:** 0.XX → after: 0.YY
**Notes:** (volitelné)

---
```

## Wave 0 success criteria

Per konsolidační výstup k self-learning smyčce (2026-05-07), Sonda D:

- 2 týdny na pilotní roli.
- HEALED_ACCEPT rate < 30% = healthy.
- > 50% = systematic problem signál → trigger redesign persony nebo methodology core té role.
- Min 3 actionable patterns z HEALED_ACCEPT log za 2 týdny (Stanislavova judgment).
- Exit po 2 týdnech: scale (rozšířit na orchestrátory) / iterate (refine detection logic) / kill (signál < hodnota).

## Anti-pattern

- **Auto-apply healed output bez log** - anti-pattern. HEALED_ACCEPT MUSÍ logovat (= primary feedback signal).
- **Confidence inflation** - strategy A says "+0.10 cap 0.80", strategy B "× 0.85". NIKDY recalibrate beyond these caps (per article reference).
- **LLM-judge based detection** - V0 NEpoužívá external LLM call pro judgment. Latency-first, deterministic checks only (sub-50ms target).
- **Healing as substitute pro retro** - Sonda D output je signál PRO retro / promotion (Sonda A + methodology-promote), NE replacement. Stanislav weekly review HEALED_ACCEPT patterns.

## V1 expansion (post-Wave 0 stabilization)

Per konsolidační výstup k self-learning smyčce (2026-05-07), Sonda D exit "scale":
- Add Signal 4: Drift detection vs. baseline persona behavior.
- Add Signal 5: Confidence calibration mismatch (overconfidence + low faithfulness).
- Per-agent threshold presets (výzkumná role strict, facilitační light, informační architektura strict u rozhodnutí o struktuře).
- Composable detection primitives.

## Reference

- Konsolidační výstup k self-learning smyčce (2026-05-07): sonda D a sekce 3.4.
- Article: *"RAG Hallucinates: I built a self-healing layer..."* (towardsdatascience.com).
- `~/.claude/foundation/<role>-patterns-core.md` - methodology core target pro Signal 1.
- `~/.claude/foundation/anti-patterns-catalog.md` - recurring failures source.
