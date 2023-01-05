#!/bin/bash
# docktools-init-user.sh
#  Given a user ID, this script creates the user account
# in the container if it doesn't already exist.
# No customization of user environment is performed.
#  e.g. `cat docktools-init-user.sh | docker exec -i my-container bash -s -- --user 1000`

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

create_user() {
    local xuid=$1
    [[ $xuid -eq 0 ]] && die "Can't create root user"
    local username=vscode
    [[ $xuid -ne 1000 ]] && {
        username="user$xuid"
    }
    useradd -u $xuid -m $username 2>/dev/null || die "Failed creating user $xuid $username"
    [[ $(id -u -n $xuid) -eq $username ]] || die "User name fails to match after useradd for $username:$xuid"
    [[ $(id -u $username) -eq $xuid ]] || die "User id fails to match after useradd for $username:$xuid"
    echo "User added: $username:$xuid"
}

main() {
    while [[ -n $1 ]]; do
        case $1 in
            --user) XUSER=$2; shift ;;
        esac
        shift
    done
    [[ -n $XUSER ]] || die "Expected --user arg"
    id $XUSER || create_user $XUSER
    grep "/home/$XUSER" /etc/passwd | awk -F ':' '{print  $1 " " $3}'
}

[[ -z ${sourceMe} ]] && {
    main "$@"
    builtin exit
}
command true

