#!/bin/sh

# server-spinup.sh - a small utility script to set up a new DigitalOcean Ubuntu server droplet
# written by @qrohlf and licensed under the WTFPL

# Variables
###############################

# User to create and grant root privileges to
ADMINUSER="qrohlf"

# Development packages to install
PACKAGES="git make ruby1.9.1 nginx-full"

# Comment this line out for no GUI
GUI="xfce4 xubuntu-artwork xubuntu-default-settings" 


# 1. Add the new user and grant root privileges
###############################################

# 2. Disallow root login via SSH
###############################################

# 3. Add PPA for passenger-nginx
###############################################

# 4. Install dev packages
###############################################

# 5. Install GUI
###############################################
