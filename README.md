# docker-live
docker-live is a bootable ISO for running docker.

## Bulding
The build runs in a container, so the prerequisites are minimal. You need to have GNU make and docker installed.

`make iso` will build the build container image (if needed), mount the repo into a conatiner instance and run the build-iso script inside the container.

The default root password after booting the ISO is "live"; You can change this by setting the ROOT_PASSWORD environment variable when you build: `ROOT_PASSWORD=secret make iso`

`make build-container` will build just the container used for building the ISO; this is only needed once, unless you change the Dockerfile.

`make clean` will delete the ISO that was built.

`make clobber` will delete the ISO and the build container.

## Customizing
To add or remove packages, edit the list of packages to be installed in install-packages.txt.

For more advanced customization, create a new hook script in the hooks directory. See the existing hooks for examples.
