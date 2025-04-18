#!/bin/bash
# docktools.sh
#  This script can be removed if you don't need it -- and if you do
# that you should remove the entry from _symlinks_ and make-kit.mk also.


# The shellkit/ tooling naturally evolves out from under the dependent kits.  ShellkitSetupVers allows
# detecting the need for refresh of templates/* derived files.  To bump the root version, 
# zap all templates/* containing 'ShellkitTemplateVers' constants and changes to the corresponding dependent kits
# Note that within templates/* there may be diverse versions in upstream shellkit, they don't all have to match,
# but the derived copies should be sync'ed with upstream as needed.
#shellcheck disable=2034
ShellkitTemplateVers=2

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
    ( builtin cd -L -- "$(command dirname -- "$0")" || exit; builtin echo "$(command pwd -P)/$(command basename -- "$0")" )
}

scriptName="$(canonpath "$0")"
scriptDir=$(command dirname -- "${scriptName}")

die() {
    builtin echo "ERROR($(command basename -- "${scriptName}")): $*" >&2
    builtin exit 1
}

stub() {
   builtin echo "  <<< STUB[$*] >>> " >&2
}

do_help() {
    local ver=$(docktools-version.sh | awk '{print $2}')
    cat <<-EOF
docktools ${ver} help:
   dockershell.sh Start terminal on running container by picklist
        a.k.a. 'docksh'
   docktools-shellkit-install.sh: Install kits by name while inside container
        a.k.a 'dockins'
   docktools-init-user.sh:  Create user inside container
   docktools-bootstrap-container.sh: Install kits into container
   docker-make-container.sh: Create a container from a recipe
        a.k.a. 'dockmk'
   dk: alias for 'docker'
   dc: alias for 'docker-compose'
   dockstat: alias showing container stats
   docker-history: show container or image history without truncation or junk whitespace
   install-docker-dive.sh: Installs the docker-dive tool from github.com
   in-container.sh:  Succeeds if running in a Docker container
   getContainerId.sh:  Print container ID from inside the container
   wait-for-container-id.sh: Watch "docker ps" for expected container, print id
EOF
}

main() {
    [[ -n $1 ]] && {
        case $1 in
            -h|--help)
                do_help
                exit
                ;;
            *)
                die "Unknown arg: $1"
        esac
    }
    do_help
}

[[ -z ${sourceMe} ]] && {
    main "$@"
    exit
}
true
