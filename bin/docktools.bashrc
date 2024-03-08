# docktools.bashrc - shell init file for docktools sourced from ~/.bashrc

docktools-semaphore() {
    [[ 1 -eq  1 ]]
}

alias docksh=dockershell.sh
alias dockmk=docker-make-container.sh

dc() {
    which docker-compose &>/dev/null && {
        command docker-compose "$@"
    } || {
        command docker compose "$@"
    }
}

alias docker-containers-status='docker stats --no-stream -a'
alias dk=docker
alias dockstat='docker stats --no-stream -a'

alias dock-start='sudo service docker start'

in_docker_container() {
    ${HOME}/.local/bin/docktools/in-container.sh "$@"
}

in_docker_container && {
    { unalias dockins; unset dockins; } &>/dev/null
    alias dockins='${HOME}/.local/bin/docktools-shellkit-install.sh'
}

[[ -f ~/.bash_completion.d/docktools ]] \
    && source ~/.bash_completion.d/docktools

docker_history() {
    #Help show container or image history without truncation or junk whitespace
    [[ $# -eq 0 ]] && return $(die "Expected container or image name")
    command docker history --no-trunc "$1" | tr -s ' '
}
