#!/bin/bash
# validate-container-bootstrap.sh [container_name] [ -u user ]
# Check the state of the container for evidence of correct bootstrapping

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


do_test_container() {
    local container_name=$1
    local xuser=$2
    docker exec  -i -u $xuser  \
        -e CONTAINER_NAME=$container_name \
        -e XUSER=$xuser \
        $container_name \
        bash -l ./validate-shellstate.sh
}

main() {
    local container_name
    local xuser=0
    while [[ -n $1 ]]; do
        case $1 in
            -u) xuser=$2; shift ;;
            *) container_name=$1 ;;
        esac
        shift
    done

    do_test_container $container_name $xuser
}

[[ -z ${sourceMe} ]] && {
    main "$@"
    builtin exit
}
command true
