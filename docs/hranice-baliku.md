# Hranice balíčku

Co tu běží, co je ke čtení a co tu vědomě není. Pravidlo, které to celé drží: **v balíčku
je jen to, co v něm běží zeleně.** Všechno ostatní se popíše, a to popsání je samo o sobě
informace - věta „u nás tahle brána běží při každém commitu, tady ji nespustíš, protože
potřebuje korpus, který v balíčku není" je poctivější než skript, který ti selže.

## Co běží

| Věc | Příkaz | Naměřeno 9. 8. 2026 |
|---|---|---|
| Validátor jednotky | `bash scaffold/validate.sh ukazka-jednotky` | 8 PASS, 0 FAIL, 0 WARN |
| Fronta nepřevzatých změn | `bash scaffold/validate.sh --baseline ukazka-jednotky --line` | strojový řádek, `lag=5`, `regrese=0`, `vadne=0`; jednotlivé testy lístků u tebe hlásí `FAIL`, protože se ptají na naši knihovnu |
| Sken přístupových údajů | `bash scaffold/tools/sken-secretu.sh .` | `[ČISTO]` |
| Kontrakt hlavičky | `bash scaffold/tests/hlavicka-deklarace-pole.sh` | 0 FAIL |
| Kontrakt strojového řádku | `bash scaffold/tests/strojovy-radek.sh` | 0 FAIL |
| Nápověda validátoru platformy | `bash scaffold/validate-platform.sh --help` | vypíše kontrakt kontrol, návratový kód 0 |

Zachycené výstupy jsou v `operations/ukazky/`. Jsou to snímky k 9. 8. 2026, negenerují se
znovu; příkaz je v hlavičce každého souboru, takže si je můžeš přehrát sám.

## Sedm věcí, které tu chybí, a proč

1. **Instalátor bran tu není a je to schválně.** Nastavil by `core.hooksPath` na hooky,
   které volají validátor platformy; ten se mimo svůj korpus odmítne spustit, takže by ti
   přestaly procházet commity v tvém vlastním repu. Hooky jsou tu ke čtení a samy se
   neaktivují.
2. **Validátor platformy tu neběží, jen `--help`.** Vypíše kontrakt kontrol generovaný
   z hlavičky vlastního skriptu, takže se s ním nemůže rozejít. Měřit nemá nad čím -
   chybí mu knihovna definic a evidence, nad kterou počítá.
3. **Z testové sady jsou tu dva testy.** Zbytek je vázaný na plný korpus changesetů nebo
   na kořen zdrojového projektu. Pět červených testů je horší vizitka než dva zelené
   a jedna věta.
4. **Režim `--baseline` puštěný na tvůj vlastní projekt funguje, ale počítá frontu proti
   našim lístkům.** Správné chování a nesmyslný výsledek zároveň. Pro vlastní použití
   nastav `NSL_META_ROOT` na svůj kořen s `operations/changesets/`.
5. **Kód distribučního mechanismu, šablona tenanta a vrstva pracovního prostoru tu nejsou.**
   Jak render funguje a proč vznikl, je popsané
   v [`architektura-vrstev.md`](architektura-vrstev.md); co tu chybí, jsou soubory
   konkrétního nasazení u konkrétního příjemce - manifest, seznam povolených nástrojů,
   šablona prostředí. To, že tu nejsou, je nejlevnější doklad, že hranice mezi platformou
   a nasazením je reálná, ne deklarovaná.
6. **Výstupy sebeučící smyčky tu nejsou, jen postupy.** Retro, kontrola výstupu i brána
   promotion jsou v `knihovna/skills/` celé, ale retro reporty a týdenní fronty kandidátů
   vznikají uvnitř jednotek a ty tu nejsou. Ověřitelný je postup a jeho stopa v katalogu
   selhání a v definicích rolí, ne provozní záznamy. Rozepsané
   v [`uceni-a-zavedeni.md`](uceni-a-zavedeni.md), část A.
7. **Výčet rolí není úplný.** V `knihovna/agents/` je platformní knihovna celá; doma zůstaly
   definice vázané na jednu jednotku nebo na jednoho tenanta, důvod je
   v [`../knihovna/README.md`](../knihovna/README.md). Definice, které tu jsou, navíc
   odkazují i na dokumenty mimo balíček. Odkaz zůstává schválně: ukazuje, kde ten fakt
   bydlí. Co v balíčku je, vyjmenovává `README.md`.

Obě řady případů, [`casy/`](casy/README.md) i [`pripady-pouziti/`](pripady-pouziti/README.md),
píšou u každého tvrzení, kde si ho v repu ověříš. Když ověřit nejde, je to tam napsané rovnou
a důvod je v tomhle soupisu.

## Co si můžeš vzít a použít zítra

Čtyři věci, které si člověk s vlastní procesní bází v Gitu obvykle nepostaví, dokud ho to
nezačne bolet:

- **Kontrakt hlavičky `operations/status.md`** jako strojově čitelný stav projektu.
- **`validate.sh`** jako lint nad vlastními adresáři.
- **Formát changesetu** s lidskou větou psanou v okamžiku změny, ne rekonstruovanou
  z git logu po týdnu.
- **Šablona jednotky** `scaffold/studio-template/`, ze které vzniká `ukazka-jednotky/`.

## Co s tím udělá tvoje prostředí

Definici role zkopírovanou do `.claude/agents/` tvého projektu Claude Code načte, ale
odkazy uvnitř budou mířit na soubory, které nemáš. Není to vada, je to hranice: kanonický
domov těch souborů zůstal u nás.

V kořeni tohohle repa schválně **není `CLAUDE.md`**. Kdyby tu byl, stal by se ti při
otevření repa v Claude Code instrukcí projektu, a to je tichý zásah do cizího prostředí.
Znění norem je proto ke čtení v `docs/normy.md`. Reálný `CLAUDE.md` uvidíš tam, kde patří:
v `ukazka-jednotky/`, kde je artefaktem systému, ne příkazem tobě.
