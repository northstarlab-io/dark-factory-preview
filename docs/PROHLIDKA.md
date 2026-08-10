# Prohlídka

Pět míst v repu v pevném pořadí, zhruba patnáct minut. Nemusíš nic spouštět; příkazy jsou u toho pro případ, že chceš. Pořadí jde od věci, kterou si umíš představit, k té, na které to celé stojí: atom, role, doktrína, propagace, brána.

Pojmy, o které cestou zakopneš, jsou vysvětlené v [CO-JE-DARK-FACTORY.md](CO-JE-DARK-FACTORY.md).

Všech pět zastávek ukazuje mechanismus, tedy soubor, který něco vynucuje. Práci, kterou ten
mechanismus obsluhuje, tady schválně nenajdeš; ta je popsaná ve čtyřech případech
v [pripady-pouziti/](pripady-pouziti/README.md) a čte se samostatně, bez pořadí a bez příkazů.

## 1. Z čeho vzniká jednotka a co o sobě hlásí

`scaffold/studio-template/` a `ukazka-jednotky/operations/status.md`

**Co tady uvidíš.** Kostru, ze které vzniká nová jednotka, a hlavičku, kterou každá jednotka povinně vyplní: sedm polí v pevném tvaru, mezi nimi klasifikace, fáze, zdraví a to, komu jednotka slouží. Tři runbooky jsou v šabloně od začátku, ne až když je potřeba.

**Co z toho plyne.** Stav portfolia se nesbírá dotazováním, čte se ze souborů, které vypadají stejně v každé jednotce. Ověřit to jde za vteřinu: `bash scaffold/validate.sh ukazka-jednotky`.

## 2. Role jako kontrakt

`knihovna/agents/humble.md` a k němu `knihovna/agents/komensky.md`

**Co tady uvidíš.** Roli, která vlastní cestu změny od hotového kódu k zapnutí u konkrétního netechnického uživatele. Frontmatter s modelem a nástroji, výčet „v doméně" a „mimo doménu" adresovaný jménem sousední role, železná pravidla a sekci „Hranice vůči sousedům": u každého souseda šedá zóna, kdo v ní vede a jednovětá heuristika pro nové případy.

**Proč hned dvě.** Poznámky k vydání se dotýkají obou rolí a hranice mezi nimi se rozhodovala, ne vymýšlela: mechanika changesetu a vydání patří jedné, žánr a finální znění textu pro zákazníka druhé, rozhraním mezi nimi je changeset. Najdi si v obou souborech sekci „Poznámky k vydání" a přečti obě, zabere to dvě minuty. Říkají totéž jinými slovy, se stejným datem rozhodnutí. To je celý trik: hranice je vypsaná z obou stran, takže se pozná, když se rozejde.

**Co z toho plyne.** Role není prompt, je to kontrakt. Hranice v něm nejsou z pořádkumilovnosti: skoro každá je tam proto, že se ta věc už jednou udělala špatně a bylo to vidět na výstupu. Ve stejné složce jsou i ostatní definice; jak se čtou a proč ten seznam není úplný, říká `knihovna/README.md`.

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

Nejostřejší věc na konec: strojový sken přístupových údajů z konstrukce nevidí jméno klienta, hledá tvary tokenů. Při přípravě tohohle balíčku byl sken čistý a ruční audit našel jméno klienta ve víc než stovce souborů. Proto tu není historie. Zbytek toho, co dnes nefunguje, je v sekci Co dnes nefunguje v [CO-JE-DARK-FACTORY.md](CO-JE-DARK-FACTORY.md).

Odsud vedou cesty dál, žádná z nich není zastávka, protože se u nich nic nespouští:

- [mapa-projektu.md](mapa-projektu.md) - z jakých projektů se to skládá a co má který na starosti; páteř jmenovitě, byznysová vrstva po kategoriích.

- [casy/](casy/README.md) - pět incidentů platformy rozepsaných i s tím, co se po nich změnilo v mechanismu.
- [pripady-pouziti/](pripady-pouziti/README.md) - čtyři případy práce z reálných projektů: co se zadalo, co odvedla agentní vrstva, kde vstoupil člověk a co se v tom předělávalo.
- [datove-vrstvy.md](datove-vrstvy.md) - kde data bydlí a podle čeho se rozhoduje, kam co patří; zavedená podoba PARA a čtyři místa, kde to dnes drhne.
- [uceni-a-zavedeni.md](uceni-a-zavedeni.md) - co se z provozu sbírá samo, proč zápis do definice role dělá člověk, a šest kroků od zadání k tomu, že to tým používá.

Když tě zaujal konkrétní mechanismus, napiš mi který (adresa je v [NOTICE.md](../NOTICE.md)). Sednout si nad jednou věcí, která ti dnes chybí, je užitečnější než nad celým systémem. A když ti u některé zastávky přijde, že je to postavené špatně, ozvi se s tím taky; kvůli tomu si to ukazujeme.
