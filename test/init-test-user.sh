#!/bin/bash
# init-test-user.sh
#

scriptName="$(readlink -f "$0")"
scriptDir=$(command dirname -- "${scriptName}")

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
    useradd -u $xuid $username 2>/dev/null || die "Failed creating user $xuid $username"
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
    local already_users=$( cd /home && ls )
    #stub "already_users" $already_users
    id $XUSER || create_user $XUSER
    grep "/home/$XUSER" /etc/passwd | awk -F ':' '{print  $1 " " $3}'
}

[[ -z ${sourceMe} ]] && {
    main "$@"
    builtin exit
}
command true

