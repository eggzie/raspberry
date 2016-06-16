# Raspberry Pi Devbox

A [Vagrant](http://vagrantup.com) recipe for an Ubuntu 12.04 virtual machine, intented to make C/C++ development for Raspberry Pi a less painful experience. Forked from <https://github.com/nickhutchinson/raspberry-devbox>, updated to use a Raspbian 8 Jessie chroot and the latest [Raspberry Pi cross-compiler toolchain (gcc 4.8.3)](https://github.com/raspberrypi/tools).

This VM includes a sandboxed installation ("chroot") of [Raspbian](http://www.raspbian.org), an ARM variant of the Debian Linux distribution optimized for Raspberry Pi. Use of the sandbox is mediated by a cross-compiling tool called [ScratchBox2](http://maemo.gitorious.org/scratchbox2). ScratchBox2 craftily translates the ARM executables bundled with Raspbian such that they run on your Intel box.

Why is this so nice? Suppose you have C++ app that you want to build for the Raspberry Pi, but it requires a bunch of third-party libraries. Do you really want to hunt down these libraries, their dependencies, their dependencies dependencies, their dependencies dependencies dependencies and so on, until you're able to build your own app? It should be clear that that way lies madness. Perhaps you'll just copy the headers and libraries from your Raspberry to your Intel box, and point your compiler at those. That might work, but it'll be fragile and annoying.

How about we let the Raspbian folks do all the hard work? With ScratchBox2, you can simply apt-get to your heart's content. Just type:

        sb2 -eR apt-get install ...

This executes `apt-get` in the default ScratchBox2 container (in our case, we only have the one. It's called "raspberry".) The `-e` flag is for chroot (emulated) mode; `-R` runs the command as the equivalent of *root* in the sandboxed environment. For a slightly more thorough explanation of ScratchBox2, see these presentation slides: <http://www.daimi.au.dk/~cvm/sb2.pdf>.

## Installation

1. Install both VirtualBox and Vagrant.
2. In a terminal, execute `git clone git://github.com/nickhutchinson/raspberry-devbox.git && cd raspberry-devbox`
3. Execute `vagrant up` to launch and provision your Virtual Machine.

Vagrant will now download the basebox, bootstrap the environment and run the provisioner for the first time. Since the basebox and numerous packages must be downloaded, the first run may take some time depending on your network connection. No supervision should be required; running the install overnight should be just fine. Future runs will be much faster, and won't require network connectivity.

If like to see words dribble down your screen, you can monitor the bootstrap progress by running `vagrant ssh` to ssh into your VM, and then `tail -F ~/raspberry-dev/rootfs/debootstrap/debootstrap.log`

After installation has completed, you should find:

- In `~/raspberry-dev/rootfs`
    - the [Raspbian](http://www.raspbian.org) chroot.
- In `/opt/raspberry-dev`
    - the official [GCC 4.8.3 cross-compiler toolchain](https://github.com/raspberrypi/tools): `arm-linux-gnueabihf-gcc`, `arm-linux-gnueabihf-ld` and so on.
    - [QEmu](http://wiki.qemu.org/Main_Page) 1.3.0
    - [ScratchBox2](http://maemo.gitorious.org/scratchbox2) @ git tag 2.3.90 (earlier releases didn't seem to work)

The default configuration allocates 4 CPU cores and 4 GB of RAM to the VM. This can be configured by editing the following lines in the `Vagrantfile`:

    v.memory = 4096
    v.cpus = 4

## Example Usage

* Starting the VM: in the program root directory, run `vagrant up` to start the VM, then `vagrant ssh` to enter it.
* `sb2 make` make using host cross compiler toolchain.
* `sb2 -e make` make using emulated target toolchain.
* `sb2 -eR make install` install in emulation mode as root.

## VirtualBox

The basic virtualization layer is [VirtualBox](https://www.virtualbox.org). Any current version should do, however the guest additions are pinned to current version at the time the basebox was built (4.2.0). A mismatch between the guest additions and the VirtualBox version may result in strange behaviour, mostly affecting shared folders and networking. To update the guest, additions follow the instructions in the VirtualBox manual.

## Vagrant

[Vagrant](http://vagrantup.com) is the scripting toolkit used to control all interaction with the devbox. A full guide on Vagrant can be found on the [Vagrant site](http://vagrantup.com). As a short primer, the following commands should be sufficient:

* `vagrant up <boxname>` start the given box. If the box has not been initialized and created, this will download the basebox as required, bootstrap it and run the provisioner. Running `vagrant up` when the box is already running is a NOOP and has no effect.
* `vagrant halt <boxname>` stop the given box. Has no effect if the box is not running. May require an invocation using the `--force` flag (`vagrant halt --force <boxname>`) if the box crashed, locked up or cannot be accessed via `vagrant ssh`
* `vagrant reload <boxname>` stop and start the given box. Runs the provisioner.
* `vagrant provision <boxname>` Runs the provisioner.
* `vagrant destroy <boxname>` destroys the given box. This is useful if for some reason the box has been damaged or to free disk space. Running `vagrant up` after running `vagrant destroy` bootstraps a new box.
* `vagrant ssh <boxname>` open an ssh connection to the given box.
	
## Puppet

Provisioning of the Virtual Machine is handled by [Puppet](http://puppetlabs.com). Take a look at the `raspberry_dev` module.

## Bugs
* Some programs such as aptitude crash with segfault when run in emulation mode. Updated qemu might fix this
