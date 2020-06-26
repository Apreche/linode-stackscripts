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

# Add PPAs
add-apt-repository ppa:jonathonf/vim -y
add-apt-repository ppa:git-core/ppa -y
add-apt-repository ppa:deadsnakes/ppa -y

# PostgreSQL apt repo
apt-get install -y postgresql-common
yes | exec /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh

# Install packages
apt-get update
apt-get install -y screen
apt-get install -y vim git postgresql-12
apt-get install -y build-essential
apt-get install -y python3.8 python3.8-dev
# Install dependencies of python packages
debian_upgrade

# Python Setup
update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1
update-alternatives --set python /usr/bin/python3.8
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
/usr/bin/env python get-pip.py
rm get-pip.py

function setup_gitconfig {
    su $USERNAME -c "git clone https://gist.github.com/889248.git ~/gittemp"
    su $USERNAME -c "mv ~/gittemp/gitconfig ~/.gitconfig"
    su $USERNAME -c "rm -rf ~/gittemp"
}

function setup_bashalias {
    su $USERNAME -c "git clone https://gist.github.com/1239622.git ~/gittemp"
    su $USERNAME -c "mv ~/gittemp/bash_aliases ~/.bash_aliases"
    su $USERNAME -c "rm -rf ~/gittemp"
}

function setup_bashrc {
    su $USERNAME -c "git clone https://gist.github.com/09eb1865347cdd6939186f100c8e654c.git ~/gittemp"
    su $USERNAME -c "mv ~/gittemp/.bashrc ~/.bashrc"
    su $USERNAME -c "rm -rf ~/gittemp"
}

function setup_localbin {
    su $USERNAME -c "mkdir ~/bin"
    su $USERNAME -c "git clone https://gist.github.com/19495f6832534bfa45bd60835a233043.git ~/gittemp"
    su $USERNAME -c "mv ~/gittemp/create_db_user.sh ~/bin/create_db_user.sh"
    su $USERNAME -c "chmod 755 ~/bin/create_db_user.sh"
    su $USERNAME -c "rm -rf ~/gittemp"
}

function setup_projectenv {
    su $USERNAME -c "mkdir ~/.project_env"
}

function setup_screenrc {
    su $USERNAME -c "git clone https://gist.github.com/1921155.git ~/gittemp"
    su $USERNAME -c "mv ~/gittemp/screenrc ~/.screenrc"
    su $USERNAME -c "rm -f ~/gittemp"
}

function setup_psqlrc {
    su $USERNAME -c "git clone https://gist.github.com/32fdb27073ae86b3fb017f2d2202da01.git ~/gittemp"
    su $USERNAME -c "mv ~/gittemp/.psqlrc ~/.psqlrc"
    su $USERNAME -c "rm -rf ~/gittemp"
}

function setup_pipconfig {
    su $USERNAME -c "git clone https://gist.github.com/8c33159a238b5d052fe84fecc9b5fd1e.git ~/gittemp"
    su $USERNAME -c "mkdir ~/.pip"
    su $USERNAME -c "mv ~/gittemp/pip.conf ~/.pip/pip.conf"
    su $USERNAME -c "rm -rf ~/gittemp"
}

function setup_poetry {
    su $USERNAME -c "wget https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py --output-document='~/get-poetry.py'"
    su $USERNAME -c "python ~/get-poetry.py"
    su $USERNAME -c "rm get-poetry.py"
}

function setup_ipython {
    su $USERNAME -c "pip install --user ipython"
    su $USERNAME -c "ipython profile create"
    su $USERNAME -c "git clone https://gist.github.com/02801160aadb5089d77e.git ~/gittemp"
    su $USERNAME -c "mv ~/gittemp/ipython_config.py ~/.ipython/profile_default/ipython_config.py"
    su $USERNAME -c "rm -rf ~/gittemp"
}

function setup_vimrc {
    su $USERNAME -c "git clone https://github.com/Apreche/vim.git ~/.vim"
    su $USERNAME -c "ln -s ~/.vimrc ~/.vim/vimrc"
    su $USERNAME -c "pip install --user -r ~/.vim/requirements.txt"
    su $USERNAME -c "ln -s ~/.config/flake8 ~/.vim/flake8"
    su $USERNAME -c "vim +'PlugInstall --sync' +qall"
}

function setup_user {
    setup_gitconfig
    setup_bashalias
    setup_bashrc
    setup_localbin
    setup_projectenv
    setup_screenrc
    setup_psqlrc
    setup_pipconfig
    setup_poetry
    setup_ipython
    setup_vimrc
}

setup_user
all_set
