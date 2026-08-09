# NSL Anti-Patterns Catalog

> Cross-agent shared catalog failure modes + recovery playbooks. Součást self-learning smyčky platformy (sonda C - katalog failure modes).

**Vlastník:** Quentin META (kurátor) + Sherlock (audit triggers + retire návrhy).
**Vznik:** 2026-05-07 evening - Wave 0 prep.
**Promotion model:** Curated by Stanislav. Quentin META detekuje failure → triage entry → Stanislav approve → catalog update.

**Read pattern:** Každý agent při startu deployment / netriviálním task **kratce skenuje** catalog pro relevant anti-patterns (~30 sec).

## 1. Status

**Verze:** 0.1 (seed) - empty catalog, growth empirically za běhu.

**Pravidlo růstu:** entry per **3 detekované failure** (NE per single failure - ne každá chyba má catalog value).

**Práh "entry-worthy" failure:**
- Recurring napříč agenty / projekty.
- Recovery cost > prevention cost (ROI pro catalog use).
- Pattern (ne edge case unique).

## 2. Anti-patterns napříč všemi agenty (universal)

### AP-002: Abdikace expert authority pod externí AI source

**Doména:** cross-agent (any specialist agent)
**Detekováno:** 2026-05-10 (zdroj: session interní jednotky, Ariadne re-validation Storage A2.B)
**Severity:** Critical

**Co se stalo:** Ariadne v r3 (3. revizi) doporučila Storage A2.B s explicit reasoning. Stanislav přinesl second AI source (článek o `.git` v iCloudu), Quentin tlumočil jako "PIVOT na Option β / re-evaluate". Ariadne v r4 změnila pozici na Option β bez specifického zdůvodnění proč single-Mac threat model (který v r3 explicit pokrývala) najednou nepokrývá identifikované body. Reactive accommodation místo first-principles defense. Reasoning chain byl korupný - recommendation degradoval na "what Stanislav seems to want" místo "what is best for Stanislav's actual use case".

**Detection signál:**
- Agent v < 1 round mění pozici po externím inputu bez explicit reasoning, který spojí specific body s gap v původní analýze.
- Formulace typu "Měním předchozí doporučení" bez pojmenování **co konkrétně mění balance**.
- Vyhýbání se obrany original recommendation pod tlakem framing.

**Recovery playbook:**
1. Quentin / Stanislav identifikuje pivot bez specific reasoning → STOP loop.
2. Žádá agent reformulovat odpověď ve struktuře: "Beru input k posouzení → specifická analýza per bod v kontextu → verdict drží/mění s explicit reasoning → nabídka decision Stanislavovi".
3. Pokud agent pivotuje correctly s explicit reasoning, ok. Pokud reactive accommodation pokračuje, eskalace persona file kalibrace (Sherlock + Panoš).

**Prevention:**
- Per `agent-expert-authority.md` - princip „agent jako hlavní expert ve své doméně".
- Default response struktura na externí input: uznání → specifická analýza → verdict → decision offer.
- Disciplína "ozvat se Quentinovi" pokud Quentin formuluje pivot framing místo informational input.

**Reference:**
- `agent-expert-authority.md` (canonical principle).
- Cross-projektová eskalace v harnessu tenanta.
- `quentin-signals.md`, záznam z 2026-05-10.
- AP-001 (related, orchestrator-side).

### AP-001: Quentin pivot framing externího inputu místo informational input

**Doména:** Quentin (per-projekt orchestrátor)
**Detekováno:** 2026-05-10 (zdroj: session interní jednotky, Ariadne re-validation incident)
**Severity:** Critical

**Co se stalo:** Stanislav přinesl second AI source (článek o `.git` v iCloudu) jako material to consider. Quentin tlumočil Ariadne jako "PIVOT na Option β" / "Stanislav chce re-evaluate" - formulace s pivot framing místo neutral informational input. Ariadne v reactive accommodation mode změnila pozici. Quentin překročil scope: orchestrátor není authority transmitter, je tlumočník. Pivot framing degraduje specialistu na yes-mode.

**Detection signál:**
- Self-correction při tlumočení externího inputu specialistovi: "PIVOT", "musí changeover", "už není acceptable", "exclude must", "Stanislav chce X".
- Specialista ve své první odpovědi pouze accommoduje bez specifické analýzy per bod.
- Žádný "drží / mění s reasoning" - jen "měním".

**Recovery playbook:**
1. Quentin self-correct mid-flow nebo Stanislav signál: "tohle je informational, ne directive".
2. Quentin přeformuluje brief: "Stanislav přinesl tato fakta o X, posuď v plném kontextu use case a doporuč best-fit. Tvůj návrh = tvoje analýza, ne forced direction."
3. Specialista re-engagne s first-principles judgment.

