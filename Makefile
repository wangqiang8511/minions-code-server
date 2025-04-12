# Variables
IMAGE_NAME := wangqiang8511/minions-code-server
IMAGE_TAG := $(shell cat VERSION)
FULL_IMAGE_NAME := $(IMAGE_NAME):$(IMAGE_TAG)
# Use ./workspace relative to the Makefile if not overridden for the workspace mount
HOST_WORKSPACE_PATH ?= ./workspace
CONTAINER_NAME := minions-code-server-container

# Ensure CODE_SERVER_PASSWORD is set for run target
check_password = $(if $(CODE_SERVER_PASSWORD),,$(error CODE_SERVER_PASSWORD environment variable is not set. Please set it before running.))

.PHONY: all build run clean push help

all: build

help:
	@echo "Makefile for managing the $(IMAGE_NAME) Docker image"
	@echo ""
	@echo "Usage:"
	@echo "  make build          Build the Docker image ($(FULL_IMAGE_NAME)) and tag as latest"
	@echo "  make run            Run the Docker container ($(CONTAINER_NAME))"
	@echo "                      (Requires CODE_SERVER_PASSWORD env var to be set)"
	@echo "  make push           Build, tag, and push versioned and latest tags (requires REGISTRY)"
	@echo "  make clean          Stop and remove the running container ($(CONTAINER_NAME))"
	@echo "  make help           Show this help message"
	@echo ""
	@echo "Variables:"
	@echo "  HOST_WORKSPACE_PATH Path on the host for the /config/workspace volume (default: ./workspace)"
	@echo "  REGISTRY          Target Docker registry (e.g., docker.io, ghcr.io). If set, push will use this."

build: Dockerfile VERSION
	@echo "Building Docker image $(FULL_IMAGE_NAME) and tagging as $(IMAGE_NAME):latest..."
	docker build -t $(FULL_IMAGE_NAME) .
	docker tag $(FULL_IMAGE_NAME) $(IMAGE_NAME):latest
	@echo "Successfully built $(FULL_IMAGE_NAME) and $(IMAGE_NAME):latest"

run: build
	$(call check_password)
	@echo "Attempting to remove existing container $(CONTAINER_NAME) if it exists..."
	docker rm -f $(CONTAINER_NAME) || true
	@echo "Creating host workspace directory if it doesn't exist: $(HOST_WORKSPACE_PATH)"
	mkdir -p $(HOST_WORKSPACE_PATH)
	@echo "Running Docker container $(CONTAINER_NAME)..."
	@echo "Mounting host workspace path: $(abspath $(HOST_WORKSPACE_PATH)) to /config/workspace"
	@echo "Port mapping: 8443:8443"
	docker run -d \
		--name=$(CONTAINER_NAME) \
		-e PUID=$$(id -u) \
		-e PGID=$$(id -g) \
		-e TZ=Etc/UTC \
		-e PASSWORD=$(CODE_SERVER_PASSWORD) \
		-e SUDO_PASSWORD=$(CODE_SERVER_PASSWORD) \
		-e DEFAULT_WORKSPACE=/config/workspace \
		-p 8443:8443 \
		-v "$(abspath $(HOST_WORKSPACE_PATH))":/config/workspace \
		--restart unless-stopped \
		$(FULL_IMAGE_NAME)
	@echo "Container $(CONTAINER_NAME) started."
	@echo "Access it at https://localhost:8443"

# Placeholder push target - requires REGISTRY to be set
# REGISTRY variable can be set in the environment or passed via command line
# e.g., make push REGISTRY=docker.io
push: build
	@if [ -z "$(REGISTRY)" ]; then \
		echo "ERROR: REGISTRY environment variable is not set. Cannot push."; \
		echo "Example: make push REGISTRY=docker.io"; \
		exit 1; \
	fi
	@echo "Tagging $(FULL_IMAGE_NAME) as $(REGISTRY)/$(FULL_IMAGE_NAME)..."
	docker tag $(FULL_IMAGE_NAME) $(REGISTRY)/$(FULL_IMAGE_NAME)
	@echo "Tagging $(IMAGE_NAME):latest as $(REGISTRY)/$(IMAGE_NAME):latest..."
	docker tag $(IMAGE_NAME):latest $(REGISTRY)/$(IMAGE_NAME):latest
	@echo "Pushing $(REGISTRY)/$(FULL_IMAGE_NAME)..."
	docker push $(REGISTRY)/$(FULL_IMAGE_NAME)
	@echo "Pushing $(REGISTRY)/$(IMAGE_NAME):latest..."
	docker push $(REGISTRY)/$(IMAGE_NAME):latest
	@echo "Successfully pushed images to registry $(REGISTRY)"

clean:
	@echo "Stopping and removing container $(CONTAINER_NAME)..."
	docker stop $(CONTAINER_NAME) || true
	docker rm $(CONTAINER_NAME) || true
