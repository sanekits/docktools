#!/bin/bash
# docktools.sh
#  This script can be removed if you don't need it -- and if you do
# that you should remove the entry from _symlinks_ and make-kit.mk also.

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

scriptName="$(canonpath "$0")"
scriptDir=$(command dirname -- "${scriptName}")

die() {
    builtin echo "ERROR($(command basename -- ${scriptName})): $*" >&2
    builtin exit 1
}

stub() {
   builtin echo "  <<< STUB[$*] >>> " >&2
}

do_help() {
    local ver=$(docktools-version.sh | awk '{print $2}')
    cat <<-EOF
docktools ${ver} help:
   docksh:  Start terminal on running container by picklist
   docktools-shellkit-install.sh: Install kits by name while inside container
        a.k.a 'dockins', e.g. 'dockins -k cdpp,localhist'
   docktools-init-user.sh:  Create user inside container
   docktools-bootstrap-container.sh: Install kits into container
   dk: alias for 'docker'
   dc: alias for 'docker-compose'
   dockstat: alias showing container stats
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
