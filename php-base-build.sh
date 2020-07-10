#!/usr/bin/env bash
  
# Log all StackScript output to a file
exec > >(tee -i /var/log/stackscript.log)

# StackScript recursiveness doesn't work.
# Copy all ssinclude and UDF statements to top level script
source <ssinclude StackScriptID=1>
source <ssinclude StackScriptID=644166>

# <UDF name="hostname" label="Node Hostname" default="localhost" example="mysite.com" />
# <UDF name="username" label="Non-root username" default="apreche" example="apreche" />
# <UDF name="password" label="Password ofr non-root user" />
# <UDF name="ssh_pubkey" label="SSH public key for non-root user" />
# <UDF name="timezone" label="Node default timezone" default="America/New_York" example="America/New_York" />

# Install base ubuntu image and nothing else
install_ubuntu_base "$HOSTNAME" "$USERNAME" "$PASSWORD" "$TIMEZONE" "$SSH_PUBKEY"

# Install packages
apt-get update
pt-get install -y screen curl vim wget
apt-get install -y apache2 mysql-server php libapache2-mod-php php-mysql
apt-get install -y php-curl php-gd php-mbstring php-xml php-xmlrpc
apt-get install -y php-intl php-soap php-zip
debian_upgrade

# Enable apache mods
a2enmod php7.4 rewrite userdir ssl
service apache2 restart

setup_screenrc
all_set
(sleep 30; shutdown -r -t 0) &
