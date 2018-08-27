#!/usr/bin/env bash
#
# Start the development environment
#

vagrant ssh -c "SWT_GTK3=0 UBUNTU_MENUPROXY=0 mcuxpressoide -data /vagrant/workspace"

