#!/bin/bash
# dockershell.sh -- open a shell or run shell command on a docker container.
# suggest alias 'docksh'


scriptName="$(readlink -f "$0")"
scriptDir=$(command dirname -- "${scriptName}")
Script="docksh"

PS4='\033[0;33m+(${BASH_SOURCE}:${LINENO}):\033[0m ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

die() {
    echo "ERROR: $@" >&1
    exit 1
}

stub() {
    # Print debug output to stderr.  Call like this:
    #   stub "${FUNCNAME[0]}.${LINENO}" "$@" "<Put your message here>"
    #
    [[ -n $NoStubs ]] && return
    builtin printf "  <<< STUB" >&2
    builtin printf "[%s] " "$@" >&2
    builtin printf " >>>\n" >&2
}

usage() {
    cat <<-EOF
$Script
    > Present a list of containers+users, open a shell
$Script my-container
    > Open shell in my-container as root
$Script my-container -u vscode -k ps1-foo,cdpp
    > Init the shell with list of kits and selected user
$Script -i 1000
    > Present list of containers, open shell with uid 1000
EOF
}

show_containers() {
    docker ps --format "{{.Names}}"
}

show_users_in_container() {
    local container="$1"
    local users=(root)
    local user
    dcex() {
        docker exec -i "$container" "$@"
    }
    unset IFS
    local xul=$(dcex ls /home )
    for user in $(dcex ls /home); do
        users+=($user)
    done
    for user in ${users[@]}; do
        local xuid=$(dcex id -u "$user")
        printf "%s:"   "${container}" "${user}" "$xuid"
        printf "\n"
    done
}

pick_container() {
    # Present a list of containers.  Interactively select
    # an entry.
    #
    #  Prints [container-name]
    #
    PS3="Choose container or Ctrl+C to quit:"
    unset IFS; select result in $( docker ps --format "{{.Names}}" ); do
        echo "$result"
        return
    done
}

pick_container_and_user() {
    # Present a list of containers and their available users (users
    # are identified by scanning /home dirs).  Interactively select
    # an entry.
    #
    # Prints [container-name] [user-name] [uid]
    #
    local entries=()
    unset IFS; for cc in $( docker ps --format "{{.Names}}" ); do
        for xu in $(show_users_in_container "$cc"); do
            entries+=( $xu )
        done
    done
    [[ ${#entries} -eq 0 ]] && {
        echo "No docker containers are running" >&2
        false; return
    }
    PS3="Choose container+user or Ctrl+C to quit: "
    select entry in ${entries[@]} ; do
        echo $entry
        return
    done
}

parseArgs() {
    local container=
    local user=
    local user_id=
    local kits=
    while [[ -n $1 ]]; do
        case $1 in
            -u|--user) user=$2; shift ;;
            -i|--uid) user_id=$2; shift ;;
            -k|--kits) kits="$2"; shift ;;
            *) container=$1 ;;
        esac
        shift
    done
    set +x
    printf "%s:" "$container" "$user" "$user_id" "$kits"
}

prepare_context() {
    # Before launching (and possibly initializing) a shell, we
    # want to identify the container name, target user, kit list,
    # and possibly user_id.  Some things the user might provide
    # on the command line, and some we might prompt, and some
    # we'll infer
    local container=$1
    local user=$2
    local user_id=$3
    local kits=$4

    [[ -n $container ]] || {
        [[ -n $user || -n $user_id ]] && {
            container=$(pick_container)
        } || {
            read container user user_id < <(pick_container_and_user)
        }
    }
    printf "%s:" "$container" "$user" "$user_id" "$kits"
}

install_container_kits() {
    # Install given kits into container as given user.   If
    # both 'user_id' and 'user' are provided, the former takes precedence.
    # Fails if user is not root and chosen user doesn't exist.
    local container=$1
    local user=$2
    local user_id=$3
    local kits=$4
    local u_kits
    IFS=$', '; u_kits=$(echo $kits); unset IFS
    local xuser=$user
    [[ -n $user_id ]] && xuser=$user_id

    docktools-bootstrap-container.sh  \
        --container-name $container \
        --user $xuser \
        $u_kits

}

launch_shell() {
    # Given a container and user, open a shell for that user in the container.
    local container=$1
    local user=$2
    local user_id=$3
    local xuser=$user
    [[ -n $user_id ]] && xuser=$user_id
    docker exec -it -u "$xuser" "$container" bash -l
}

if [[ -z $sourceMe ]]; then
    case $1 in
        -h|--help) usage; exit 1;;
    esac
    IFS=':' ; read container user user_id kits < <(parseArgs "$@"); unset IFS

    IFS=':' ; read container user user_id kits < <(prepare_context "$container" "$user" "$user_id" "$kits"); unset IFS

    [[ -n $kits ]] && {
        install_container_kits "$container" "$user" "$user_id" "$kits"
    }
    launch_shell "$container" "$user" "$user_id"
fi