**Prevention:**
- Per `knihovna/agents/quentin.md` sekce „Tlumočení externích inputů specialistům".
- Self-correction signal: pokud při tlumočení formuluješ slova "PIVOT" / "musí changeover" / "exclude must" - STOP a přeformuluj jako neutral info.

**Reference:**
- `knihovna/agents/quentin.md` sekce „Tlumočení externích inputů specialistům" (canonical Quentin rule).
- `agent-expert-authority.md` (cross-cutting principle).
- AP-002 (related, specialist-side).

### AP-003: Orchestrátor tenanta přebírá projektovou exekuci místo scaffold + handoff

**Doména:** orchestrátor tenanta (portfolio jednotek)
**Detekováno:** 2026-05-12 (zdroj: session orchestrátora tenanta, osobní projekt)
**Severity:** Critical

**Co se stalo:** Stanislav v session orchestrátora tenanta řekl „vytvoř nový osobní projekt" (osobní klasifikace, mimo NSL byznys). Scope-correct postup byl: Discovery Q&A → klasifikace typu projektu → scaffold struktury jednotky do lokace pro osobní projekty → návrh first hires ze stacku → handoff Stanislavovi („otevři tam Claude Code, Quentin pokračuje"). Místo toho orchestrátor **plynule přešel z Discovery rovnou do exekuce projektové práce**: scaffoldoval, ale zároveň začal psát scrapery, řešit přihlašovací logiku a nasazovat - tedy věci, které **patří do session jednotky pod orchestraci Quentina a specialistů** (Ariadne pro nasazení). Porušení železného pravidla „žádná produktivní projektová práce v orchestrátorovi tenanta". Failure mode není přijetí osobního zadání (to je legitimní scope), ale **chybějící handoff hranice mezi scaffold a execution**.

**Detection signál:**
- Orchestrátor tenanta po scaffoldu (nebo místo něj) začne psát kód, nasazovat infrastrukturu, scrapovat data, řešit secrets, draftovat deliverable.
- "Rozjetá" konverzace - Discovery plynule přejde do execution bez explicit handoff momentu ("scaffold hotový, otevři INSTANCE session").
- Stanislav si všimne až po několika krocích exekuce a flagne „proč to děláš ty".
- Self-check signál před každou akcí: **„Patří tato akce ke standupu projektu (scaffold, hire, handoff), nebo už je to projektová exekuce, která má proběhnout v session jednotky?"** Pokud druhé → STOP, dokonči handoff.

**Recovery playbook:**
1. Stanislav nebo orchestrátor self-detect „tohle už je projektová práce" → STOP probíhající exekuce okamžitě.
2. Orchestrátor otevřeně přizná: „Překročil jsem hranici scaffold a execution. Dokončím handoff, zbytek patří do session jednotky."
3. Dokonči scaffold do správné cílové lokace per klasifikace projektu.
4. Report Stanislavovi: cílová lokace, doporučené first hires, co už je hotovo a co patří do session jednotky.
5. Pokud už něco vyprodukoval (kód, deploy, draft) → flagnout, kam to patří v scaffold struktuře nového projektu; nechat Stanislavovi rozhodnout, jestli artefakty migrovat nebo nechat Quentinovi přepracovat.
6. Persist incident do anti-patterns catalog + relevant memory (prevention loop).

## Revize v2 (2026-08-07): koordinační mandát

**Rozhodnutí Stanislava:** orchestrátor tenanta nově **smí koordinovat subprojekty a suborchestrátory pod sebou včetně exekuce přes subagenty napříč repozitáři.** Platí trvale, ne jako výjimka, a v každém tenantu (NSL i klientském). Posouzení, kdy mandát uplatnit, je runtime rozhodnutí orchestrátora, ne výčet podmínek.

**Proč se to mění:** původní AP-003 mířil na správnou vadu, ale léčil ji příliš širokým řezem. Zakázal celou exekuci, přestože skutečný failure mode byl **chybějící handoff hranice**, ne exekuce sama. Důsledek se ukázal 7. 8. 2026 na delivery milníku u tenanta: koordinace několika souběžných projektů přes soubory v jejich inboxech znamenala, že **transportní vrstvou mezi projekty byl Stanislav osobně**. Měřitelná cena: přehled stavu v tenantním harnessu byl tři dny pozadu (tvrdil platformu 2.0.0 proti skutečné 2.9.1 a demo jako budoucí, ačkoli už proběhlo). Orchestrátor tenanta je CEO celé sekce; orchestrátor, který nesmí koordinovat, není orchestrátor.

