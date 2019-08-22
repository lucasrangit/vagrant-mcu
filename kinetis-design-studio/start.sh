#!/usr/bin/env bash
#
# Start the development environment
#

vagrant up
vagrant ssh -c "SWT_GTK3=0 UBUNTU_MENUPROXY=0 kinetis-design-studio -data /home/vagrant/workspace"

