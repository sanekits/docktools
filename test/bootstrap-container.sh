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
    [[ -n $1 ]] || die Expected container name as \$1
    local container_name=$1
    dcexec() {
        docker exec $container_name "$@" | sed 's|^|  >>> |'
    }
    dccopy() {
        docker cp "$1" "$container_name":/tmp/$2
    }
    dcexec mkdir -p /tmp/shellkit-boot || die "Failed creating /tmp/shellkit-boot in container $container_name"
    for kit in $(kit_list); do
        dccopy ~/.local/bin/$kit $kit || die "Failed copying $kit to container:/tmp"
        dcexec bash -c /tmp/${kit}/setup.sh || die "Failed setup for kit $kit"
    done
}

[[ -z ${sourceMe} ]] && {
    main "$@"
    builtin exit
}
command true
