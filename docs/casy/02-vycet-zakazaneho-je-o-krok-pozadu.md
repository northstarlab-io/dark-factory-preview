# Výčet zakázaného je vždycky o krok pozadu

**Kdy:** 6. a 7. srpna 2026, s předchozím případem téže třídy o dva týdny dřív
**Kde:** distribuce agentní sady na stroj mimo naše prostředí
**Třída vady:** oprávnění postavená na seznamu zakázaného

## Co se stalo

Agenti, kteří běží mimo naše prostředí, dostávají vygenerovanou sadu definic. Součástí
každé definice je výčet nástrojů, které smí volat. Ten výčet vznikal odečtením: vzala se
sada z kanonické definice a odečetl se seznam zakázaného pro dané nasazení, položka po
položce podle přesné shody jména.

Šestého srpna přibyla do kanonické definice jedné orchestrační role dvojice čtecích
nástrojů do naší vlastní znalostní báze. Seznam zakázaného tu dvojici neznal, protože
v době, kdy vznikal, ji neměla žádná role. Nezakázal ji tedy nikdo a generátor neměl proč
mlčet. Příští běh by ji vypsal do definice na cizím stroji a spolu s tím do souboru, který
je verzovaný v repozitáři druhé strany.

## Jak se to projevilo

Kontrolou dosahu, kterou dělal ten, kdo změnu do kanonické definice zapisoval. Ne skenem.
Sken vzorů přístupových údajů (je v tomhle balíčku jako `scaffold/tools/sken-secretu.sh`)
tuhle třídu z konstrukce nevidí: identifikátor konektoru není přístupový údaj a nemá tvar,
na který se dá napsat vzor.

Předchozí případ téže třídy proběhl při nasazení o dva týdny dřív. Orchestrační role
dostala na cizím stroji shell a odchozí síť, které v předchozí ručně udržované kopii
neměla. Zachytila to až verifikace po provedení, tedy poslední okamžik, kdy to ještě jde
zachytit.

## Co to stálo

V prvním případě odložené nasazení a hodinu práce navíc, protože se to našlo před
generováním. V druhém případě běželo nasazení s právy širšími, než jaká byla schválená,
až do doby, než doběhlo ověření po provedení. Ani jeden případ neskončil zneužitím; oba
skončily tím, že se schválená hranice a skutečná hranice po nějakou dobu lišily.

## Co se z toho stalo za pravidlo

Autorita se přesunula ze seznamu zakázaného na seznam povoleného a je fail-closed: co
v povolených není, do artefaktu nejde, i kdyby to nikdo nezakázal. Jmenovité rozšíření pro
jednu roli má vlastní klíč. Seznam zakázaného zůstal, ale už jen jako evidence
očekávaného odebrání, ne jako bezpečnostní vlastnost.

Dvě upřesnění ukazují, že to pravidlo není symetrické a proč:

- **Zástupné znaky jsou v autorizačních seznamech zakázané** a engine na nich padá. Vzor
  v seznamu povoleného by pustil i to, co v době psaní neexistovalo.
- **V seznamu zakázaného vzor naopak zůstat smí**, protože tam selhává zavřeným směrem:
  zachytí i nástroj, který ještě nevznikl.

Zobecněná věta, která z toho zbyla a používá se dál i mimo oprávnění: **udržovaný má být
ten seznam, jehož zastarání selže fail-closed.**

## Jak se to hlídá dnes

Autorizuje seznam povoleného, engine je fail-closed a zápisy vygenerovaných souborů čekají
ve frontě, dokud neprojdou všechny; půlka nasazení je horší stav než žádné.

Samotný převod na nový mechanismus nebyl tvrzený, ale měřený: diff vygenerovaných
artefaktů před změnou a po ní měl jediný rozdíl, a to odebranou dvojici u jedné role.
Všechny ostatní vyšly bajtově shodné.

Totéž pravidlo řídilo i stavbu tohohle balíčku. Do něj se nedostalo nic, co nemělo vlastní
řádek v plánu. Výčet toho, co se sem nesmí přibalit, by byl o krok pozadu za tím, kdo do
zdroje přidává, tedy přesně ta chyba, o které je celý tenhle case.

## Co na tom pořád není dořešené

Sken přístupových údajů nevidí klientskou identitu ani identifikátory naší znalostní
vrstvy. Je to brzda, ne důkaz, a v tomhle případě zafungovala ruční kontrola dosahu, ne
stroj. Automatická kontrola pro třídu „identifikátor mířící do našeho prostředí v souboru,
který drží někdo jiný" dnes neexistuje. Zůstává tedy pravidlo, že takový soubor prochází
rukama před každým nasazením.

## Kde si to v tomhle balíčku ověříš

- `operations/changesets/README.md`, sekce o dodatcích k vydaným lístkům: je tam popsané,
  jak přechodem na seznam povoleného zanikl důvod jednoho už rozeslaného pokynu.
- `scaffold/tools/sken-secretu.sh` - co ten sken hledá, a tedy i co nehledá.
- [`docs/hranice-baliku.md`](../hranice-baliku.md), bod 5: distribuční mechanismus ani
  konfigurace konkrétního nasazení v balíčku nejsou, takže tenhle case si nepřehraješ.
  Zůstává z něj pravidlo a jeho stopa jinde.
