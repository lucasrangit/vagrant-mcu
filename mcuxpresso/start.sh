#!/usr/bin/env bash

vagrant up
vagrant ssh -c "SWT_GTK3=0 UBUNTU_MENUPROXY=0 mcuxpressoide -data /home/vagrant/workspace" &

