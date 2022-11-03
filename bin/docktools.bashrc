# docktools.bashrc - shell init file for docktools sourced from ~/.bashrc

docktools-semaphore() {
    [[ 1 -eq  1 ]]
}

docksh() {
    #help: Enumerate running containers and open a shell by picking from a list
    dockershell.sh "$@"
}

alias dc=docker-compose
alias docker-containers-status='docker stats --no-stream -a'
alias dk=docker

complete -F _complete_alias dk
complete -F _complete_alias dc
complete -F _complete_alias docker-containers-status
