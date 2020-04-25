#!/usr/bin/env bash

# Include the Linode StackScript Library
Source <ssinclude StackScriptID=1>

# Upgrade all packages
system_update
debian_upgrade

# Set the hostname
# <UDF name="hostname" Label="System Hostname" default="" />
system_set_hostname “$HOSTNAME”

# setup unattended upgrades
# create user
# configure sudo
# setup SSH
# setup mosh
# setup fail2ban
# setup local email
postfix_install_loopback_only
# setup firewall

# END
all_set
