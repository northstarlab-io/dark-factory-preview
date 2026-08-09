# Prohlídka

Pět míst v repu v pevném pořadí, zhruba patnáct minut. Nemusíš nic spouštět; příkazy jsou u toho pro případ, že chceš. Pořadí jde od věci, kterou si umíš představit, k té, na které to celé stojí: atom, role, doktrína, propagace, brána.

Pojmy, o které cestou zakopneš, jsou vysvětlené v [CO-JE-DARK-FACTORY.md](CO-JE-DARK-FACTORY.md).

## 1. Z čeho vzniká jednotka a co o sobě hlásí

`scaffold/studio-template/` a `ukazka-jednotky/operations/status.md`

**Co tady uvidíš.** Kostru, ze které vzniká nová jednotka, a hlavičku, kterou každá jednotka povinně vyplní: sedm polí v pevném tvaru, mezi nimi klasifikace, fáze, zdraví a to, komu jednotka slouží. Tři runbooky jsou v šabloně od začátku, ne až když je potřeba.

**Co z toho plyne.** Stav portfolia se nesbírá dotazováním, čte se ze souborů, které vypadají stejně v každé jednotce. Ověřit to jde za vteřinu: `bash scaffold/validate.sh ukazka-jednotky`.

## 2. Role jako kontrakt

`knihovna/agents/quentin.md`

**Co tady uvidíš.** Frontmatter s modelem a nástroji, výčet „v doméně" a „mimo doménu" včetně toho, komu se práce předává, železná pravidla s prahem, kdy si role smí úkol vzít sama, a u několika z nich doložený incident s datem. Ve stejné složce jsou i další definice; podle čeho jsou vybrané, říká `knihovna/README.md`.

**Co z toho plyne.** Role není prompt, je to kontrakt. Hranice v něm nejsou z pořádkumilovnosti: skoro každá je tam proto, že se ta věc už jednou udělala špatně a bylo to vidět na výstupu.

## 3. Odkud se pravidla vzala

`docs/normy.md`

**Co tady uvidíš.** Dvanáct provozních norem. U každé pravidlo, důvod, test, kterým si ověříš, že ho dodržuješ, a incident, kterým norma vznikla, včetně data a toho, co selhalo.

**Co z toho plyne.** Pravidla tu nevznikla návrhem, vznikla z chyb. U každého je vidět z jaké, takže se dá i vyhodit, až přestane platit; pravidlo bez doloženého původu vyhodit nejde, protože nikdo neví, co jím bylo koupeno.

## 4. Jak se změna dostane k tomu, koho se týká

`operations/changesets/2026-08-03-zaveden-mechanismus-propagace.md`, `ukazka-jednotky/operations/platform-baseline.md` a zachycený výpis `operations/ukazky/fronta-changesetu.txt`

**Co tady uvidíš.** Lístek k jedné změně platformy s lidskou větou napsanou v okamžiku změny, s akcí pro příjemce a s blokem strojového testu. Vedle toho evidenci jednotky o tom, co převzala, a výpis fronty se strojovým řádkem `lag=5`.

**Co z toho plyne.** Změna, kterou nikdo nepřevzal, je vidět jako číslo, místo aby se na ni přišlo náhodou. Přiložená jednotka je pozadu schválně, je založená dnes a frontu má od nuly.

Když si příkaz pustíš, čekej u většiny lístků `FAIL`, ne `PASS`: jejich testy se ptají na soubory v naší platformní knihovně a ty u sebe nemáš. Brána je fail-closed, takže nezměřitelné neprohlásí za v pořádku. Třetí hodnotu `NEZJISTENO` dostaneš tam, kde nástroj neumí ani rozhodnout, jestli má nad čím měřit. Obojí je v hlavičce `operations/ukazky/fronta-changesetu.txt` i s příkazem, kterým si ten druhý stav vyrobíš.

## 5. Kdo to hlídá, když se nikdo nedívá

`scaffold/validate-platform.sh --help` a `scaffold/hooks/pre-commit`

**Co tady uvidíš.** Osmnáct číslovaných kontrol vypsaných z hlavičky samotného skriptu a hook, který je při commitu spouští. V hooku je i vysvětlení, proč se měří plocha commitu a ne pracovní strom, a co se stalo, když to bylo obráceně.

**Co z toho plyne.** Nápověda se generuje z hlavičky skriptu, takže se s ním nemůže rozejít. Měřicí běh tady nefunguje, chybí mu korpus, nad kterým počítá; instalátor bran v balíčku schválně není, nastavil by ti hooky, které by ti zablokovaly commity ve tvém vlastním repu. Detail v [hranice-baliku.md](hranice-baliku.md).

## Kde to drhne a co dál

Nejostřejší věc na konec: strojový sken přístupových údajů z konstrukce nevidí jméno klienta, hledá tvary tokenů. Při přípravě tohohle balíčku byl sken čistý a ruční audit našel jméno klienta ve víc než stovce souborů. Proto tu není historie. Zbytek toho, co dnes nefunguje, je v sekci Co dnes nefunguje v [CO-JE-DARK-FACTORY.md](CO-JE-DARK-FACTORY.md); pět případů rozepsaných i s tím, co se po nich změnilo v mechanismu, je v [casy/](casy/README.md).

Když tě zaujal konkrétní mechanismus, napiš mi který (adresa je v [NOTICE.md](../NOTICE.md)). Sednout si nad jednou věcí, která ti dnes chybí, je užitečnější než nad celým systémem. A když ti u některé zastávky přijde, že je to postavené špatně, ozvi se s tím taky; kvůli tomu si to ukazujeme.
