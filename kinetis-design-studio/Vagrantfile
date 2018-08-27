# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Recommended by Vagrant, headless, doesn't have shared folder issue
  config.vm.box = "bento/ubuntu-16.04"

  # Forward X11
  config.ssh.forward_x11 = true

  # Share host downloads directory to serve as a cache.
  config.vm.synced_folder "~/Downloads", "/vagrant_data"

  # VMWare Support
  config.vm.provider "vmware_desktop" do |vm|
    # Only needed to debug vagrant issues
    #vm.gui = true

    # Customize the amount of memory on the VM:
    vm.memory = "1024"

    # Enable USB 2.0
    vm.vmx["usb.present"] = "TRUE"
    vm.vmx["usb.generic.autoconnect"] = "FALSE"
    vm.vmx["ehci.present"] = "TRUE"

    # Auto-connect USB development devices
    vm.vmx["usb.autoConnect.device0"] = "0x1366:0x1015"
  end

  # VirtualBox Support
  config.vm.provider "virtualbox" do |vm|
    # Only needed to debug vagrant issues
    #vm.gui = true

    # Save disk space by only storing difference from base image
    vm.linked_clone = true if Vagrant::VERSION =~ /^1.8/

    # Customize the amount of memory on the VM:
    vm.memory = "1024"

    # Enable USB 2.0
    vm.customize ["modifyvm", :id, "--usb", "on"]
    vm.customize ["modifyvm", :id, "--usbehci", "on"]

    # Segger J-Link devices and debuggers
    vm.customize ['usbfilter', 'add', '0',
      '--target', :id,
      '--name', 'J-Link 0x0101',
      '--vendorid', '0x1366',
      '--productid', '0x0101']
    vm.customize ['usbfilter', 'add', '0',
      '--target', :id,
      '--name', 'J-Link 0x1015',
      '--vendorid', '0x1366',
      '--productid', '0x1015']
  end

  # Enable provisioning with a shell script.
  config.vm.provision "shell", inline: <<-SHELL
    # Disable frontend in debconf, prevent interactive access to stdin
    export DEBIAN_FRONTEND=noninteractive

    apt-get update

    # X11 client only (include xterm to get other deps)
    apt-get install -y xauth xterm

    apt-get install -y unzip

    # Grant access to USB to serial adapters and the like
    usermod -G dialout vagrant
  SHELL

  config.vm.provision "shell", path: "setup.sh"
end
