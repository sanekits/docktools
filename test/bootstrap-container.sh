#!/bin/bash
# bootstrap-container.sh

scriptName="$(readlink -f "$0")"
scriptDir=$(command dirname -- "${scriptName}")

die() {
    builtin echo "ERROR($(basename ${scriptName})): $*" >&2
    builtin exit 1
}

stub() {
   builtin echo "  <<< STUB[$*] >>> " >&2
}

kit_list() {
    echo "cdpp ps1-foo "
}

main() {
    while [[ -n $1 ]]; do
        case $1 in
            --container-name) CONTAINER_NAME=$2; shift ;;
            --user) XUSER=$2; shift ;;
        esac
        shift
    done
    [[ -n $CONTAINER_NAME ]] && [[ -n $XUSER ]] || die "Expected --container-name and --user args"

    dcexec() {
        docker exec -u $XUSER $CONTAINER_NAME "$@" | sed 's|^|  >>> |'
        [[ ${PIPESTATUS[0]} -eq 0 ]] || die "dcexec failed [$@] (user=$XUSER)"
    }
    dccopy() {
        docker cp "$1" "$CONTAINER_NAME":/tmp/$2
    }
    dcexec mkdir -p /tmp/shellkit-boot || die "Failed creating /tmp/shellkit-boot in container $container_name"
    for kit in $(kit_list); do
        XUSER=0 dccopy ~/.local/bin/$kit $kit || die "Failed copying $kit to container:/tmp"
        dcexec bash -c /tmp/${kit}/setup.sh || die "Failed setup for kit $kit"
    done
    echo bootstrap complete for $CONTAINER_NAME / $XUSER
}

[[ -z ${sourceMe} ]] && {
    main "$@"
    builtin exit
}
command true
