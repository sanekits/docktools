# getContainerId.sh
#  This runs inside the container and prints the container ID

# Commands are ordered by descending reliability:

grep -qE 'docker' /proc/self/cpuset && {
    grep -E 'docker' /proc/self/cpuset | tr '/' ' ' | awk '{print $NF}'
    exit
}

grep -qE 'docker' /proc/self/cgroup && {
    grep -E 'docker' /proc/self/cgroup | tail -n 1 | tr ':/' ' ' | awk '{print $NF}'
    exit
}

docker info &>/dev/null \
    && exit 1

cat /etc/hostname

