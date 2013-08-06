#!/bin/sh

# server-spinup.sh - a small utility script to set up a new DigitalOcean Ubuntu server droplet
# written by @qrohlf and licensed under the WTFPL

# Variables
##############################################

# User to create and grant root privileges to
ADMINUSER="qrohlf"

# Development packages to install
PACKAGES="git make ruby1.9.1 nginx-full"

# Comment this line out for no GUI
# I use a GUI for my 'sandbox' servers because it makes
# configuration and setup much easier, but I woudn't
# recommend installing onein an actual production environment
GUI="xfce4 xubuntu-artwork xubuntu-default-settings" 

# 0. Sanity Check
###############################################

# Make sure we  are being run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# 1. Add the new user and grant root privileges
###############################################
PASS=`(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)`
adduser -p $PASS -g sudo --gecos "" $ADMINUSER
echo user $ADMINUSER created with generated password $PASS

# 2. Disallow root login via SSH
###############################################
sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# 3. Add PPA for passenger-nginx
###############################################
apt-get update
apt-get install python-software-properties # needed for apt-add-repository
apt-add-repository ppa:brightbox/ruby-ng # includes nginx with passenger, newer ruby versions

# 4. Install dev packages and GUI
###############################################
apt-get update
apt-get install $PACKAGES $GUI

# 5. Set up VNC
###############################################
if [$GUI]
   then
   
fi

# 5. Install sexy-bash-prompt to $ADMINUSER and root bashrc
###############################################

