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
    local username=vscode
    [[ $xuid == 1000 ]] || {
        username="user$xuid"
    }
    useradd -u $xuid $username || die "Failed creating user $xuid $username"
}

main() {
    local host_uids=( $*)
    [[ -n ${host_uids[@]} ]] || die "Expected host_uids as \$1..\$N"
    local already_users=$( cd /home && ls )
    stub "already_users" $already_users
    for host_uid in ${host_uids[@]}; do
        id $host_uid || create_user $host_uid
        local uk=$( grep "/home/$user" /etc/passwd | awk -F ':' '{print  $1 " " $3}' )
        echo "[$uk]"
    done
}

[[ -z ${sourceMe} ]] && {
    main "$@"
    builtin exit
}
command true


#comment_out() {
    # vscode_uid=$(sed -n "s/^.*--uid \([0-9]*\).*$/\1/p" <<< "$*")
    # [[ -n $vscode_uid ]] || vscode_uid=1000


    # [[ -f /.dockerenv ]] || die "Not running in a Docker container"
    # [[ $UID -eq 0 ]] || die "We're expecting to run as root in a container during image build"


    # grep -Eq vscode /etc/passwd || {
    #     adduser --home /home/vscode --uid $vscode_uid vscode 2>/dev/null || die "Failed adding vscode user"
    #     usermod -aG wheel vscode
    #     echo '%vscode ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
    # }

    # [[ -d /home/vscode ]] || echo "WARNING: no vscode user home dir has been created" >&2

    # [[ -f /devcontainer/dotfiles/.bashrc ]] || die no .bashrc

    # [[ -d /devcontainer/dotfiles && -d /home/vscode ]] && {
    #     (
    #         cd /home/vscode
    #         for file in $(cd /devcontainer/dotfiles &>/dev/null; ( ls -a .[a-z]* ; ls * ) 2>/dev/null ); do
    #             su -c "cat /devcontainer/dotfiles/${file} >> ${file}" - vscode
    #         done
    #         su -c "ln -s /opt/bb/libexec/bde-gdb-printers/gdbinit .gdbinit" - vscode
    #         su -c "mkdir .cgdb && ln -s /devcontainer/dotfiles/cgdbrc .cgdb/" - vscode
    #     )
    # }


    # [[ -d /workspace ]] && {
    #     # We want all our workspace files to be owned by the vscode user
    #     chown vscode:vscode /workspace
    #     chmod g+s /workspace
    #     chmod u+x /workspace
    # }

    # cd /devcontainer/hello-world && {
    #     chown ${vscode_uid}:${vscode_uid} . -R
    #     ls -al .
    # }

#}
