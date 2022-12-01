#!/bin/bash
# install-docker-dive.sh

scriptName="$(readlink -f "$0")"
scriptDir=$(command dirname -- "${scriptName}")
DockerDiveVersion=0.9.2

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
    cd /tmp
    url="https://github.com/wagoodman/dive/releases/download/v${DockerDiveVersion}/dive_${DockerDiveVersion}_linux_amd64.deb"
    curl -I "$url" --max-time 4 || die "Can't reach url: $url"
    wget "$url" || die "Download failed"
    sudo apt install ./dive_${DockerDiveVersion}_linux_amd64.deb || die "Install failed"
    echo "Dive install ok from $url"
    echo "Home page: https://github.com/wagoodman/dive"
}

[[ -z ${sourceMe} ]] && {
    stub "${FUNCNAME[0]}.${LINENO}" "calling main()" "$@"
    main "$@"
    builtin exit
}
command true
