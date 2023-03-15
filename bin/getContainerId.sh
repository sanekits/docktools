#!/bin/sh
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

# If we've gotten this far, it's time to get crude.  This means that if you
# are doing docker-in-docker, we expect one of the tests above to detect that.
which docker 2>&1 \
    && exit 1

cat /etc/hostname

