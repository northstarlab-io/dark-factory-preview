# {{PROJEKT}} - STUDIO jednotka

> {{OBLAST_NEBO_PROBLEM}} - jednovětá definice oblasti nebo problému, který tahle STUDIO jednotka řeší (např. "Provoz interní znalostní báze" nebo "Příprava podkladů pro cenové nabídky").

## Zařazení

- **Tenant:** {{TENANT}} (NSL / klient / venture firma - vlastník harnesse a portfolia STUDIO jednotek, do kterého tenhle projekt patří).
- **Klasifikace:** {{KLASIFIKACE}} (META | Internal | Client | Personal). Autoritativní zdroj typu projektu - řídí management style (compliance, NDA, cadence, secrets discipline, komunikační tón). Lokace na disku je organizační konvence, ne klasifikace.
- **Typ:** {{Průvodce | Asistent | Projekt | Mini-produkt | Automat}} (per OR-03 v6). Jaký tvar práce STUDIO jednotka má - vícekrokový workflow / doménový společník s human-in-the-loop / ohraničený projekt s plánem a koncem / featura-nástroj-artefakt / autonomní běh bez člověka po ruce. Čistý label, NEřídí chování (validátor je type-blind); klasifikaci nezaměňovat s typem.
- **Vrstva:** STUDIO (per AR-05 v6, čtyřvrstvý model USER / META / TENANT / STUDIO). STUDIO jednotka = jedna oblast nebo jeden problém s vlastním `CLAUDE.md`, `operations/`, `team-inbox/`, `team-outcomes/`. Kanonické texty vrstev: `docs/architektura-vrstev.md`.

## Discovery brief

{{DISCOVERY_BRIEF}}

<!--
Sem patří výstup Discovery Q&A (tenantní orchestrátor při scaffoldu):
- Cílový výsledek zakázky / oblasti (co je hotovo, až je hotovo).
- Klient / kontext / vztah (kdo je zadavatel, jaký je vztah, oslovení, jazyk).
- Deadline, milníky, MD alokace, rozpočet, hard constraints.
- Klíčové zdroje pravdy (dokumenty, harmonogram, kontrakt, klientský brief).
- Scope boundary - co je in-scope a co explicitně out-of-scope.
- Citlivá data / NDA / compliance režim.
- U Client klasifikace: datová governance per AR-10 (klientův record vs. klientova znalost vs. NSL produkční data o zakázce).
- U zakázky se software částí: dekompozice per AR-11 (appka/kód = samostatný projekt vs. obsah/delivery).
Brief je zdroj pravdy pro každý brief subagentovi (OR-01). Když je prázdný, projekt není ready k exekuci.
-->

## Hranice zadání

**Co do jednotky patří:** {{výčet typických zadání}}

**Co se dá zaměnit, ale patří jinam:**
- {{zadání}} → {{jednotka nebo projekt}}, protože {{důvod}}

Pravidlo psaní: **každý řádek v druhém seznamu musí uvést, kam to patří místo toho, a proč.** Věta bez adresáta je stížnost, ne hranice.

<!--
Vyplňuje se postupně, při první běžné úpravě tohohle souboru, ne dávkově - dávka vyrobí
věty, které nikdo nepromyslel. Do té doby zůstávají zástupné symboly a je to legitimní stav:
validátor tuhle sekci nekontroluje, je to obsah, ne struktura.

Sekce odpovídá na otázku, kterou dostane každý, kdo jednotku otevře poprvé: "patří tohle
zadání sem?" Bez ní se odpovídá dohadem a práce skončí ve špatné jednotce - nejčastěji
v té, kterou měl člověk zrovna otevřenou.
-->

## Tým

**Orchestrátor: Quentin.** Kanonická definice `~/.claude/agents/quentin.md` (platform library, jediné místo rozvoje) + tento projektový kontext. Quentin drží operativu STUDIO jednotky - backlog, status header, delegace na specialisty, header disciplínu.

**Hire nové role:**
- Potřeba specialisty → Quentin hledá v `~/.claude/agents/` (GLOBAL primary). Pokud existuje, instanciuje. Pokud chybí, eskaluje Stanislavovi s návrhem role.
- **Jméno agenta = Stanislavova brána.** Jméno vždy vybírá Stanislav přes Q&A (slavné osobnosti, jejichž jméno významem souvisí s rolí). Platí i při hire v projektové session, ne jen v META. Provizorní pracovní název je OK, ale musí být explicitně flagnutý a doladěný se Stanislavem před promotion do GLOBAL.
- Kompetenční mapu dělá Sherlock, personu a agent definici Panoš.

