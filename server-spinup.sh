#!/bin/sh

# server-spinup.sh - a small utility script to set up a new DigitalOcean Ubuntu server droplet
# written by @qrohlf and licensed under the WTFPL

# Variables
##############################################

# User to create and grant root privileges to
ADMINUSER="qrohlf"

# Development packages to install
PACKAGES="git make build-essential zip"

# 0. Sanity Check
###############################################

# Make sure we  are being run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

echo
echo
echo "# 1. Add the new user and grant root privileges"
echo "###############################################"
echo
if [ -z $PASS ]; then
   echo "PASS var not set, generating a random one..."
   PASS=`(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)`
fi
adduser --ingroup sudo --gecos "" --disabled-password $ADMINUSER 
echo $ADMINUSER:$PASS | chpasswd
echo user $ADMINUSER created with password $PASS

echo
echo
echo "# 2. Disallow root login via SSH"
echo "###############################################"
echo
sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
service ssh restart

echo
echo
echo "# 3. Install dev packages"
echo "###############################################"
echo
apt-get update  >/dev/null
apt-get install -y $PACKAGES  >/dev/null

echo
echo
echo "# 5. Install sexy-bash-prompt to $ADMINUSER and root bashrc"
echo "###############################################"
echo
cd /tmp && git clone --depth 1 https://github.com/twolfson/sexy-bash-prompt && cd sexy-bash-prompt && make install
su -c "(cd /tmp/sexy-bash-prompt && make install)" qrohlf
echo
echo
echo "# 6. Upgrade and reboot"
echo "################################################"
echo
apt-get upgrade -y
echo "All finished! Rebooting now..."
reboot
