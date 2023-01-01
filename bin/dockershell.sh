#!/bin/bash
# dockershell.sh -- open a shell or run shell command on a docker container.
# suggest alias 'docksh'


scriptName="$(readlink -f "$0")"
[[ -z $sourceMe ]] && scriptDir=$(command dirname -- "${scriptName}") \
    || scriptDir=$PWD;
Script="docksh"

source ${scriptDir}/_common_


usage() {
    cat <<-EOF
$Script usage:
    \$ $Script
        # Pick container and user then run shell
    \$ $Script my-container
        # Run as root in my-container
    \$ $Script my-container -u vscode -k ps1-foo cdpp
        # Run as vscode in my-container and install 2 kits
    \$ $Script -i 1000
        # Pick container then run as user 1000
EOF
}

parseArgs() {
    local container=
    local user=
    local user_id=
    local kits=()
    while [[ -n $1 ]]; do
        case $1 in
            -u|--user) user=$2; shift ;;
            -i|--uid) user_id=$2; shift ;;
            -k|--kits) shift; kits+=( $(printf "%s," "$@") ); break 2;;
            *) container=$1 ;;
        esac
        shift
    done
    printf "%s:" "$container" "$user" "$user_id" "${kits[@]}"
}

prepare_context() {
    # Before launching (and possibly initializing) a shell, we
    # want to identify the container name, target user, kit list,
    # and possibly user_id.  Some things the user might provide
    # on the command line, and some we might prompt, and some
    # we'll infer
    local container="$1"; shift
    local user="$1"; shift
    local user_id="$1"; shift
    local kits=( "$@" )

    if [[ -z $container ]]; then
        if [[ -z $user && -z $user_id ]]; then
            # We don't know the user:
            IFS=':' ; read container user user_id < <(_pick_container_and_user) ; unset IFS
        else
            container=$(_pick_container);
        fi
    fi
    # Result format is container:user:user_id:kit1,kit2,kit3
    printf "%s:" "$container" "$user" "$user_id" $(printf "%s," "${kits[@]}")
}



if [[ -z $sourceMe ]]; then
    #echo "args" "$@"
    case $1 in
        -h|--help) usage; exit 1;;
        --show-users-in-container) shift; show_users_in_container "$1"; exit;;
    esac
    IFS=':' ; read container user user_id kits < <(parseArgs "$@"); unset IFS
    #echo "kits=${kits[@]}"

    IFS=':' ; read container user user_id kits < <(prepare_context "$container" "$user" "$user_id" "$kits"); unset IFS

    [[ -n $container ]] || exit 1

    kits=${kits//,/ }  # Remove commas

    [[ -n "$kits" ]] && {
        _install_container_kits "$container" "$user" "$user_id" "$kits"
    }
    [[ -n "$user_id" ]] && \
        user="$user_id"
    _dk_launch_shell "$container" "$user"
fi

