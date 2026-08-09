# Runbook: výmaz osobních údajů z workspace repa tenanta

> Kdy stačí smazat soubor a kdy se musí přepsat historie, jak to udělat a jak ověřit, že to zabralo.
> **Vlastník:** Ariadne (system architecture a bezpečnost). **Spouští:** člověk (správce instance), nikdy agent sám.
> **Zavedeno:** 2026-08-04 jako závazná podmínka rozhodnutí D7 (obsah jednotek je verzovaný v gitu).

## Proč tenhle runbook existuje

D7 (Stanislav, 4. 8. 2026) rozhodlo, že obsah STUDIO jednotek v repu tenanta je verzovaný včetně `team-inbox/` a `team-outcomes/`. Git historie je z principu nesmazatelná běžnými prostředky: `git rm` a commit odeberou soubor z pracovní kopie, ne z historie. Tam, kde jednotky pracují s osobními údaji, přitom může přijít žádost o výmaz podle GDPR a odpověď „je to v historii, nejde to" není splnění.

Runbook je tedy protějšek D7. Rozhodnutí drží proto, že existuje doložený postup, jak jeho následek vrátit.

## Hranice scope

Runbook řeší **jedno git repo workspace tenanta a jeho klony**. Nic víc.

| Kde jsou osobní údaje ještě | Kdo to řeší |
|---|---|
| Systém záznamu klienta (CRM, kde vzniká primární záznam o člověku) | retence a proces klienta |
| Znalostní báze tenanta | retence a proces klienta |
| E-mail, přepisy schůzek, sdílené disky | vlastník daného systému |
| Zálohy strojů s klonem (Time Machine, iCloud, externí disk) | vlastník stroje, po instrukci správce |

Git repo je **kopie, ne systém záznamu**. Výmaz v repu je jeden krok z několika a runbook netvrdí, že vyřizuje celou žádost. Kdo žádost odbavuje, musí projít všechny řádky tabulky výše zvlášť.

## Krok 0: klasifikace nálezu

Tři otázky v tomhle pořadí.

1. **Je to secret** (token, heslo, klíč, credentials)? Pak platí OR-02 a jiné pořadí kroků: secret se považuje za kompromitovaný okamžikem, kdy se dostal do repa, takže **první je rotace, teprve druhý výmaz z historie**. Výmaz bez rotace je kosmetika.
2. **Přišla žádost o výmaz, nebo jde o údaje, které v repu nikdy neměly být** (cizí tenant, NDA, třetí strana)? Pak varianta B, přepis historie.
3. **Jinak** varianta A, smazat a commitnout.

| Situace | Varianta | Proč |
|---|---|---|
| Obsah dosloužil, běžný úklid nebo retence; údaje smí v historii zůstat | A | repo je private, okruh čtenářů je evidovaný a schválený |
| Žádost subjektu údajů o výmaz (GDPR čl. 17) | B | právo na výmaz míří na všechny kopie, ne jen na aktuální stav |
| Osobní údaje třetí strany nebo jiného klienta, které v repu nikdy neměly být | B | k obsahu se dostal okruh lidí, který k němu nemá právní titul |
| Secret | rotace, pak B | viz otázka 1 |
| Podezření na únik mimo evidovaný okruh (ztracený stroj, sdílený přístup) | B | evidence čtenářů přestala platit |

**Kdo rozhoduje:** správce instance (Stanislav). Varianta A je běžné provozní rozhodnutí. Varianta B se dokumentuje (co, kdy, na čí žádost, kdo provedl).

**Poznámka k proporcionalitě.** Varianta A je většinový případ a je v pořádku. Přepis historie má reálnou cenu: změní se všechny SHA, každý existující klon se musí založit znovu, odkazy na commity v dokumentech a poznámkách přestanou platit. Sahat po B tam, kde stačí A, je vlastní škoda bez zisku.

## Varianta A: smazat a commitnout

```bash
cd <workspace-repo>
git rm <cesta/k/souboru.md>
git commit -m "Odstraneni obsahu, ktery dosloužil"   # bez jmen a bez hodnot v hlášce
git push
```

Historie se nemění, do klonů se změna dostane běžným `git pull`. Zápis do `operations/worklog.md` stačí jednou větou. Hotovo.

## Varianta B: přepis historie

### B0: agent připraví, člověk spustí

