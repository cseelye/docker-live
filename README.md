# docker-live
docker-live is a bootable ISO for running docker. The entire system is contained in the ISO image and can run out of RAM without even needing a disk in the host. The image is currently ~230MB and takes ~5 min to build.

## Building
The build runs in a container, so the prerequisites are minimal. You need to have a GNU-compatible make and docker installed. Docker 19.03.4 or later is preferred. If you are on macOS, you also need the GNU version of touch; `brew install coreutils` will install it from homebrew. macOS users may also wish to install the latest version of make from homebrew.

`make iso` will build the build container image (if needed), mount the repo into a conatiner instance and run the build-iso script inside the container.

The default root password after booting the ISO is "live"; You can change this by setting the ROOT_PASSWORD environment variable when you build: `ROOT_PASSWORD=secret make iso`

`make build-container` will build just the container used for building the ISO; this is only needed once, unless you change the Dockerfile.

`make clean` will delete the ISO that was built.

`make clobber` will delete the ISO and the build container.

## Customizing
To add or remove packages, edit the list of packages to be installed in install-packages.txt.

For more advanced customization, create a new hook script in the hooks directory. See the existing hooks for examples. The hooks are run in alphabetical order, in the context of the chroot, just after debootstrapping.

To manually customize the image, change the 90-manual-config hook to executable and then `make iso` as normal. When the build gets to that hook, it will stop in an interactive shell, allowing you to manually confiugre the image in whatever way you wish. When finished, type exit to close the shell and the build will continue.
