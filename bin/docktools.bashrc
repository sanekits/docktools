# docktools.bashrc - shell init file for docktools sourced from ~/.bashrc

docktools-semaphore() {
    [[ 1 -eq  1 ]]
}

docksh() {
    #help: Enumerate running containers and open a shell by picking from a list
    dockershell.sh "$@"
}