Per OR-05 doplněk v2 (mutace prostředí, které NSL nevlastní): agent (Ariadne, Quentin instance) smí najít výskyty, sestavit seznam cest, připravit přesné příkazy, sepsat komunikaci pro ostatní a vyrobit dry-run výpis „tohle se změní". **Agent nespouští přepis historie ani force push do klientova repa.** Dry-run výpis je povinný vstup konsentu, ne formalita.

Containment per OR-02: přípravné výstupy uvádějí **lokaci** (soubor, řádek, commit), nikdy hodnotu. Seznam hledaných hodnot žije v souboru **mimo repo** (pracovní adresář, ne iCloud) a po dokončení se maže. Do chatu, do ticketu ani do commit hlášky se hodnoty neopisují, jinak výmaz replikuje to, co maže.

### B1: okno zmrazení

Napiš všem z `operations/prava-zapisu.md`: „od teď do odvolání do repa `<jméno>` nikdo nepushuje a nepulluje, ozvu se, až to bude hotové."

Důvod není opatrnost. Kdo mezitím pullne nebo pushne ze starého klonu, **vrátí staré commity zpátky na server** a přepis je zbytečný. Okno se plánuje na hodiny, ne na dny, a začíná až ve chvíli, kdy je připravené všechno ostatní.

### B2: záloha

```bash
git clone --mirror git@github.com:<org>/<repo>.git /tmp/<repo>-zaloha.git
git -C /tmp/<repo>-zaloha.git bundle create /tmp/<repo>-pred-prepisem.bundle --all
```

Záloha je pojistka na chybu při přepisu, ne archiv. Drží se **jen po dobu okna** a pak se maže, protože sama obsahuje přesně ty údaje, které mažeme. Nikdy ne na sdílený disk ani do cloudové synchronizace. Precedent: bundle před očistou historie 7. 7. 2026.

### B3: nástroj

Používá se **`git filter-repo`**, ne `git filter-branch` (ten je pomalý, snadno nechá nekonzistentní stav a Git sám ho nedoporučuje). Na stroji standardně není:

```bash
brew install git-filter-repo
git filter-repo --version
```

Přepis se dělá **na čerstvém klonu**, ne na pracovní kopii s rozdělanou prací:

```bash
git clone git@github.com:<org>/<repo>.git /tmp/<repo>-prepis
cd /tmp/<repo>-prepis
```

### B4: vlastní přepis

**(a) Celý soubor nebo cesta pryč z historie:**

```bash
git filter-repo --path workspace/<pilir>/<jednotka>/team-outcomes/<soubor>.md --invert-paths
# víc cest: --path opakovaně; vzor: --path-glob 'workspace/**/zaznamy-*.md'
```

**(b) Údaj uvnitř souboru, který má zůstat:**

Soubor s náhradami se drží mimo repo (obsahuje mazané hodnoty), tvar jeden pár na řádek:

```
literal:<hodnota>==>[ODSTRANENO]
regex:<vzor>==>[ODSTRANENO]
```

```bash
git filter-repo --replace-text /tmp/nahrady.txt
```

Dvě věci, na které se zapomíná:

- `filter-repo` po sobě **odstraní remote** (záměrné bezpečnostní chování, aby se omylem nepushlo). Vrací se ručně: `git remote add origin git@github.com:<org>/<repo>.git`.
- Přepis se týká **všech větví a tagů**, které v klonu jsou. Když má repo víc větví, musí být v klonu všechny, jinak zůstane údaj v té vynechané.

### B5: force push a strana GitHubu

```bash
git push --force origin --all
git push --force origin --tags
```

`--mirror` použij jen při úplné náhradě serveru lokálním stavem; smaže na serveru refs, které lokálně nejsou.

Co k tomu patří na straně GitHubu:

- **Branch protection na plánu Free u private repa neexistuje.** Force push tedy projde bez odblokování, ale stejně tak projde omylem. To je důvod pro okno zmrazení (B1), ne argument proti postupu.
- Staré commity zůstávají po force pushi **dosažitelné přes SHA**, dokud neproběhne úklid na serveru. U citlivého případu (secret, doložená žádost o výmaz) požádej **GitHub Support** o odstranění cached views a spuštění GC nad repem. Odkaz na aktuální postup je v dokumentaci GitHubu k odstranění citlivých dat; znění se mění, proto ho tenhle runbook neopisuje.
- Přepis **nemění** `refs/pull/*` (refs pull requestů). Ty odstraní jen support.
- Zkontroluj **releases, artefakty Actions, wiki a forky**. Fork je samostatná kopie celé historie, kterou přepis originálu neřeší; existující fork se musí smazat, jinak je výmaz neúplný.

