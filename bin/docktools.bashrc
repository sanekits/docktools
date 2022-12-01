# docktools.bashrc - shell init file for docktools sourced from ~/.bashrc

docktools-semaphore() {
    [[ 1 -eq  1 ]]
}

in_docker_container() {
    # Sadly this topic is endlessly complex, and we're compromising here.  See https://stackoverflow.com/questions/20010199/how-to-determine-if-a-process-runs-inside-lxc-docker/20010626#20010626

    [[ -f /.dockerenv ]] \
        &&  return;
    grep -sq 'docker' /proc/1/cgroup
}

docksh() {
    #help: Enumerate running containers and open a shell by picking from a list
    dockershell.sh "$@"
}

alias dc=docker-compose
alias docker-containers-status='docker stats --no-stream -a'
alias dk=docker
alias dockstat='docker stats --no-stream -a'

in_docker_container && {
    { unalias dockins; unset dockins; } &>/dev/null
    alias dockins='${HOME}/.local/bin/docktools-shellkit-install.sh'
}

complete -F _complete_alias dk
complete -F _complete_alias dc
complete -F _complete_alias docker-containers-status

docker-history() {
    #Help show container or image history without truncation or junk whitespace
    [[ $# -eq 0 ]] && return $(die "Expected container or image name")
    command docker history --no-trunc "$1" | tr -s ' '
}
