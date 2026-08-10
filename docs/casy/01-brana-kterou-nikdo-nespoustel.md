# Brána, kterou nikdo nespouštěl

**Kdy:** 6. srpna 2026
**Kde:** vlastní platforma
**Třída vady:** kontrola, která existuje, ale nic ji nespouští

## Co se stalo

Platforma má validátor, který měří vlastní invarianty: shodu odvozeného katalogu rolí
s knihovnou definic, tvar frontmatteru, číslování výstupů, hlavičky, jeden domov verze,
pokrytí commitů changesetem. Skript existoval několik týdnů a spouštěl se rukou, když si
na něj někdo vzpomněl. Šestého srpna ho někdo pustil a on hlásil dva FAILy. Nebyly nové.
Bylo to jen poprvé, co je někdo viděl.

## Jak se to projevilo

Nijak, a to je na tom to podstatné. Chyby byly celou dobu detekovatelné, kontrola na ně
mířila správně a výstup byl červený. Jenom mezi kontrolou a člověkem nebyla žádná
událost. Nedá se ani dopočítat, jak dlouho ten stav trval: první červený běh není v žádné
evidenci, protože běhy nikdo neevidoval.

## Co to stálo

Neznámý počet commitů proti kontrole, o které si všichni mysleli, že platí. Přesnou cenu
neumíme vyčíslit a je to samo o sobě nález: kontrola bez spouštěče nemá ani historii, ze
které by se cena dala spočítat.

## Co se z toho stalo za pravidlo

Věta „brána, kterou nikdo nespouští, není brána" a dva verzované git hooky:

- `pre-commit` spustí validátor a jeho FAIL zastaví commit,
- `commit-msg` vyžaduje u commitu s dosahem mimo platformu trailer s číslem changesetu.

Dva místo jednoho, protože `pre-commit` běží dřív, než zpráva commitu vůbec existuje -
chybějící trailer tedy z principu nevidí.

Tři vlastnosti, které z toho plynou a jsou vědomé:

- **Hooky jsou verzované soubory v repu**, ne obsah `.git/hooks/`. Změna hooku je normální
  diff a nese changeset jako každý jiný soubor enginu. Netrackovaný hook by se spouštěl
  při každém commitu, nešel by diffnout a o jeho degradaci by se nikdo nedozvěděl.
- **Aktivaci provádí člověk, ne agent.** Jednorázově a per klon jedním příkazem, zpět
  týmž příkazem s přepínačem. Agent hook napsat smí, zapnout ho na stroji ne: vykonávaná
  konfigurace, která se aktivuje sama, je nerozlišitelná od driftu.
- **Brána vykoná jen to, co je verzované v gitu.** Před spuštěním validátoru i před každým
  načtením sdílené funkce relativní cestou se ověří, že soubor je v gitu. Bez toho by
  položení souboru do pracovního stromu stačilo k tomu, aby se při příštím commitu spustil
  cizí kód.

## Co se pokazilo hned první den

Brána v prvním provedení posuzovala pracovní strom, ne plochu commitu. Ještě týž den
zablokovala dva nezávislé commity kvůli rozpracovanému souboru, kterého se ani jeden
netýkal. Oprava je přepínač, kterým hook říká validátoru, ať měří obsah commitu a ne to,
co má autor rozdělané. Zaznamenané je to v komentáři přímo v hooku, ne v retrospektivě.

## Totéž o tři dny později, jinou třídou

Každý changeset nese blok s ověřovacími testy. Třikrát ve třech dnech vznikl blok, který
nemohl projít nikdy: nezaescapované závorky ve vzoru (7. 8.), sloveso, které jazyk nezná
(8. 8.), a hledaná formulace, kterou mezitím přejmenovala jiná změna (9. 8.). Jazyk je
fail-closed, takže nic tiše neprošlo jako splněné. Autor se to ale dozvěděl až ve chvíli,
kdy někdo test pustil proti reálné jednotce, a ve třetím případě to část jednotek drželo ve
falešném stavu regrese, přestože knihovna byla v pořádku.

Devátého srpna se kontrola posunula do okamžiku commitu: tvar každého řádku se ověřuje
proti deklarovanému výčtu vrstev a sloves a testy mířící do knihovny se rovnou zkusí
vyhodnotit. Výčet je jeden a je deklarovaný v kódu, takže brána nemá vlastní opsaný
seznam, který by se s implementací rozešel.

## Jak se to hlídá dnes

Hooky spouští bránu při každém commitu na stroji, kde jsou zapnuté. Úniková cesta
`--no-verify` zůstává a obejití není tiché - commit bez pokrytí chytne zpětná kontrola
při příštím běhu. Commit, jehož historie se přepisovat nebude, se pokrývá jmenovitou
evidovanou výjimkou v jednom souboru. Posun kotvy se nepoužívá: každý posun promine celý
rozsah před sebou, takže po druhém už není co počítat. Ten vzorec se během tří dnů objevil
dvakrát a tohle je odpověď na něj.

## Co na tom pořád není dořešené

Aktivace je ruční a per klon. Kdo si hooky nezapne, bránu nemá a nikdo se to nedozví.
Server, který by kontroly pustil za člověka, neběží; testy se pouštějí rukou před
commitem. Doba běhu se sleduje - poslední přidaná kontrola prodloužila běh o necelé dvě
vteřiny z necelých dvaceti - protože brána, kterou se vyplatí obejít kvůli délce, je horší
než žádná.

## Kde si to v tomhle balíčku ověříš

- `scaffold/hooks/pre-commit` a `scaffold/hooks/commit-msg` - včetně komentářů, proč jsou
  dva, co se stalo první den a co znamená „vykonej jen to, co je v gitu".
- `operations/changesets/2026-08-06-index-platformy-a-automaticke-brany.md`
- `operations/changesets/2026-08-09-brana-verify-bloku-a-kontrakt-radku.md`
- [`docs/normy.md`](../normy.md), OR-12 a doplněk OR-09 o vykonávané konfiguraci.
