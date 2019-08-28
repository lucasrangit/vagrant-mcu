# vagrant-mcu

Vagrant files for various (e.g. Kinetis) microcontroller development environments.

## HOWTO

1. Copy the `.gitignore` and the files in the IDE folder to you project's source folder.
1. Run `./start.sh`. Vagrant will run the `setup.sh` script and automatically provision a VM and import the project in the current directory.

* Subsequently run `./start.sh` to launch the IDE.
* Manually shutdown the VM with `vagrant halt`.
* Recreate the VM with `vagrant destroy -f default`.

