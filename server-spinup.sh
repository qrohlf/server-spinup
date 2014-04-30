#!/bin/bash

# server-spinup.sh - a small utility script to set up a new Ubuntu server with a
# variety of nice things, as well as add an admin user and disable root SSH logins
# written by @qrohlf and licensed under the WTFPL

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

prompt() {
  RESPONSE=''
  shopt -s nocasematch;
  while ! [[ "$RESPONSE" =~ ^([yn]|yes|no)$ ]]; do
    printf "\e[0;34;49m$1\e[0m (y/n) "
    read RESPONSE
  done

  if [[ "$RESPONSE" =~ ^(y|yes)$ ]]; then
    return 0
  else 
    return 1
  fi
}


# 0. Sanity Check
###############################################

# Make sure we  are being run as root
if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root" 
   exit 1
fi


section "User Provisioning"
if prompt "Create a new sudo user?"; then
  if [ -z $ADMINUSER ]; then
     read -p "Enter username for the administrative user: " ADMINUSER
  fi

  adduser --ingroup sudo --gecos "" $ADMINUSER 
  success "user $ADMINUSER created"
fi

section "Security stuff"
if prompt "Disallow root login via SSH?"; then
  sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
  service ssh restart
  success "root login via SSH disabled"
fi

section "Environment"
if prompt "Install default development packages?"; then
  apt-get update
  apt-get install -y wget make build-essential zip software-properties-common
  sudo add-apt-repository -y ppa:git-core/ppa # latest git is always nice to have
  apt-get install -y git
  success "done installing packages"
fi

section "Awesomeness"
if prompt "Install sexy-bash-prompt to $ADMINUSER and root bashrc"; then
  cd /tmp && git clone --depth 1 https://github.com/twolfson/sexy-bash-prompt && cd sexy-bash-prompt && make install
  su -c "(cd /tmp/sexy-bash-prompt && make install)" $ADMINUSER
  success "done installing sexy-bash-prompt"
  echo "(you will need to '. .profile' to see the changes in your current session)"
fi

if prompt "Setup dotfiles?"; then
  error "Sorry bro, not implemented yet."
fi

if prompt "Add SSH Key?"; then
  error "Sorry bro, not implemented yet."
fi

section "Tools"
if prompt "Install dokku on this machine?"; then
  wget -qO- https://raw.github.com/progrium/dokku/v0.2.3/bootstrap.sh | sudo DOKKU_TAG=v0.2.3 bash
fi

section "Finished!"
success "Configuration is complete!"
success "If you opted to disable root SSH, you should probably try SSHing localhost as the new user before closing this terminal."
