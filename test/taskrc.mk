# taskrc.mk for test
#


absdir := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
SHELL := /bin/bash
REMAKE := $(MAKE) -C $(absdir) -s -f $(lastword $(MAKEFILE_LIST))
HOST_UID := $(shell echo $$UID)

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

.PHONY: test-container-bootstrap
test-container-bootstrap:
	# Spin up a bare container and bootstrap a usable shell with sane defaults
	docker run  -d --rm --init \
		--name docktools-test1 \
		-v $(absdir):/workspace \
		-u root \
		-w /workspace \
		docktools-test:1 \
		bash -c './init-test-users.sh $(HOST_UID) && sleep infinity;'
	./bootstrap-container.sh docktools-test1
	echo "Infinite wait for tests:"
	sleep infinity

.PHONY: validate-container-shellstate
validate-container-shellstate:
	./validate-container-bootstrap.sh docktools-test1 -u 0
	./validate-container-bootstrap.sh docktools-test1 -u $(HOST_UID)

.PHONY: test
test: test-container-bootstrap



.PHONY: clean
clean:
	-docker kill docktools-test1
