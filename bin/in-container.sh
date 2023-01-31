#!/bin/bash
# in-container.sh
# Succeeds if invoked within a Docker container

scriptName="$(readlink -f "$0")"
scriptDir=$(command dirname -- "${scriptName}")
PS4='+$?(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

die() {
    builtin echo "ERROR($(basename ${scriptName})): $*" >&2
    builtin exit 1
}

in_docker_container() {
    # Sadly this topic is endlessly complex, and we're compromising here.  See https://stackoverflow.com/questions/20010199/how-to-determine-if-a-process-runs-inside-lxc-docker/20010626#20010626

    [[ -f /.dockerenv ]] \
        &&  return;
    grep -sq 'docker' /proc/1/cgroup
}

[[ -z ${sourceMe} ]] && {
    in_docker_container
    builtin exit
}
command true
