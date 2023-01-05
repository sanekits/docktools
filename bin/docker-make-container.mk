# docker-make-container.mk
# The targets in this makefile are mixed-in with
# targets from recipes.
#
#  This file is passed to 'make' ahead of the recipe file.

RecipeName := UNKNOWN
RunCommand := true
Shellkits := bashics ps1-foo
PullImage := true
ImageName := alpine
ImageTag := latest
Remove := --rm
Iterm := -it
CmdMount :=
Volumes := \
	-v $(HOME)/.local/bin:/host_locbin \
	-v $(HOME):/host_home:ro \
	-v $(PWD):/workspace

.PHONY: help default-help

default-help:
	@echo "Help for recipe $(RecipeName):"

help-options:
	@echo "  Command line options:"
	@echo "    RunCommand=\"$(RunCommand)\""
	@echo "      # Set this to define a command to run in the container immediately"
	@echo "    Shellkits=\"$(Shellkits)\""
	@echo "      # List of shell kits to install"
	@echo "    ImagePull=\$(PullImage)
	@echo "      # Pull image before building container

help: default-help help-options

.PHONY: image-pull
image-pull:
	@if $(PullImage); then \
		docker pull $(ImageName):$(ImageTag) >&2; \
	fi;

.PHONY: image
image: image-pull
	@docker inspect $(ImageName):$(ImageTag) &>/dev/null || { \
		echo "ERROR: no such image cached: $(ImageName):$(ImageTag)" >&2;  \
		exit 1; \
	};

container: image
	@docker run \
		$(Remove) \
		$(Iterm) \
		$(Volumes) \
		$(CmdMount) \
		$(ExtraVols) \
		'$(ImageName):$(ImageTag)' \
		$(RunCommand)

