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

install_completion() {
    # Setup shell completion stuff
    HISTFILE= bash -ic 'complete'  2>/dev/null | awk '/docker$/ {print $NF}' | grep -q docker
    if [[ $? -ne 0 ]]; then
        # We don't already have completion setup for this.  We do bundle the upstream
        # completion script though:
        mkdir -p ~/.bash_completion.d
        cd ~/.bash_completion.d && {
            local cxloc=${HOME}/.local/bin/docktools/docker.bashrc
            ln -sf ${cxloc} ./docker || {
                echo "Failed to symlink from $PWD" >&2
                false; return;
            }
            echo "Shell completion for docker installed: OK"
        }
    else
        echo "docker completion is already installed."
    fi
}

main() {
    Script=${scriptName} main_base "$@"
    builtin cd ${HOME}/.local/bin || die 208

    install_completion
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
