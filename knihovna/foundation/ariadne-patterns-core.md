# Ariadne methodology core - decision rules + pattern library

> Methodology core pro Ariadne decision rules napříč deployments. **Disk = SoT** per AR-08 v2 (Typ 1 implementační content). Git verzováno.

**Vlastník:** Ariadne (sklízí lessons z deployments) + Stanislav (kurátor promotion).
**Vznik:** 2026-05-07 - seed při Ariadnině hire (krok 3 z 8-step Knowledge & Systems team hire batch).
**Promotion model:** Ariadne navrhuje promotion candidates z per-deployment lessons → Stanislav schvaluje → tato library updatuje. Curated, ne auto-commit.

## 1. Status

**Verze:** 0.1 (seed) - 5 baseline starter heuristik z systems integration / AI tooling / tech stack literatury jako startovní bod. Plný decision tree vzniká empiricky za běhu.

**Změny:** žádné dosud.

## 2. Baseline starter decision rules

### 2.1 AI client routing per audience

**Pravidlo:** Volba AI klienta per primary persona týmu klienta:

- **Sales / management / non-tech** → **Claude.ai (Cowork feature)** - drag-drop UI, low friction, žádný Markdown.
- **Tech / dev / power user** → **Claude Code (CLI)** - file system, Markdown, advanced features, skills + commands.
- **Hybrid tým (mix tech + non-tech)** → primarily Claude.ai s Claude Code option pro power users.
- **Cursor + file system** - pokud klient pracuje primarily v code editoru (rare pro SMB).
- **ChatGPT projects** - alternativa pro klienty s ChatGPT subscription a no Claude preference.

**Default counter:** Claude.ai Cowork pro většinu malých a středních firem. Claude Code pro Stanislava + tech-heavy klienty.

### 2.2 Workflow automation tool selection

**Pravidlo:** Volba per klient tech kapacita + flow complexity:

- **n8n** - self-hosted nebo cloud, visual + code flexibility. Pro klienty s mid-tech kapacita + custom needs.
- **Zapier** - managed, no-code, broad integrace. Pro non-tech klienty + standard workflows.
- **Make.com** - visual flow design, mid-cena, mid-complexity. Mezi Zapier (simple) a n8n (advanced).
- **Apify** - scraping + automation. Specifický use case (data ingestion z webu).
- **MCP bridges** - když klient používá Claude Code / Claude.ai, MCP je native. Žádný third-party tool potřeba pro AI ↔ system integration.

**Default counter:** Pro malé a střední firmy: Zapier baseline (low friction), Make.com pro mid-complexity, n8n když self-hosting + cost concerns + advanced custom logic.

### 2.3 Cloud storage routing

**Pravidlo:** Routing per klientův existing ekosystém (sunk cost respect, anti-migration default):

- **Microsoft stack klient** (Office 365, Outlook, Teams) → **OneDrive / SharePoint**.
- **Google Workspace klient** (Gmail, Calendar, Docs) → **Google Drive**.
- **Hybrid / žádný preferovaný** → **Notion + GDrive** (Notion KB primary, GDrive pro sdílené dokumenty s klienty).
- **Vendor-agnostic + privacy-first** → **lokální file system + sync přes iCloud / Dropbox / Sync.com**.

**Anti-pattern:** Nutit klienta migrovat z Microsoft na Google nebo opačně bez explicit důvodu. Vendor lock-in cost > integrace cost ve většině případů.

### 2.4 Database paradigm vendor selection (per doporučení role pro taxonomii a datové paradigma)

**Pravidlo:** role pro taxonomii a datové paradigma doporučí paradigm (relational / document / graph / vector / time-series / multi-model). Ariadne vybere konkrétního vendora per:

- **Relational** → **Postgres** (open-source, mature, hostable cloud + self-hosted). Default. **MySQL** pokud klient existing.
- **Document** → **MongoDB** v managed variantě u výrobce (dobré DX). Self-hosted **MongoDB** pokud privacy / cost.
- **Graph** → **Neo4j** (mature, Cypher query). **ArangoDB** pro multi-model needs.
- **Vector** → **pgvector** (Postgres extension) pro lightweight + simple. **Pinecone** pro managed multi-tenant. **Qdrant / Weaviate** pro self-hosted production.
- **Time-series** → **TimescaleDB** (Postgres extension). **InfluxDB** pro pure TS workloads.
- **Multi-model** → **ArangoDB** / **FaunaDB**. Rare pro NSL ICP.

**Default counter:** Postgres + extensions (pgvector, TimescaleDB) pokrývají 70 % use cases pro SMB klienty. Specialized vendors až když Postgres extension nestačí (multi-tenant vector, distributed graph, etc.).

### 2.5 Anti-overengineering threshold pro tech stack changes

**Pravidlo:** Před doporučením migrace / refactor / replace klientova existing toolu, projdi 4 otázky:

1. **Co konkrétně klientův current tool nedokáže?** (Specific gap, ne generic "modern tools jsou lepší".)
2. **Kolik práce je migrace?** (Effort estimation - hodiny / dny / týdny.)
3. **Kolik práce je learning + adoption nového toolu?** (Klient + jeho tým.)
4. **Co nevíme?** (Skryté závislosti, custom integrace, training history s old tool.)

Pokud nemáš jasné odpovědi na všechny 4 → **NEdoporučuj migraci**. Default = sunk cost respect, navázat AI / nové features na existing stack.

**Anti-pattern:** *"Migrace na X je modern best practice"* bez specific value pro tohoto konkrétního klienta = NSL anti-enterprise vibes. NSL není konzultant, který recommenduje migration kvůli own profit / vendor preference.

## 3. Promotion log

> Každá nová heuristika nebo refinement existující heuristiky promote z per-deployment lessons. Format: datum + zdroj + heuristika + Stanislav approval.

(zatím prázdné - seed verze)

## 4. Pattern library indexes (budoucí evoluce)

Po několika deployments se zde mohou objevit additional indexy:

- **Integration playbooks** napříč běžnými klientskými stacky (CRM plus cloudový disk plus mail, v různých kombinacích vendorů).
- **AI assistant patterns** - common use cases (cenové nabídky, lead gen, kvalifikace, souhrny podkladů) s implementation playbooks.
- **MCP setup recipes** - Notion, GitHub, Google Drive, Slack, případně další.
- **Auth flow templates** - OAuth 2.0 patterns per service, refresh strategies, scope minimization.
- **Security stack recipes** - per use case (single-user dev, team, multi-tenant production).
- **Cost optimization patterns** - kdy serverless vs. dedicated, kdy managed vs. self-hosted.
- **Anti-pattern catalog** - recurring chyby v tech stack + integrace + jak je řešit.

(zatím prázdné - vznikne empiricky)

## 5. References

- Kompetenční mapa k hire Ariadne, sekce 5 - origin baseline heuristik; sekce 2.11 - security expertise a AI security awareness (rozšíření 2026-05-07).
- Návrh rolí znalostního a systémového týmu (2026-05-06) - Ariadnin scope a hranice vůči sousedům.
- `docs/architektura-vrstev.md`, AR-08 v2 - lokační rozhodnutí.
- `knihovna/agents/ariadne.md` - definice role (vznikla paralelně 2026-05-07).
- Methodology core soubory dalších rolí - precedent struktury.
