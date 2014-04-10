#!/bin/sh

# server-spinup.sh - a small utility script to set up a new DigitalOcean Ubuntu server droplet
# with an admin user and disable root login. Also installs sexy-bash-prompt because it's pretty.
# written by @qrohlf and licensed under the WTFPL\

# Logging
##############################################
# nice colorized output
notice() {
    printf "\e[0;35;49m$1\e[0m\n"
}

error() {
    printf "\e[0;33;49m$1\e[0m\n"
}

success() {
    printf "\e[0;32;49m$1\e[0m\n"
}

section() {
    echo
    echo
    notice "# $1"
    notice "###############################################"
    echo
}

# Variables
##############################################

# Development packages to install
PACKAGES="git make build-essential zip"

# 0. Sanity Check
###############################################

# Make sure we  are being run as root
if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root" 
   exit 1
fi


section "1. Add the new user and grant root privileges"
if [ -z $ADMINUSER ]; then
   echo "ADMINUSER var not set, displaying interactive prompt"
   echo
   read -p "Enter username for the administrative user: " ADMINUSER
fi

while [ -z $PASS ]; do
   echo "PASS var not set, displaying interactive prompt"
   echo
   read -s -p "Enter new password for user $ADMINUSER: " PASS
   echo
   read -s -p "Confirm password for user $ADMINUSER: " PASS_CONFIRM
   echo
   if [[ $PASS != $PASS_CONFIRM ]]; then
       error "Passwords do not match"
       unset PASS
   fi
done
adduser --ingroup sudo --gecos "" --disabled-password $ADMINUSER 
echo $ADMINUSER:$PASS | chpasswd
success "user $ADMINUSER created"

section "2. Disallow root login via SSH"
sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
service ssh restart
success "root login via SSH disabled"

section "3. Install dev packages"
apt-get update
apt-get install -y $PACKAGES
success "done installing packages"

section "5. Install sexy-bash-prompt to $ADMINUSER and root bashrc"
cd /tmp && git clone --depth 1 https://github.com/twolfson/sexy-bash-prompt && cd sexy-bash-prompt && make install
su -c "(cd /tmp/sexy-bash-prompt && make install)" qrohlf
success "done installing sexy-bash-prompt"

section "6. Upgrade and reboot"
apt-get upgrade -y
success "All finished! Rebooting now..."
reboot
