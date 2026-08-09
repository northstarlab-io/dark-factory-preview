#!/usr/bin/env bash
#
# git-prostredi.sh - hranice repa a plocha commitu pro nástroje platformy
#
# Dvě věci, které se v nástrojích spouštěných z git hooku pokazí tiše, a proto mají
# jeden domov místo záplaty per volání:
#
#   1) ZDĚDĚNÉ PROSTŘEDÍ. Git exportuje do hooků proměnné, které ukazují do repa,
#      ve kterém hook běží. Dotaz do JINÉHO repa je pak lež, ne chyba - příkaz
#      projde a vrátí prázdný nebo cizí výsledek:
#
#        GIT_INDEX_FILE=<index METY> git -C <repo knihovny> ls-files agents/  -> 0 souborů
#        GIT_DIR=<.git METY>         git -C <repo knihovny> ls-files agents/  -> 0 souborů
#        (bez nich)                  git -C <repo knihovny> ls-files agents/  -> soubory definic
#
#      Zákeřné je, že se to neprojeví vždycky. Při PLNÉM commitu je GIT_INDEX_FILE
#      relativní (".git/index"), takže se s "git -C <cizí repo>" rozbalí vůči cizímu
#      repu a náhodou vyjde správně. Při ČÁSTEČNÉM commitu ("git commit <cesty>")
#      je absolutní - míří na dočasný index METY - a dotaz do cizího repa vrátí nulu.
#      Nález z 6. 8. 2026: kontrola (2) hlásila všechny definice agentů jako
#      untracked a shodila bránu při každém částečném commitu.
#
#      Pravidlo: zděděné prostředí patří repu, ze kterého jsme byli spuštěni. Do
#      vlastního repa se ctí (je to jeho pravda o tom, co se právě commituje), do
#      cizího se zahazuje.
#
#   2) PLOCHA COMMITU. "git commit -- <cesty>" nekomituje pracovní strom ani stage:
#      git si postaví dočasný index HEAD + jmenované cesty a ten exportuje hookům.
#      Cizí staged i cizí rozpracované soubory v něm NEJSOU (ověřeno průchodem).
#      Kdo chce posuzovat to, co se commituje, musí měřit tuhle plochu - ne disk,
#      na kterém současně pracuje někdo jiný.
#
# Sourcovat, ne spouštět. Závislosti: git + POSIX shell (bash 3.2, macOS BSD nástroje).

# Proměnné, které přesměrují git do jiného repa, indexu nebo objektové databáze.
# Seznam je záměrně užší než "všechno GIT_*": GIT_AUTHOR_*, GIT_EDITOR ani GIT_EXEC_PATH
# hranici repa neporušují a zahazovat je by měnilo chování bez důvodu.
GIT_ZDEDENE_PROMENNE='GIT_INDEX_FILE GIT_DIR GIT_WORK_TREE GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_COMMON_DIR GIT_NAMESPACE GIT_PREFIX GIT_GRAFT_FILE GIT_SHALLOW_FILE GIT_CONFIG'

# Dotaz do CIZÍHO repa - bez zděděného prostředí.
# Použití: git_cizi <repo> <argumenty gitu...>
git_cizi() {
  gc_repo="$1"
  shift
  (
    for gc_var in $GIT_ZDEDENE_PROMENNE; do
      unset "$gc_var"
    done
    exec git -C "$gc_repo" "$@"
  )
}

# Dotaz do repa, který sám rozhodne, jestli je cizí. "." (nebo prázdno) = vlastní repo,
# kde se zděděné prostředí ctí; cokoli jiného projde přes git_cizi.
# Použití: git_v_repu <repo> <argumenty gitu...>
git_v_repu() {
  gvr_repo="${1:-.}"
  shift
  case "$gvr_repo" in
    ''|'.') git "$@" ;;
    *)      git_cizi "$gvr_repo" "$@" ;;
  esac
}

# Materializuje plochu commitu do adresáře.
#
# Bez cest: plochou je AKTUÁLNÍ INDEX. V hooku je to dočasný index, který si git
# postavil pro tenhle commit (tedy přesně to, co se commituje); mimo hook je to stage.
# S cestami: plochou je HEAD + jmenované cesty z pracovního stromu, tedy přesně to,
# co udělá "git commit -- <cesty>". Umí i smazání souboru.
#
# Použití: plocha_materializuj <repo> <cílový adresář> [cesty...]
# Návratový kód: 0 v pořádku, 1 nepodařilo se (volající rozhodne, co s tím).
plocha_materializuj() {
  pm_repo="${1:-.}"
  pm_cil="$2"
  shift 2
  [ -n "$pm_cil" ] || return 1
  # Cíl musí být absolutní: dole se mění pracovní adresář na kořen repa a relativní
  # --prefix by pak mířil jinam, než volající čeká.
  case "$pm_cil" in /*) : ;; *) pm_cil="$PWD/$pm_cil" ;; esac
  mkdir -p "$pm_cil" 2>/dev/null || return 1

  if [ "$#" -eq 0 ]; then
    # Zděděné prostředí se tady ctí schválně: GIT_INDEX_FILE JE ta plocha.
    ( cd "$pm_repo" 2>/dev/null || exit 1
      git checkout-index --prefix="$pm_cil/" -a -f >/dev/null 2>&1 ) || return 1
    return 0
  fi

  pm_idx="${pm_cil%/}.index"
  rm -f "$pm_idx"
  (
    cd "$pm_repo" 2>/dev/null || exit 1
    # Dočasný index se staví od nuly, takže tady zděděný GIT_INDEX_FILE naopak vadí.
    for pm_var in $GIT_ZDEDENE_PROMENNE; do
      unset "$pm_var"
    done
    GIT_INDEX_FILE="$pm_idx"
    export GIT_INDEX_FILE
    git read-tree HEAD >/dev/null 2>&1 || exit 1
    git add --all -- "$@" >/dev/null 2>&1 || exit 1
    git checkout-index --prefix="$pm_cil/" -a -f >/dev/null 2>&1 || exit 1
  ) || { rm -f "$pm_idx"; return 1; }
  rm -f "$pm_idx"
  return 0
}
