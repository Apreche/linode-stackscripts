#!/usr/bin/env bash

# *Copy this line to the upper level StackScript because they don't do it recursively
source <ssinclude StackScriptID=1>

function download_config {
    # Utility function to download a config file from this repo to the local system

    # ${1} the name of the config file
    # ${2} the directory to put the config file in with trailing /
    # $3 chmod permissions for the config file

    local -r base_url="https://raw.githubusercontent.com/Apreche/linode-stackscripts/master/configs/"
    local -r filename="${1}"
    local -r full_url="${base_url}${filename}"
    local -r config_path="${2}"
    local -r permissions=$3
    wget "${full_url}" --output-document="${config_path}${filename}"
    chmod $3 "${config_path}"
}

function update_and_upgrade {
    # Update and upgrade all packages

    system_update
    debian_upgrade
}

function enable_unattended_upgrades {
    # Enable the unattended upgrades system on Ubuntu

    apt-get install -y unattended-upgrades
    echo unattended-upgrades unattended-upgrades/enable_auto_updates boolean true | debconf-set-selections
    dpkg-reconfigure -f noninteractive unattended-upgrades
    download_config "50unattended-upgrades" "/etc/apt/apt.conf.d/" 644
    service unattended-upgrades restart
}

function enable_mosh {
    # Enable the mosh shell

    apt-get install -y mosh
    ufw allow 60000:61000/udp
}

function enable_ssh {
    # Create a new user with an SSH pub key and configure ssh server

    # ${1} - username
    # ${2} - ssh public key
    local -r username="${1}"
    local -r ssh_pubkey="${2}"
    user_add_pubkey "${username}" "${ssh_pubkey}"
    ssh_disable_root
    ufw allow ssh
    enable_mosh
    enable_fail2ban
    service ssh restart
}

function enable_ufw {
    # Enable the Ubuntu Uncomplicated FireWall
    ufw default deny incoming
    ufw default allow outgoing
    ufw --force enable
}

function default_editor_vim {
    # Set vim.basic to be the default editor
    update-alternatives --set editor /usr/bin/vim.basic
}

function trim_motd {
    # Remove some extra stuff from the MOTD
    sed -i 's/ENABLED=1/ENABLED=0/' /etc/default/motd-news
    chmod -x /etc/update-motd.d/10-help-text
    rm /etc/update-motd.d/50-landscape-sysinfo
}

function install_ubuntu_base {
    # Performs setup and configuration common to all Ubuntu nodes

    # ${1} - hostname
    # ${2} - non-root username
    # ${3} - non-root password
    # ${4} - timezone (America/New_York)
    # ${5} - non-root SSH public key

    local -r hostname="${1}"
    local -r username="${2}"
    local -r password="${3}"
    local -r timezone="${4}"
    local -r ssh_pubkey="${5}"

    update_and_upgrade
    system_set_hostname "${hostname}"
    system_set_timezone "${timezone}"
    enable_unattended_upgrades
    user_add_sudo "${username}" "${password}"
    enable_passwordless_sudo "${username}"
    enable_ssh "${username}" "${ssh_pubkey}"
    postfix_install_loopback_only
    enable_ufw
    default_editor_vim
    trim_motd
}
