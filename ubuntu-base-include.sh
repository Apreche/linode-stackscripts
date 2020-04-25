#!/usr/bin/env bash

# Include the Linode StackScript Library
Source <ssinclude StackScriptID=1>

function download_config {
    # Download a config file from this repo to the local file system
    # ${1} the name of the config file
    # ${2} the directory to put the config file in with trailing /
    # $3 chmod permissions for the config file

    local -r base_url="https://raw.githubusercontent.com/Apreche/linode-stackscripts/master/configs/"
    local -r filename="${1}"
    local -r full_url="${base_url}${filename}"
    local -r config_path="${2}"
    local -r permissions=$3

    wget "${full_url}" --output-document="${config_path}${filename}"
    chmod $3 ${config_path}
}

function update_and_upgrade {
    # Update and upgrade all packages
    system_update
    debian_upgrade
}

function enable_unattended_upgrades {
    apt install unattended-upgrades
    echo unattended-upgrades unattended-upgrades/enable_auto_updates boolean true | debconf-set-selections
    dpkg-reconfigure -f noninteractive unattended-upgrades
    download_config "50unattended-upgrades" "/etc/apt/apt.conf.d/" 644
    service unattended-upgrades restart
}

function enable_mosh {
    apt install mosh
    ufw allow 60000:61000/udp
}

function enable_ssh {
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
    ufw default deny incoming
    ufw default allow outgoing
    ufw enable
}

function install_ubuntu_base {
    # Performs setup common to all Ubuntu nodes

    # ${1} - hostname
    # ${2} - non-root username
    # ${3} - non-root password
    # ${4} - non-root SSH public key
    # ${5} - timezone (America/New_York)

    local -r hostname="${1}"
    local -r username="${2}"
    local -r password="${3}"
    local -r ssh_pubkey="${4}"
    local -r timezone="${5}"


    update_and_upgrade

    system_set_hostname "${hostname}"
    system_set_timezone "${timezone}"

    # setup unattended upgrades
    enabled_unattended_upgrades

    # Set user
    user_add_sudo "${username}" "${password}"
    enable_passwordless_sudo "${username}"

    enable_ssh

    # setup local email
    postfix_install_loopback_only

    # setup firewall
    enable_ufw

    # END
    all_set
}
