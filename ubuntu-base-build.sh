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
all_set