**Lokální overlay agenta (AR-12):** když STUDIO jednotka potřebuje lokální dovednost (tenant MCP konektor, klientská doména, lokální pravidla), vzniká overlay `<name>-<tenant>.md` s pointerem na kanonickou definici a jen deltou (≤ 60 řádků). **Same-name stínění kanonického agenta je zakázáno** (fork = drift, kanál selhání propagace). Konvence a povinný tvar overlaye: `.claude/agents/README.md`.

## Provozní normy (OR-01 až OR-12)

Zkrácený výtah. **Kanonické texty OR s Why / Test / referencemi: `docs/normy.md`; AR rozhodnutí: `docs/architektura-vrstev.md`.** Při jakékoli nejasnosti čti kanonický zdroj, neimprovizuj - tenhle výtah je orientační, ne náhrada.

- **OR-01 Kompletní kontext subagentovi.** Před každou delegací přibal zdroje pravdy, parametry, fixní hodnoty, předchozí rozhodnutí, constraints, formát výstupu i styl. Nejistá hodnota → ověř ve zdroji, nestav brief na paměti.
- **OR-02 Secrets discipline.** Nikdy neukládej secrets (klíče, tokeny, hesla) do Notion, gitu, plaintextu, nezabezpečené komunikace. Při detekci flagni jen lokaci, nikdy hodnotu. Nepřebitelné.
- **OR-03 Status header kontrakt.** `operations/status.md` má jako první sekci strojově čitelný header (Last update, Klasifikace, Fáze, Health, top 3 úkoly, blokátory, next milestone). Update event-driven při milestone, ne mechanicky.
- **OR-04 Specialist delegation primacy.** Úkol v doméně specialisty → defaultně deleguj, i když máš tooling sám. Self-execute jen výjimky (specialist neexistuje / sub-2-min trivial lookup / explicitní pokyn / circular dependency).
- **OR-05 Strukturní integrita.** Destruktivní strukturní operace (move container, `replace_content`, edit stránky s inline databázemi) → pre-op soupis children + operace + post-op verifikace HNED. Platí u Notion a strukturních zápisů. Doplněk v2 - mutace cizího prostředí (klientský Notion, CRM, file systém, cloud konfigurace, repo klienta): plán s dry-run výpisem → explicitní konsent člověka → apply → post-op verifikace proti plánu; backup před destruktivním krokem. Agent připravuje, člověk spouští - u klientských prostředí bez výjimky.
- **OR-06 team-outcomes číslování.** Každý sekvenční výstup dostane trojmístný prefix `NNN-<slug>.md`. Přidělení: glob `[0-9][0-9][0-9]-*` → max + 1; kolize → nejbližší volné. Výjimka: stable-name methodology deliverables (nečíslují se). Forward-only.
- **OR-07 v3 Model + effort disciplína.** Model i effort se volí při spawnu, routing je dvouosý a směr kalibrace se řídí rizikem: levná/vratná práce → start na nejnižším tieru, který úkol udělá dobře, self-flag nahoru; drahá/nevratná → start high/xhigh, sestup po naměřené kvalitě. Metrika = cost per successful outcome, ne cena za token. Malé kontextové úlohy nedelegovat (startup overhead subagenta); briefovat odkazem, ne opisem. Agent self-flagne mismatch tieru na obou osách; orchestrátor při mismatch session doporučí Stanislavovi `/model` + `/effort`. Dvojice strategických rolí má vlastní downgrade pravidlo (kanonický text).
- **OR-08 Priorita instrukčních vrstev.** Při konfliktu vyhrává (odshora): harness → bezpečnost/etika → Stanislav v turnu → USER pravidla → platformní normy (AR/OR) → TENANT → STUDIO → agent definice → skills → brief → memory. Aktivně řešený konflikt flagni jednou větou.
- **OR-09 Agent nepřepisuje vlastní kontrakt.** Žádný agent needituje vlastní ani cizí definici, launcher či pravidla mimo governance flow. Zlepšení navrhne (flag), zapisuje ho člověk nebo Panoš po lidském schválení.
- **OR-10 Lifecycle obsahu.** Header drží jen aktuální stav (distilát), historie do rolling logu pod ním - žádné řetězení "Předchozí: ...". Staleness sweep periodicky. Nahrazené výstupy → `team-outcomes/archive/`. Každý fakt má jeden kanonický domov, ostatní odkazují.
- **OR-11 Content preflight gate.** Content agent (próza pod brand hlasem) před generováním deklaruje 4 naložené pilíře řádkou `Naloženo: tón [zdroj], cílovka [zdroj], příklady [zdroj], struktura [zdroj]`; bez jmenovaného zdroje negeneruje, ptá se. Orchestrátor v zadání pojmenuje collaboration level 0-5.
- **OR-12 Disciplína changesetů.** Změna s dosahem mimo METU nese changeset v okamžiku změny (`operations/changesets/` METY) + commit trailer `Changeset: <id>` nebo evidované `none (<důvod>)`. Orchestrátor jednotky spouští startup check (`validate.sh --baseline <jednotka> --line`) a frontu odbavuje, nebo vědomě odkládá.

