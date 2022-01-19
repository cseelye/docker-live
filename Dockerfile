FROM ubuntu:20.04

ARG ROOT_PASSWORD
ENV ROOT_PASSWORD=${ROOT_PASSWORD:-live}

ARG PROJECT_NAME
ENV PROJECT_NAME=${PROJECT_NAME:-docker-live}

ARG ISO_NAME
ENV ISO_NAME=${ISO_NAME:-${PROJECT_NAME}.iso}

ARG OUTPUT_DIR
ENV OUPUT_DIR=${OUTPUT_DIR:-/output}

ARG DEB_SUITE
ENV DEB_SUITE=${DEB_SUITE:-focal}

ARG DEB_MIRROR
ENV DEB_MIRROR=${DEB_MIRROR:-http://us.archive.ubuntu.com/ubuntu/}

ARG BUILD_DIR
ENV BUILD_DIR=${BUILD_DIR:-/root/builder}

ARG SOURCE_DIR
ENV SOURCE_DIR=${SOURCE_DIR:-/root/src}

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get --no-install-recommends --yes install \
        binutils \
        debootstrap \
        grub-efi-amd64-bin \
        grub-pc-bin \
        mtools \
        rsync \
        squashfs-tools \
        vim \
        xorriso \
    && apt-get autoremove --yes && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR $SOURCE_DIR
CMD ["./build-iso"]
