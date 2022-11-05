#!/bin/bash
# validate-shellstate.sh
# Run this inside a container to sanity-check the shell configuration
#
# - Caller should set CONTAINER_NAME and XUSER first.

PS4='\033[0;33m+(${BASH_SOURCE}:${LINENO}):\033[0m ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

scriptName="$(readlink -f "$0")"
scriptDir=$(command dirname -- "${scriptName}")

die() {
    builtin echo "ERROR($(basename ${scriptName})): $*" >&2
    builtin exit 1
}

stub() {
   builtin echo "  <<< STUB[$*] >>> " >&2
}


__log() {
    echo "   INFO: $@" >&2
}
__errCount() {
    ls .vss-errs | wc -l
}

__add_err() {
    local cnt=$(( $(__errCount) + 1 ))
    echo "Error($cnt): $@" > .vss-errs/_${cnt}.err
}

group_1() {
    # Group 1 tests: basic checks
    _err() {
        __add_err "[group_1]" "$@"
    }
    (
        echo "$CONTAINER_NAME:group_1 tests --->"
        main_profile=~/.profile
        [[ -f ~/.bash_profile ]] && {
            [[ -f ~/.profile ]] && __add_err "Both .bash_profile and .profile exist"
            main_profile=~/.bash_profile
            source ~/.bash_profile
        }
        __log main_profile=~main_profile
        kuser="$(id -u -n):$(id -u)"
        [[ $(id -u ) -eq $XUSER ]] || {
            _err "User != $XUSER"
        }
        __log "User: $(id -u -n):$(id -u) vs. XUSER=$XUSER"
        __log $"PS1=[" $( bash -i -c 'echo "$PS1"' ) $"]"
        __log "PATH=$PATH"

        echo 'true' > ~/.local/bin/vss-sniff || __add_err "Can't write vss-sniff to ~/.local/bin/vss-sniff"
        chmod +x ~/.local/bin/vss-sniff || __add_err "Can't chmod vss-sniff +x"
        vss-sniff || __add_err "Failed executing vss-sniff: maybe ~/.local/bin is not on the PATH?"


    )
}

main() {
    echo
    echo
    echo "${scriptName} start: $CONTAINER_NAME / $XUSER"
    echo "============================================="

    mkdir -p .vss-errs;  rm -rf .vss-errs/* &>/dev/null

    group_1

    [[ $(__errCount) -eq 0 ]] && {
        __log "OK: No errors found in validate-shellstate.sh"
    } || {
        cat .vss-errs/*err
        echo " -- ^^ The following command produced the preceding errors:"
        echo "Command: ${scriptName} $@"
        echo " -- ^^ ...with Environment:"
        env | sed 's/^/     [env] /'
    }
}

[[ -z ${sourceMe} ]] && {
    main "$@"
    builtin exit
}
command true

