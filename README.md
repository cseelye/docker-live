# docker-live
docker-live is a bootable ISO for running docker.

## Bulding
`make iso`  
The build runs in a container, so the prerequisites are minimal. You need to have GNU make and docker installed.

## Customizing
To add or remove packages, edit the list of pacakges to be installed in install-pacakges.txt.

For more advanced customization, create a new hook script in the hooks directory. See the existing hooks for examples.
