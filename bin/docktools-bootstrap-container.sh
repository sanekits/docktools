#!/bin/bash
# docktools-bootstrap-container.sh
# Given a container name, optional user ID, and a list of kits (from ~/.local/bin), this
# script installs them in the container for that user.
#  User must exist first if not root (see docktools-init-user.sh to create user)


scriptName="$(readlink -f "$0")"
scriptDir=$(command dirname -- "${scriptName}")
PS4='\033[0;33m+(${BASH_SOURCE}:${LINENO}):\033[0m ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

die() {
    builtin echo "ERROR($(basename ${scriptName})): $*" >&2
    builtin exit 1
}

stub() {
   builtin echo "  <<< STUB[$*] >>> " >&2
}


main() {
    local kitlist=()
    while [[ -n $1 ]]; do
        case $1 in
            --container-name) CONTAINER_NAME=$2; shift ;;
            --user) XUSER=$2; shift ;;
            *) kitlist+=($1) ;;
        esac
        shift
    done
    [[ -n $XUSER ]] || XUSER=0
    [[ -n $CONTAINER_NAME ]] || die "Expected --container-name arg and one or more kit names"

    dcexec() {
        docker exec -u $XUSER $CONTAINER_NAME "$@" | sed 's|^|  >>> |'
        [[ ${PIPESTATUS[0]} -eq 0 ]] || die "dcexec failed [$@] (user=$XUSER)"
    }
    dccopy() {
        docker exec -u root $CONTAINER_NAME bash -c "rm -rf $(dirname $2)/* &>/dev/null"
        docker exec -u root $CONTAINER_NAME mkdir -p $(dirname $2)
        docker cp "$1" "$CONTAINER_NAME":$2
    }
    for kit in ${kitlist[@]}; do
        XUSER=0 dccopy ~/.local/bin/$kit /tmp/user-${XUSER}/$kit || die "Failed copying $kit to container"
        dcexec bash -c /tmp/user-${XUSER}/${kit}/setup.sh || die "Failed setup for kit $kit"
    done
}

[[ -z ${sourceMe} ]] && {
    main "$@"
    builtin exit
}
command true
