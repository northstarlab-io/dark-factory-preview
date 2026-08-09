# Overlay agentů STUDIO jednotky (AR-12)

Kanonická definice každého agenta žije JEN v platform library `~/.claude/agents/<name>.md` (META governance, git verzovaná). Zde v STUDIO jednotce vzniká nanejvýš **overlay** - lokální specializace nad kanonickou vrstvou. Strop jsou dvě vrstvy: kanonická + max. jeden overlay, nikdy řetězený.

## Kdy overlay vzniká

Jen při **skutečně lokální dovednosti**, kterou kanonická definice nemá a mít nemá - project-local zdroj či MCP konektor, doména platná jen v této STUDIO jednotce, lokální pravidlo. Ne pro drobnou úpravu tónu a ne jako kopie kanonického agenta. Když overlay potřebuje víc než delta, je to signál špatné granularity - řeš v kanonické definici nebo hire nového agenta.

## Povinný tvar

- **Jméno se suffixem STUDIO jednotky:** `<name>-{{STUDIO}}.md` (kanonická AR-12 forma `<name>-<sufix>.md`; suffix = slug STUDIO jednotky zde, slug tenanta u tenant overlay). Overlay NIKDY nemá stejné jméno jako kanonický agent.
- **Pointer místo kopie:** tělo začíná instrukcí `Načti kanonickou definici ~/.claude/agents/<name>.md Read toolem, převezmi ji, aplikuj delta níže.` Overlay čte kanonickou definici při spawnu - upgrade se propíše okamžitě, žádný sync.
- **Jen delta, cíl ≤ 60 řádků.** Nikdy neopakuj personu, metodiku ani OR/AR normy z kanonické vrstvy.
- **Kompletní `tools` frontmatter** = kanonická sada + delta (frontmatter se nemerguje, je to jediná povolená duplikace; validátor scaffoldu hlídá soulad).
- **`model:` jen alias** (fable/opus/sonnet/haiku) a jen při odůvodněné odchylce od kanonického tieru; jinak se dědí kanonický.

## Zákazy

- **Same-name stínění** kanonického agenta (`<name>.md` zde) - zakázáno, validátor scaffoldu odmítne neprázdný průnik jmen s `~/.claude/agents/`.
- **Kopie kanonického obsahu** do overlaye - kopie je fork, fork je drift.

## Skeleton

```markdown
---
name: ariadne-{{STUDIO}}
description: Ariadne s lokální dovedností pro STUDIO jednotku {{STUDIO}} - <čím se liší>
tools: Read, Write, Edit, Grep, Glob, Bash, WebSearch, WebFetch   # kanonická sada + delta
# model: opus   # jen při odůvodněné odchylce od kanonického tieru
---

Načti kanonickou definici `~/.claude/agents/ariadne.md` Read toolem, převezmi ji, aplikuj delta níže.

## Delta pro STUDIO jednotku {{STUDIO}}
- <lokální dovednost: project-local zdroj / MCP konektor dostupný jen zde>
- <lokální pravidlo nebo doména platná jen v této STUDIO jednotce>
```
