# scaffold

Engine platformy. Skripty, šablona jednotky a brány, které v provozu drží pravidla
místo dobré vůle. Nic z toho není ukázka postavená kvůli téhle prohlídce - jsou to
soubory, které se spouští při běžné práci a při každém commitu.

Co tu najdeš:

- `validate.sh` - validátor jednotky (kontroluje strukturu a hlavičku `operations/status.md`)
  a druhý režim `--baseline`, který spočítá frontu nepřevzatých changesetů. Spusť
  `bash scaffold/validate.sh ukazka-jednotky`.
- `validate-platform.sh` - validátor platformy. V balíčku **neběží**, měřit nemá nad čím;
  `--help` ale funguje a vypíše kontrakt kontrol generovaný z hlavičky vlastního skriptu.
- `lib/` - sdílené funkce (parser changesetů, hranice repa a plocha commitu, policy, seam).
- `hooks/` - `pre-commit` a `commit-msg`. V balíčku jsou **ke čtení**, samy se neaktivují.
- `tools/sken-secretu.sh` - sken vzorů přístupových údajů. Běží nad libovolnou cestou.
- `tests/` - dva testy, které v balíčku končí zeleně.
- `studio-template/` - kostra nové jednotky. Zkopíruj adresář a máš jednotku, která
  projde validací; `ukazka-jednotky/` v kořeni je přesně výsledek takového zkopírování.

**Proč se cesty nepřejmenovávají.** `scaffold/` a `operations/changesets/` nejsou popisky,
jsou to cesty v kontraktu. `validate.sh` odvozuje kořen repa řezem umístění vlastního
skriptu a frontu changesetů hledá jako `<kořen>/operations/changesets/`. Přejmenovat je
by znamenalo sáhnout do enginu a udělat z balíčku fork, který příště nejde srovnat diffem
proti zdroji. Cena za zachování je tenhle odstavec.

**Co tu vědomě není:** instalátor bran, generátor indexu platformy, render tenantů,
vrstva pracovního prostoru a zbytek testové sady. Důvody per položku jsou v
`docs/hranice-baliku.md`; pravidlo je jednoduché - v balíčku je jen to, co v něm běží
zeleně, zbytek se popíše.
