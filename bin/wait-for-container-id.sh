#!/bin/bash
# wait-for-container-id.sh
# Run this after container start: we will poll for the container startup
# and print the id when it happens

do_help() {
    cat <<-EOF
$(basename ${scriptName}) help:

    --match-pattern <regex>:
    -m <regex>:
        Pattern to match against output of "docker ps" to identify container

    --timeout <seconds>:
    -t <seconds>:
        Number of seconds to wait (default=60)

EOF
}

scriptName="$(readlink -f "$0")"
scriptDir=$(command dirname -- "${scriptName}")
PS4='+$?(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

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

do_wait_for_container_id() {
    local matchPattern="$1";
    local timeout="$2"
    while true; do
        docker ps | grep -qE "$matchPattern" || {
            (( timeout-- ))
            if (( timeout >  0 )); then
                sleep 1
                continue
            fi
            die "Timeout waiting for pattern \"$matchPattern\" in docker ps output"
        }
        break
    done
    docker ps | grep -E "$matchPattern" | awk '{print $1}'
}

[[ -z ${sourceMe} ]] && {
    MatchPattern=""
    Timeout=60
    while [[ -n $1 ]]; do
        case "$1" in
            -m|--match-pattern)
                # This is what we'll pass to grep for "docker ps" output.  When
                # the pattern matches, the container ID is extracted
                shift; MatchPattern="$1"
                ;;
            -t|--timeout)
                shift; Timeout="$1"
                ;;
            -h|--help)
                do_help; exit;;
            *) die "Unknown arg: $@" ;;
        esac
        shift
    done
    [[ -n $MatchPattern ]] \
        || die "Expected --match-pattern (-m) [arg]"
    do_wait_for_container_id "$MatchPattern" "$Timeout"
    builtin exit
}
command true
