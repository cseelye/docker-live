# Tabs vs spaces are incredibly important in this file! Both are present for a reason, make sure your editor does not change them!

.DEFAULT_GOAL := iso
SHELL = bash -o pipefail

PROJECT_NAME ?= docker-live
ISO_NAME ?= $(PROJECT_NAME).iso
ROOT_PASSWORD ?= live
BUILD_DIR ?= /root/builder
OUTPUT_DIR ?= /output
SOURCE_DIR ?= /root/src
DEB_SUITE ?= focal
DEB_MIRROR ?= http://us.archive.ubuntu.com/ubuntu/

ARTIFACT_DIR = $(CURDIR)/build
BUILD_IMAGE_NAME = $(PROJECT_NAME)-builder:latest
BUILD_IMAGE_MARKER = .$(subst :,-,$(BUILD_IMAGE_NAME))

ISO_DEPS = $(wildcard hooks/*)
ISO_DEPS += build-iso install-packages.txt

# Idempotent deletion of a container image
# $1 the image name
define delete_image
if docker image inspect $1 &>/dev/null; then \
    docker image rm --force $1; \
fi
endef

builder-image: Dockerfile
	docker image build \
        --build-arg PROJECT_NAME="$(PROJECT_NAME)" \
        --build-arg ISO_NAME="$(ISO_NAME)" \
        --build-arg ROOT_PASSWORD="$(ROOT_PASSWORD)" \
        --build-arg BUILD_DIR="$(BUILD_DIR)" \
        --build-arg OUTPUT_DIR="$(OUTPUT_DIR)" \
        --build-arg SOURCE_DIR="$(SOURCE_DIR)" \
        --build-arg DEB_SUITE="$(DEB_SUITE)" \
        --build-arg DEB_MIRROR="$(DEB_MIRROR)" \
        --tag=$(BUILD_IMAGE_NAME) \
        .

$(ARTIFACT_DIR):
	mkdir -p $@

.PHONY: iso
iso: $(ARTIFACT_DIR)/$(ISO_NAME)

$(ARTIFACT_DIR)/$(ISO_NAME): $(ISO_DEPS) | $(ARTIFACT_DIR) builder-image
	$(RM) $@ && \
    docker container run \
        --rm \
        --privileged \
        --interactive \
        --tty \
        --volume "$(CURDIR)":"$(SOURCE_DIR)" \
        --volume "$(ARTIFACT_DIR)":"$(OUTPUT_DIR)" \
        --env ROOT_PASSWORD="$(ROOT_PASSWORD)" \
        --env BUILD_DIR="$(BUILD_DIR)" \
        --env SOURCE_DIR="$(SOURCE_DIR)" \
        --env OUTPUT_DIR="$(OUTPUT_DIR)" \
        --env ISO_NAME="$(ISO_NAME)" \
        --env DEB_SUITE="$(DEB_SUITE)" \
        --env DEB_MIRROR="$(DEB_MIRROR)" \
        --name docker-live-builder \
        $(BUILD_IMAGE_NAME)

.PHONY: clean
clean:
	$(RM) -r $(ARTIFACT_DIR)/*

.PHONY: clobber
clobber: clean
	$(call delete_image,$(BUILD_IMAGE_NAME))

.PHONY: docker-clean
docker-clean:
	docker image prune --force

.PHONY: docker-clobber
docker-clobber:
	docker system prune --force
