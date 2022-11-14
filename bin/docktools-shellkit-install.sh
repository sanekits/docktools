#!/bin/bash
# docktools-shellkit-install.sh
#

do_help() {
    cat <<-EOF
$(basename ${scriptName})
Installs multple shellkits in one pass, using the "-k kitname,..." syntax similar to dockershell.sh.  However we expect to run inside a container or container-simulation.

We expect that all the kits in the -k list are pre-installed within a list of colon-delimited dirs, which is established in this order:

    1.  -p|--installer-path DD1:DD2:...
    2.  SHELLKIT_INSTALLER_PATH=DD1:DD2:...

For --installer-path|-p, only the first kit found in the dir list will be installed.  Also, the command-line spec of paths will take precedence over the environment list.

EOF

}


scriptName="$(readlink -f "$0")"
scriptDir=$(command dirname -- "${scriptName}")
PS4='\033[0;33m+(${BASH_SOURCE}:${LINENO}):\033[0m ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'


Kitlist=() # Use -k
InstallerDirs=() #  Use -d or SHELLKIT_INSTALLER_PATH

die() {
    builtin echo "ERROR($(basename ${scriptName})): $*" >&2
    builtin exit 1
}

stub() {
    # Print debug output to stderr.  Recommend to call like this:
    #   stub "${FUNCNAME[0]}.${LINENO}" "$@" "<Put your message here>"
    #
    [[ -n $NoStubs ]] && return
    [[ -n $__stub_counter ]] && (( __stub_counter++  )) || __stub_counter=1
    {
        builtin printf "  <=< STUB(%d:%s)" $__stub_counter "$(basename $scriptName)"
        builtin printf "[%s] " "$@"
        builtin printf " >=> \n"
    } >&2
}

main() {
    for kit in ${Kitlist[@]}; do
        for dir in ${InstallerDirs[@]}; do
            [[ -d ${dir}/${kit} ]] && {
                ${dir}/${kit}/setup.sh
                continue 2
            }
        done
    done
}

[[ -z ${sourceMe} ]] && {
    #stub $scriptName cmdline-args "$@"
    [[ -f /.dockerenv ]] || {
        grep -sq docker /proc/1/cgroup || {
            die "$scriptName expects to run in a docker container"
        }
    }
    [[ -n "$SHELLKIT_INSTALLER_PATH" ]] && {
        IFS=$':'; InstallerDirs+=( $SHELLKIT_INSTALLER_PATH ); unset IFS
    }
    origArgs=("$@")
    while [[ -n $1 ]]; do
        case $1 in
            -h|--help) shift; do_help "$@"; exit 1;;
            -k|--kits) IFS=$', '; Kitlist+=( $2 ); shift; unset IFS;;
            -p|--installer-path) IFS=$':'; InstallerDirs+=( $2 ); shift; unset IFS;;
            *) die unknown arg: $1;;
        esac
        shift
    done
    (( ${#Kitlist[@]} == 0 )) && {
        do_help; exit 1;
    }
    [[ ${#InstallerDirs[@]} -eq 0 ]] \
        && InstallerDirs=( /host_home/.local/bin )
    main
    builtin exit
}
command true
