# Operations - provozní vrstva STUDIO jednotky

> Provozní stav projektu (STUDIO jednotky): co se dělá, v jakém je to stavu, jaká padla rozhodnutí. Bez `operations/` je projekt jen sklad dokumentů. S ní je řiditelný.

**Vlastník:** Quentin per-projekt (orchestrátor). Zapisují i specialisté (výstupy, rozhodnutí, handoffy).

## Co kam patří

| Soubor / složka | Obsah |
|-----------------|-------|
| `status.md` | Živý stav projektu. Nahoře OR-03 header (strojově čitelný pro čtecí vrstvu portfolia), pod ním rolling log. Distilát vs. historie per OR-10. |
| `backlog.md` | Otevřené úkoly s ID `B-NNN` (trojmístné, forward-only). Top 3 aktivní se zrcadlí do OR-03 headeru. |
| `decisions/` | Provozní rozhodnutí (ADR / DR). Formát: Kontext - Rozhodnutí - Důsledky - Datum. |
| `handoffs/` | Session handoff snapshoty (skill `session-handoff`) pro kontinuitu přes `/clear`. |
| `runbooks/` | Opakovatelné operační postupy (např. `kb-staleness-sweep.md` per OR-10). |
| `retrospectives/` | Pravidelné retrospektivy projektu (`{YYYY-MM-DD}-retro.md` per AR-03). |

## Vztah k dalším vrstvám

`operations/` = co dnes dodáme (taktické). `team-outcomes/` = hotové výstupy (číslované `NNN-` per OR-06). `team-inbox/` = vstupy od zadavatele a tenantního orchestrátora. Released obsah migruje do Notion KB per AR-07.
