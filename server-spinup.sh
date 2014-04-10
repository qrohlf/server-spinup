#!/bin/sh

# server-spinup.sh - a small utility script to set up a new DigitalOcean Ubuntu server droplet
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
   info "ADMINUSER var not set, displaying interactive prompt"
   read -s -p "Enter username for the administrative user: " ADMINUSER
fi
if [ -z $PASS ]; then
   info "PASS var not set, displaying interactive prompt"
   read -s -p "Enter new password for user $ADMINUSER: " PASS
   read -s -p "Confirm password for user $ADMINUSER: " PASS_CONFIRM
fi
adduser --ingroup sudo --gecos "" --disabled-password $ADMINUSER 
echo $ADMINUSER:$PASS | chpasswd
echo user $ADMINUSER created with password $PASS

section "2. Disallow root login via SSH"
sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
service ssh restart

section "3. Install dev packages"
apt-get update  >/dev/null
apt-get install -y $PACKAGES  >/dev/null

section "5. Install sexy-bash-prompt to $ADMINUSER and root bashrc"
cd /tmp && git clone --depth 1 https://github.com/twolfson/sexy-bash-prompt && cd sexy-bash-prompt && make install
su -c "(cd /tmp/sexy-bash-prompt && make install)" qrohlf

section "6. Upgrade and reboot"
apt-get upgrade -y
echo "All finished! Rebooting now..."
reboot
