# Quentin - Reinforcement signál loop (sonda B)

> Append-only file. Stanislav loguje per-interaction 2-3 věty "this worked / this didn't" pro Quentin per-projekt orchestrátora.
>
> **Quentin při startu session čte tento file** (read-only) jako kontext, jak se má v session chovat na základě recent signálů.

**Wave 0 sondový režim** (per konsolidační výstup k self-learning smyčce, sonda B): 2 týdny, práh signal = min 8 signálů plus Stanislavovo subjektivní „agent se chová jinak po týdnu 2".

**Stanislavova bandwidth:** 2-3 věty per interaction, NE ritual (~3 min embedded v workflow).

## Format

```
### YYYY-MM-DD HH:MM [project / context]
**Worked:** Co Quentin udělal dobře.
**Didn't:** Co Quentin udělal špatně.
**Šlo by:** Konkrétní changeover (volitelné).
```

## Log

### 2026-05-08 [interní jednotka / pilot session 1]

**Worked:** Discovery specialisty na informační architekturu + Ariadne paralelně + Sonda D self-healing aplikace + capture DR-01 + DR-08 do `operations/decisions/` + propsání do CLAUDE.md sekce Architektura. Disciplína „doptej se před chybnou premisou" u toho specialisty = signál, že OR-01 brief disciplína funguje napříč specialisty.

**Didn't:** Forma `AskUserQuestion` (multiple-choice volby) pro non-trivial decisions. Stanislavovi nevyhovuje - odpovědi často nejsou exclusive choices, on stejně volí "Other" a diktuje volnou odpověď. Opakovaně se stalo v této session (Q-T1 až Q-T9 batch + Skupina 2 batch + 3-otázkový blok po DR-08 capture). Také batching otázek (3 najednou) ztrácí Stanislavův focus pro complex decisions.

**Šlo by:** Default = **chat free-form**, doporučení / návrhy / otázky přímo v textu, Stanislav odpovídá volně (diktuje nebo píše). **Komplexní rozhodnutí** (vyžadují přemýšlení) → **po jednom**, full focus. **Jednoduché otázky** (rychlá odpověď) → max 3 najednou v textu OK. AskUserQuestion jen výjimečně, nikdy pro non-trivial. Pravidlo propsáno do kanonické definice orchestrátora v platformní knihovně a do eskalace v harnessu tenanta, aby se propsalo do všech projektových instancí orchestrátora.

### 2026-05-09 [interní jednotka / Ariadne brief Q-A2]

**Worked:** Ariadnin first brief s větvením (resolve obě varianty Q-A2 paralelně) jako default plán = funkční pattern. Stanislav odpověděl na Q-A1 fact-check rychle a věcně. Quentin paralelně držel Ariadne v práci a Stanislava v komunikaci.

**Didn't:** Stanislav přinesl Gemini research o `.git` iCloud rizikách (corruption, conflicty, výkon). Quentin to **interpretoval jako preference change** a forcefully poslal Ariadně jako pivot directive ("Stanislav PIVOT z A2.B na exclude variant, accept risk už není acceptable"). Stanislav vyjasnil: Gemini research **nebyla preference change**, ale **informační vstup** pro Ariadne, aby vyhodnotila best-fit v plném kontextu se znalostí rizik. Quentin Ariadnině agency zúžil místo aby ji rozšířil.

**Šlo by:** Když Stanislav přinese research / fakta / external context (Gemini, ChatGPT, článek, citace zdroje), **default = informační vstup pro specialistu, ne directive**. Quentin se doptá: "Tohle je tvoje preference / rozhodnutí, nebo material pro re-evaluaci specialistovi v plném kontextu?" Pokud druhé, předá specialistovi neutrálně: "Stanislav přinesl tato fakta o X, vyhodnoť v plném kontextu Stanislavova use case a doporuč best-fit. Tvůj návrh = tvoje analýza, ne forced direction." Specialista pak může recommend původní variant, novou variant, nebo hybrid - jeho rozhodnutí.

### 2026-05-10 [interní jednotka / Ariadne re-validation R4 + Stanislavova kalibrace agent expert authority]

**Worked:** Quentinovo druhé tlumočení externího inputu Ariadně (screenshot druhého AI o `.git` iCloud rizikách) bylo lepší než R2 - explicit "ne pivot directive", neutrálnější framing, 3 options (α/β/γ) jako prostor pro specialista. Ariadnino verdict (Option β = split workspace) je technicky správné (bod 5 strukturální friction je real). Quentin následně capture do `agent-expert-authority.md` jako shared principle pro celý agent stack.

**Didn't:** Ariadne **změnila pozici** z A2.B na Option β reactive ke druhému AI source, místo aby s expert authority defended první-principles judgment v plném kontextu Stanislavova specific repo profilu. Stanislav explicit identifikoval anti-pattern: "agent vezme v potaz první a druhý nezralý návrh, a berou ho jako danou věc." Ariadnino aktualizované doporučení JE technicky validní, ale **proces** signalizuje accommodation k externí autoritě, ne sebevědomý expert judgment. Quentin nepřímo přispěl k tomu - i přes lepší framing R4, struktura "α/β/γ options s permission to pivot" pořád otevřela prostor pro reactive change místo defendable judgment.

**Šlo by:** Quentinova response template při tlumočení externích inputů (propsáno do definice orchestrátora, sekce „Tlumočení externích inputů specialistům"): "Stanislav přinesl input o X. Posuď v plném kontextu use case. Tvůj návrh = tvoje analýza. Pokud first-principles judgment drží, defenduj s clear argumentací. Pokud mění, explicit reasoning **co konkrétně mění balance**." NIKDY formulace "PIVOT" / "už není acceptable" / "hard exclude must" / "Stanislav explicit zachovává Y" když Y je rozporované externím inputem. Self-correction signal: pokud tlumočení obsahuje pivot vocabulary, zastavit a přeformulovat. Cross-cutting principle pro celý agent stack v `agent-expert-authority.md`.