**Nákladová kritéria pro produktové jednotky (Typ Mini-produkt / Automat):** kde jednotka volá API (ne subscription), patří do návrhu od začátku: caching-friendly struktura promptů (stabilní prefix: tool definice → systémový prompt → referenční dokumenty → dynamická data na konec), Batch API pro offline pipeline (50% sleva bez dotyku na kvalitu), model routing per typ úlohy. Know-how: Notion KB „Optimalizace nákladů na LLM - routing modelů a effort per typ úlohy".

## Struktura projektu

| Složka / soubor | Účel | Kdo zapisuje |
|-----------------|------|--------------|
| `CLAUDE.md` | Projektový kontext, Discovery brief, provozní normy (tento soubor) | Quentin, Stanislav |
| `.claude/agents/` | Lokální overlay agenti per AR-12 (`<name>-<tenant>.md` + pointer). Konvence v `README.md`. Same-name stínění zakázáno. | Panoš (governance flow) |
| `operations/` | Provozní vrstva - `backlog.md`, `status.md` (OR-03 header), `decisions/`, `handoffs/`, `runbooks/`, `retrospectives/` | Quentin |
| `team-inbox/` | Podklady od Stanislava / tenanta - tým čte, nemaže se | Stanislav, tenant → tým čte |
| `team-outcomes/` | Persistentní výstupy k revizi (OR-06 číslování) + `archive/` (OR-10) | Celý tým |
| `strategic/` | Volitelné - Playing to Win cascade, hypotézy, SDR (jen u strategických STUDIO jednotek, per AR-04) | Strateg + Stanislav |
| `research/` | Volitelné - výzkumné podklady, kompetenční mapy | výzkumná role, Sherlock |

## Jazyk a styl

Závazná NSL pravidla (plný text `~/.claude/CLAUDE.md`):
- **Česky s diakritikou.** Nikdy slovensky. Slovenské zabarvení → upozornit a opravit.
- **Krátká pomlčka (-)**, nikdy em-dash ani en-dash. Pro pauzu čárka, středník, závorky.
- **Žádné horizontální dividery** (`---`) v Markdown obsahu. Sekce oddělují nadpisy nebo prázdný řádek.
- **Zakázaná slova:** unikátní, jediný, nejlepší, revoluční, průlomový, game-changing, transformativní, komplexní, enterprise (bez substance). Přidaná hodnota se prokazuje prací, ne adjektivy.
- **Žádné šíření strachu** - motivace pozitivní (příležitost, výhoda, efektivita), ne apokalyptické scénáře.
- **Bez manipulativních technik** - transparentnost před taktickou výhodou. Cokoli, co se čte jako manipulace, flagni jako etický bod.
- **Bez AI-tropů** ("Není to jen X, je to Y", "Zkrátka...", "V dnešní době", robotické věty stejné délky, nadužívání bulletů).
- **AI-safe Markdown** (Obsidian konvence) - žádné wikilinks `[[...]]`, transclusions, canvas; standardní `[text](cesta.md)` odkazy. Detail v konvenci přenositelného Markdownu platformy.
- **Lidský test před odevzdáním:** "Kdyby to psal kolega v e-mailu, zní to přirozeně?" Pokud ne, přepsat.
