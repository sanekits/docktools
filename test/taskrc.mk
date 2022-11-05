# taskrc.mk for test
#


absdir := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
SHELL := /bin/bash
REMAKE := $(MAKE) -C $(absdir) -s -f $(lastword $(MAKEFILE_LIST))

HOST_UID := 0

.PHONY: help
help:
	@echo "Targets in $(basename $(lastword $(MAKEFILE_LIST))):" >&2
	@$(REMAKE) --print-data-base --question no-such-target 2>/dev/null | \
	grep -Ev  -e '^taskrc.mk' -e '^help' -e '^(Makefile|GNUmakefile|makefile|no-such-target)' | \
	awk '/^[^.%][-A-Za-z0-9_]*:/ \
			{ print substr($$1, 1, length($$1)-1) }' | \
	sort | \
	pr --omit-pagination --width=100 --columns=3
	@echo -e "absdir=\t\t$(absdir)"
	@echo -e "CURDIR=\t\t$(CURDIR)"
	@echo -e "taskrc_dir=\t$${taskrc_dir}"

.PHONY: start-test-container
start-test-container:
	# Spin up a bare container and add requested user
	set -x; docker run  -d --rm --init \
		--name docktools-test1 \
		-v $(absdir):/workspace \
		-v $(absdir/../bin):/workspace/bin \
		-u root \
		-w /workspace \
		docktools-test:1 \
		bash -c 'bin/init-test-user.sh --user $(HOST_UID) ; sleep infinity;'
	sleep 1

.PHONY: test-container-bootstrap
test-container-bootstrap:
	set -x; ./bootstrap-container.sh --container-name docktools-test1 --user $(HOST_UID)
	docker ps
	set -x; $(MAKE) -f taskrc.mk \
		HOST_UID=$(HOST_UID) \
		validate-container-shellstate
	#docker stop docktools-test1

.PHONY: test-container-bootstrap-0
test-container-bootstrap-0:
	$(MAKE) -f taskrc.mk HOST_UID=0 test-container-bootstrap


.PHONY: test-container-bootstrap-1000
test-container-bootstrap-1000:
	$(MAKE) -f taskrc.mk HOST_UID=1000 test-container-bootstrap

.PHONY: validate-container-shellstate
validate-container-shellstate:
	xopts="-e CONTAINER_NAME=docktools-test1 -e XUSER=$(HOST_UID)"; \
		docker exec -u $(HOST_UID) $$xopts -i docktools-test1 bash -l ./validate-shellstate.sh


.PHONY: test
test: clean
	$(MAKE) -f taskrc.mk clean test-container-bootstrap-1000
#	$(MAKE) -f taskrc.mk clean test-container-bootstrap-0



.PHONY: clean
clean:
	-docker kill docktools-test1 2>/dev/null