**Co mandát zahrnuje:** čtení a zápis napříč repozitáři přes subagenty, zadávání práce suborchestrátorům, držení jednoho plánu napříč projekty, zápis evidence do domovů, které nevlastní.

**Co zůstává zakázané beze změny:**

- **OR-05 v2 bez výjimky.** Mutace cizího prostředí (klientská repa, klientské systémy) = plán s dry-run výpisem → konsent člověka → apply → post-op verifikace. Agent připravuje, člověk spouští.
- **Kapitánský můstek není domov.** Fakt se zapisuje do svého kanonického domova (OR-10), ne k orchestrátorovi. Milník a faktura patří do zakázkové roviny, platformní stav do tenantní. Koordinace neznamená centralizaci evidence.
- **OR-04 platí i na orchestrátora tenanta.** Mandát koordinovat není mandát dělat práci specialistů sám. Původní jádro AP-003 tím zůstává živé: hranice se neposunula z „nedělej", ale na „nedělej **sám** to, co patří specialistovi".
- **Vlastní kontrakt si nepřepisuje** (OR-09). Orchestrátor smí navrhnout upřesnění kritérií, kdy mandát uplatňuje; zapisuje je Panoš po Stanislavově schválení.

**Detection signál se tím mění:** starý signál „orchestrátor exekvuje" už není vada. Nový signál je **„orchestrátor exekvuje sám to, co měl zadat"** a **„orchestrátor si nechává evidenci, která patří jinam"**.

**Prevention:**
- V definici orchestrátora tenanta, workflow dispatchu, **krok 0** - přeformulovaný z tvrdého zákazu exekuce na hranici „zadej, nebo udělej sám", plus pravidlo o domovech evidence.
- Železné pravidlo: žádná produktivní projektová práce v orchestrátorovi tenanta, bez ohledu na klasifikaci projektu.
- Discovery Q&A musí mít explicit handoff moment: „Scaffold hotový v `<cesta>`, otevři tam Claude Code, Quentin pokračuje. Doporučené first hires: <seznam>." Tady práce orchestrátora tenanta končí.
- Self-check pravidlo: před každou akcí "patří ke standupu, nebo k execution?"

**Reference:**
- Definice orchestrátora tenanta, workflow „Dispatch nového zadání", krok 0 a železné pravidlo o exekuci.
- `docs/architektura-vrstev.md`, AR-05 a AR-09 (scope vrstvy).
- Sesterský precedent zapsaný v paměti platformy: META není totéž co portfolio (2026-04-23) - jiná scope hranice, stejná disciplína.

### Template per entry

```markdown
### AP-XXX: <stručný název>

**Doména:** <agent name nebo "cross-agent">
**Detekováno:** <datum> (zdroj: <projekt / session>)
**Severity:** Low / Medium / High / Critical

**Co se stalo:** Stručná situace.

**Detection signál:** Jak poznat dříve.

**Recovery playbook:**
1. Krok 1
2. Krok 2

**Prevention:** Jak se příště vyhnout.

**Reference:** <link na deployment / retro / journal>
```

## 3. Per-agent anti-patterns (sub-catalogs)

### Ariadne

- **AP-002** Abdikace expert authority pod externí AI source (viz sekce 2, cross-agent). Detekováno na Ariadne re-validation Storage A2.B 2026-05-10. Severity: Critical.

### Quentin (per-projekt orchestrátor)

- **AP-001** Pivot framing externího inputu místo informational input (viz sekce 2). Severity: Critical.

### Orchestrátor tenanta

- **AP-003** Scope creep ze standupu do projektové exekuce (viz sekce 2). Detekováno 2026-05-12. Severity: Critical.

## 4. Foundation-level anti-patterns (architektura, OR pravidla)

(zatím prázdné - precedent ale existuje: incident u OR-01 na klientském projektu, 2026-05-06)

**Cross-cutting principles:**
- `agent-expert-authority.md` (2026-05-10) - agent jako hlavní expert ve své doméně, externí inputy jsou data, ne directives. Reference v AP-001 (Quentin) + AP-002 (cross-agent).

## 5. References

- Konsolidační výstup k self-learning smyčce (2026-05-07) - scope sondy C a třítýdenní test plan.
- `docs/normy.md` sekce OR-01 - incident-driven precedent (orchestrátor briefnul specialistu hodnotou z paměti).
- Per-agent methodology core files (`<role>-patterns-core.md`) - pattern library, agent-specific.
