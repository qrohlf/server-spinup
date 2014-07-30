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
    echo "# $1"
    echo "###############################################"
    echo
}

prompt() {
  RESPONSE=''
  shopt -s nocasematch;
  while ! [[ "$RESPONSE" =~ ^([yn]|yes|no)$ ]]; do
    printf "\e[0;36;49m$1\e[0m (y/n) "
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

# set the user
SPINUP_USER="$LOGNAME"

section "User Provisioning"
if prompt "Create a new sudo user?"; then
  if [ -z $ADMINUSER ]; then
     read -p "Enter username for the administrative user: " ADMINUSER
  fi
  export SPINUP_USER="$ADMINUSER"
  echo "Creating user $ADMINUSER"
  adduser --ingroup sudo --gecos "" $ADMINUSER #not sure if this works
  echo "Generating ssh keys for user qrohlf"
  su qrohlf -c "ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa"
  echo "Adding root authorized_keys to $ADMINUSER"
  cp /root/.ssh/authorized_keys /home/$ADMINUSER/.ssh/authorized_keys
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
  apt-get update
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
  git clone https://github.com/progrium/dokku.git /usr/src/dokku
  cd /usr/src/dokku
  git checkout v0.2.3 #latest dokku version as of 4/30
  make install
  cd
fi

section "Finished!"
success "Configuration is complete!"
echo
success "If you opted to disable root SSH, you should probably try SSHing into the box as the new user before closing this terminal."
echo
success "If you installed dokku, you can setup push access by running:"
echo "cat ~/.ssh/id_rsa.pub |ssh $SPINUP_USER@yourdomain.com \"sudo sshcommand acl-add dokku '\$USER@\$HOSTNAME'\""
echo
success "bye"
