## ----------------------------------------------------------------------
## Builder for creating Docker images that behave similar to Virtual
## Machines for use with Vagrant. This takes advantage if the buildx
## builder in docker which can cross-compile images for other targets.
## ----------------------------------------------------------------------

# These can be overidden with env vars.
REGISTRY ?= rofrano
IMAGE_NAME ?= vagrant-provider
IMAGE_TAG ?= ubuntu
IMAGE ?= $(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)
PLATFORM ?= "linux/amd64,linux/arm64"

# Set up the Docker build environment
.EXPORT_ALL_VARIABLES:

DOCKER_BUILDKIT = 1

all: build

## help:	Lists help on the commands
.PHONY: help
help: Makefile
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST)

.PHONY: clean
clean:	## Removes all dangling build cache
	$(info Removing all dangling build cache)
	echo Y | docker buildx prune

.PHONY: init
init: export DOCKER_BUILDKIT=1
init:	## Creates the buildx instance
	$(info Initializing Builder...)
	docker buildx create --use --name=qemu
	docker buildx inspect --bootstrap

.PHONY: build
build:	## Build all of the project Docker images
	$(info Building $(IMAGE) for $(PLATFORM)...)
	docker buildx build --file Dockerfile.$(IMAGE_TAG)  --pull --platform=$(PLATFORM) --tag $(IMAGE) --push .

.PHONY: run
run:	## Run a vagrant VM using this image
	$(info Bringing up virtual machine with Docker...)
	vagrant up --provider=docker

.PHONY: remove
remove:	## Stop and remove the buildx builder
	$(info Stopping and removing the builder image...)
	docker buildx stop
	docker buildx rm
