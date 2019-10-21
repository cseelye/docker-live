# Tabs vs spaces are incredibly important in this file! Both are present for a reason, make sure your editor does not change them!

.DEFAULT_GOAL := iso
SHELL = bash -o pipefail

PROJECT_NAME ?= docker-live
ISO_NAME ?= $(PROJECT_NAME).iso
ROOT_PASSWORD ?= live
BUILD_DIR ?= /root/builder
OUTPUT_DIR ?= /output
SOURCE_DIR ?= /root/src
DEB_SUITE ?= buster
DEB_MIRROR ?= http://ftp.us.debian.org/debian/

ARTIFACT_DIR = $(CURDIR)/build
BUILD_IMAGE_NAME = $(PROJECT_NAME)-builder:latest
BUILD_IMAGE_MARKER = .$(subst :,-,$(BUILD_IMAGE_NAME))

ISO_DEPS = $(wildcard hooks/*)
ISO_DEPS += build-iso install-packages.txt

# Override commands where needed for macOS
TOUCH = touch
uname=$(shell uname -s)
ifeq ($(uname),Darwin)
    TOUCH = gtouch
    ifeq (, $(shell which gtouch))
        $(error "Please install gtouch)
    endif
endif

# Print the value of a variable, for debugging
print-%  : ; @echo $* = $($*)

# Print a list of targets in this Makefile
.PHONY: list
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

# Create a file whose existance and modification date match a container image.
# This brings a container image into make's world and allows make to do its
# normal magic with dependencies, build avoidance, etc.
# $1 the image name
# $2 the marker filename
define create_image_marker
time=$$(docker inspect --format '{{.Metadata.LastTagTime}}' $1 2>/dev/null | perl -pe 's/\s+[^\s]+$$//'); \
if [[ $$? -ne 0 ]]; then \
    time=1970-01-01T00:00:01.000Z; \
fi; \
$(TOUCH) -d "$${time}" '$2';
endef

# Idempotent deletion of a container instance
# $1 the container name
define delete_container
if docker container inspect $1 &>/dev/null; then \
    docker container rm --force $1; \
fi
endef

# Idempotent deletion of a container image
# $1 the image name
define delete_image
if docker image inspect $1 &>/dev/null; then \
    docker image rm --force $1; \
fi
endef

# Idempotent deletion of a container instance and image
# $1 the container name
# $2 the image name
define delete_container_and_image
$(call delete_container,$1)
$(call delete_image,$2)
endef

.PHONY: .create-build-image-marker
.create-build-image-marker:
	@$(call create_image_marker,$(BUILD_IMAGE_NAME),$(BUILD_IMAGE_MARKER))

.PHONY: build-container
build-container: | .create-build-image-marker $(BUILD_IMAGE_MARKER)

$(BUILD_IMAGE_MARKER): Dockerfile
	@$(call delete_image,$(BUILD_IMAGE_NAME)) && \
    DOCKER_BUILDKIT=1 docker build \
        --no-cache \
        --force-rm \
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

$(ARTIFACT_DIR)/$(ISO_NAME): $(ISO_DEPS) $(BUILD_IMAGE_MARKER) | $(ARTIFACT_DIR)
	$(RM) $@ && \
    docker run \
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
        --name docker-live-build-container \
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
