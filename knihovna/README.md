# knihovna

Platformní knihovna: to, co si session načítá. `agents/` jsou definice rolí, `foundation/`
metodické soubory, na které definice odkazují, `skills/` workflow postupy volané v turnu.

**Definice role není prompt, je to kontrakt.** Popisuje doménu, hranice vůči sousedním
rolím, železná pravidla s doloženými incidenty a kritéria kvality výstupu. Většina textu
neřeší, co má role dělat, ale kde přestává a komu to předává.

**Proč jsou tu jen některé.** Je to výběr definic, ne celý stack, a dělící čára je hranice,
ne rozpracovanost: role, které obsluhují klientský obsah a provozní model firmy, ven
nejdou. Ven jde tolik, aby se z toho dal zrekonstruovat mechanismus - jak role vzniká,
jak se udržuje a jak se hlídá hranice mezi rolemi.

**Proč je to snímek.** Kanonický domov těch souborů je jinde a mění se jen schváleným
postupem, ve kterém agent svou vlastní definici needituje. Kopie tady se zpět
nesynchronizuje a od uvedeného data zastarává.

**Jak si to zkusit u sebe.** Zkopíruj soubor do `.claude/agents/` nebo `.claude/skills/`
svého projektu. Nic se neaktivuje samo, je to tvůj krok. Pole `model` nese alias platný
v našem prostředí; ve svém si ho přepiš na alias, který máš. Pole `tools` u některých
definic jmenuje i konektory, které máme připojené my - co nemáš, škrtni, zbytek funguje.

Odkazy na dokumenty, které v balíčku nejsou, jsou ponechané schválně - ukazují, kde ten
fakt bydlí.
