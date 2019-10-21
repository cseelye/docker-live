FROM debian:buster

ARG ROOT_PASSWORD
ENV ROOT_PASSWORD=${ROOT_PASSWORD:-live}

ARG PROJECT_NAME
ENV PROJECT_NAME=${PROJECT_NAME:-docker-live}

ARG ISO_NAME
ENV ISO_NAME=${ISO_NAME}:-${PROJECT_NAME}.iso}

ARG OUTPUT_DIR
ENV OUPUT_DIR=${OUTPUT_DIR:-/output}

ARG DEB_SUITE
ENV DEB_SUITE=${DEB_SUITE:-buster}

ARG DEB_MIRROR
ENV DEB_MIRROR=${DEB_MIRROR:-http://ftp.us.debian.org/debian/}

ARG BUILD_DIR
ENV BUILD_DIR=${BUILD_DIR:-/root/builder}

ARG SOURCE_DIR
ENV SOURCE_DIR=${SOURCE_DIR:-/root/src}

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get --no-install-recommends --yes install \
        adduser \
        busybox-static \
        bzip2 \
        cpio \
        debootstrap \
        grub-efi-amd64-bin \
        grub-pc-bin \
        insserv \
        kmod \
        mtools \
        rsync \
        squashfs-tools \
        sudo \
        vim \
        xorriso \
        xz-utils

WORKDIR $SOURCE_DIR
CMD ["./build-iso"]
