#!/bin/bash
# docker-make-container.sh

scriptName="$(readlink -f "$0")"
scriptDir=$(command dirname -- "${scriptName}")
PS4='\033[0;33m+$?(${BASH_SOURCE}:${LINENO}):\033[0m ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

Kitname=$(cat ${scriptDir}/Kitname)
KitRoot=${HOME}/.local/bin/${Kitname}
RecipeRoot=${HOME}/.local/etc/docker-make-container.d
RecipeCfg=${RecipeRoot}/config
OrigTemplate=${KitRoot}/template-recipe.mk
BaseMakefile=${KitRoot}/docker-make-container.mk

RunCommand=

die() {
    builtin echo "ERROR($(basename ${scriptName})): $*" >&2
    builtin exit 1
}

recipe_exists() {
    # Check each name for existence, return true if they're all found
    [[ $# -eq 0 ]] \
        && { false; return; }
    for name; do
        [[ -f "${RecipeRoot}/${name}-recipe.mk" ]] \
            || { false; return; }
    done
    true
}

get_recipe_path() {
    recipe_exists "$1" \
        || die "No recipe name passed to get_recipe_path"
    local name="$1"
    echo "${RecipeRoot}/${name}-recipe.mk"
}



list_recipes() {
    [[ -d $RecipeRoot ]] \
        || die "RecipeRoot [$RecipeRoot] not found"
    (
        cd $RecipeRoot
        command ls *-recipe.mk | sed 's/-recipe.mk//'
    )
}

make_recipe() {
    [[ "$1" =~ ^[a-z]+[-_a-z0-9]* ]] \
        || die "No recipe-name provided"
    local name="$1"
    local tgtfile="${RecipeRoot}/${name}-recipe.mk"
    [[ -f $tgtfile ]] \
        && die "Recipe \'${name}\' already exists [$tgtfile]"
    command cp ${OrigTemplate} ${tgtfile} \
        || die "Failed copying ${OrigTemplate} to ${tgtfile}"
    echo "Created ${tgtfile} OK"
    true
}

edit_recipe() {
    recipe_exists "$1" \
        die "Can't find recipe $1"
    $EDITOR "$(get_recipe_path $1)"
}

do_help() {
    [[ $# -eq 0 ]] && {
        echo "do '--help [recipe-name]' to see help details for a recipe"; return;
    }
    local recipe="$1"; shift

    recipe_exists "$recipe" \
        || die "No such recipe [$recipe].  Try --list-recipes"
    local recipe_path=$(get_recipe_path $recipe)
    make \
        -f ${KitRoot}/docker-make-container.mk \
        -f "${recipe_path}" \
        help \
        RecipeName=${recipe} \
        "$@"
}

run_recipe() {
    [[ $# -eq 0 ]] && {
        echo "ERROR: no recipe." >&1; exit 1
    }
    local recipe="$1"; shift

    recipe_exists "$recipe" \
        || die "No such recipe [$recipe].  Try --list-recipes"

    local recipe_path=$(get_recipe_path $recipe)
    local cmd=( make \
        -f ${KitRoot}/docker-make-container.mk \
        -f ${recipe_path}  \
        )
    [[ -n $RunCommand ]] \
        && cmd+=( RunCommand="\"echo hello\""  )

    [[ $# -gt 0 ]] \
        && cmd+=( "$@" )

    cmd+=( container )

    echo "${cmd[@]}"
    set -x
    ${cmd[@]}
    set +x
}

main() {
    local recipe yesmode
    while [[ -n $1 ]]; do
        set -x
        case "$1" in
            -c|--command) shift; RunCommand="$1" ;;
            --list-recipes) shift; list_recipes "$@"; exit ;;
            --recipe-root) echo $RecipeRoot; exit;;
            --recipe-path) shift; get_recipe_path "$@"; exit ;;
            --make-recipe) shift; make_recipe "$@"; exit ;;
            --edit-recipe) shift; edit_recipe "$@"; exit ;;
            -h|--help) shift;  do_help "$@"; exit ;;
            -*)  die "Unknown option: $1" ;;
            *)
                recipe_exists "$1" \
                    || die "Unknown recipe name: $1 ( try --list-recipes )"
                recipe="$1"
                ;;
        esac
        set +x
        shift
    done
    [[ -n $recipe ]] \
        || die "No recipe specified"
    run_recipe $recipe
}

[[ -z ${sourceMe} ]] && {
    main "$@"
    builtin exit
}
command true
