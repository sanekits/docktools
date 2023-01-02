#!/bin/bash
# docker-make-container.sh

scriptName="$(readlink -f "$0")"
scriptDir=$(command dirname -- "${scriptName}")
PS4='\033[0;33m+$?(${BASH_SOURCE}:${LINENO}):\033[0m ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

RecipeCfg=${HOME}/.local/etc/docker-make-container.conf
RecipeRoot=${RecipeCfg}.d

die() {
    builtin echo "ERROR($(basename ${scriptName})): $*" >&2
    builtin exit 1
}

list_recipes() {
    [[ -d $RecipeRoot ]] \
        || die "RecipeRoot [$RecipeRoot] not found"
    (
        cd $RecipeRoot
        command ls *-recipe.mk | sed 's/-recipe.mk//'
    )
}

main() {
    local recipe yesmode
    while [[ -n $1 ]]; do
        case $1 in
            --list-recipes) list_recipes; exit ;;
        esac
        shift
    done
}

[[ -z ${sourceMe} ]] && {
    stub "${FUNCNAME[0]}.${LINENO}" "calling main()" "$@"
    main "$@"
    builtin exit
}
command true