### B6: klony

Každý existující klon je plná kopie staré historie. Po přepisu se **nedělá pull, ale nový klon.** Pull nebo merge do starého klonu staré commity vzkřísí a při prvním pushi je nahraje zpátky.

Postup per člověk:

1. Starou složku přesuň na plochu (nebo smaž, když v ní nic vlastního není).
2. Stáhni repo znovu, u klientského stroje instalačním balíkem, ne příkazem.
3. Zkontroluj, že aplikace naběhne, a teprve pak starou složku smaž.

U netechnického uživatele tohle nedělá sám ze psaného návodu: buď to proběhne po sdílené obrazovce se správcem, nebo dostane přesný krokový postup s klikáním. Formulace typu „udělej rebase" nebo „přepiš si historii" u téhle cílovky negenerují akci, generují blokaci.

Kontrolní seznam, komu se má ozvat, je `operations/prava-zapisu.md`. Kvůli tomuhle kroku existuje stejně jako kvůli GDPR. **Okno zmrazení se uvolní až po potvrzení od všech**, ne po odeslání instrukce.

### B7: úklid pracovních materiálů

Smaž soubor s náhradami, dry-run výpisy, mirror zálohu i dočasný klon z `/tmp`. Zkontroluj správce schránky a historii shellu, pokud se hodnota omylem psala do příkazu (proto se píše do souboru, ne na příkazovou řádku). Údaj, který jsme právě smazali z historie, nesmí přežít v pomocném souboru vedle.

## Verifikace

Ověřuje se **z čerstvého klonu z GitHubu**, ne z repa, ve kterém přepis proběhl. Lokální stav po přepisu vypadá vždycky správně; poučení ze 4. 8. 2026 zní, že stav se čte z toho, co je nasazené, ne z diffu.

```bash
git clone git@github.com:<org>/<repo>.git /tmp/<repo>-overeni
cd /tmp/<repo>-overeni
```

1. **Cesta zmizela z historie** (prázdný výstup je správný výsledek):
   ```bash
   git log --all --full-history --oneline -- <cesta>
   ```
2. **Vzorek hodnot** přes soubor se vzory, ne přes příkazovou řádku (běh nad velkým repem trvá minuty):
   ```bash
   git grep -I -f /tmp/vzory.txt $(git rev-list --all)
   ```
   Tenhle krok se spouští **před** úklidem B7, protože potřebuje soubor se vzory. Po něm se maže i on.
3. **Sken secretů** na aktuální strom: `tools/sken-secretu.sh /tmp/<repo>-overeni` musí skončit čistě.
4. **Validátor struktury**: `bash scaffold/validate.sh /tmp/<repo>-overeni` bez FAIL. Přepis mohl upustit `.gitkeep` nebo kostru jednotky.
5. **Kokpit a launcher naběhnou z čerstvého klonu.** Když přepis sáhl na cestu jednotky, `workspace-manifest.json` se musí přegenerovat.

Neprojde-li kterýkoli bod, okno zmrazení se **neuvolňuje** a řeší se dál ze zálohy z B2.

## Zápis a doložitelnost

Varianta B se zapisuje do `operations/worklog.md` instance: co (třída údajů a rozsah, ne hodnoty), kdy, na čí žádost, kdo provedl, kdy potvrdily všechny klony nové stažení, co runbook nepokryl a kdo to řeší jinde. Zápis je NSL-side, `operations/` je gitignorované.

Doklad o splnění žádosti dává subjektu údajů klient jako správce. Runbook dodává jen svou část a je poctivější ji takhle i pojmenovat, než tvrdit, že přepisem historie žádost skončila.

## Prevence, která je levnější než výmaz

- `.gitignore` drží secrets a per-stroj soubory mimo repo, re-include pilířů má úzké výjimky.
- `_README.md` v každém `team-inbox/` s větou o zákazu hesel (podmínka D7).
- Sken secretů před každým pushem.
- **V jednotkách drž odkaz do systému záznamu místo kopie celého profilu.** Identifikátor záznamu v systému, kde ten záznam primárně vzniká, plus to, co je pro rozhodnutí opravdu potřeba, je jiná třída rizika než přepsaný profil člověka. Co v repu není, se nemusí mazat.
- Retence: uzavřená jednotka jde do `archive/`, obsah se nedrží věčně jen proto, že disk je levný.
