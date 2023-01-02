#!/bin/bash
# setup.sh for docktools
#  This script is run from a temp dir after the self-install code has
# extracted the install files.   The default behavior is provided
# by the main_base() call, but after that you can add your own logic
# and installation steps.

canonpath() {
    builtin type -t realpath.sh &>/dev/null && {
        realpath.sh -f "$@"
        return
    }
    builtin type -t readlink &>/dev/null && {
        command readlink -f "$@"
        return
    }
    # Fallback: Ok for rough work only, does not handle some corner cases:
    ( builtin cd -L -- "$(command dirname -- $0)"; builtin echo "$(command pwd -P)/$(command basename -- $0)" )
}

stub() {
   builtin echo "  <<< STUB[$*] >>> " >&2
}
scriptName="$(canonpath  $0)"
scriptDir=$(command dirname -- "${scriptName}")

source ${scriptDir}/shellkit/setup-base.sh

die() {
    builtin echo "ERROR(setup.sh): $*" >&2
    builtin exit 1
}

setup_dockmk() {
    local recipeRoot="$($HOME/.local/bin/$Kitname/docker-make-container.sh --recipe-root)"
    mkdir -p "$recipeRoot"
    [[ -d "$recipeRoot" ]] \
        || die "Failed to create recipeRoot=$recipeRoot"
    cp ${scriptDir}/sample-recipe.mk "${recipeRoot}" \
        || die Failed creating sample recipe
}

main() {
    Script=${scriptName} main_base "$@"
    builtin cd ${HOME}/.local/bin || die 208

    # Fetch completion for docker-compose:
    mkdir -p ~/.bash_completion.d
    if which docker-compose &>/dev/null; then
        if !  bash -ic 'complete -p docker-compose' &>/dev/null ; then
            echo "Docker-compose is installed. Attempting to setup shell completion for it:" >&2
            local xurl="https://raw.githubusercontent.com/docker/compose/$(docker-compose version --short)/contrib/completion/bash/docker-compose"
            curl --connect-timeout 3 -I "$xurl" &>/dev/null && {
                curl -L https://raw.githubusercontent.com/docker/compose/$(docker-compose version --short)/contrib/completion/bash/docker-compose > ~/.bash_completion.d/docker-compose || echo "ERROR (non-fatal): failed installing shell completion for docker-compose" >&2
                echo "Shell completion for docker-compose installed: OK"
            } || {
                echo "ERROR (non-fatal): can't connect to download docker-compose completion from [ $xurl ]" >&2
            }
        else
            echo "docker-compose with completion is installed."
        fi
    else
        echo "ERROR (non-fatal): docker-compose not installed, so I can't setup shell completion for it."
    fi

    setup_dockmk

    # FINALIZE: perms on ~/.local/bin/<Kitname>.  We want others/group to be
    # able to traverse dirs and exec scripts, so that a source installation can
    # be replicated to a dest from the same file system (e.g. docker containers,
    # nfs-mounted home nets, etc)
    command chmod og+rX ${HOME}/.local/bin/${Kitname} -R
    command chmod og+rX ${HOME}/.local ${HOME}/.local/bin
    true
}

[[ -z ${sourceMe} ]] && {
    main "$@"
    builtin exit
}
command true
