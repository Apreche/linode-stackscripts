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
apt-get install curl ca-certificates gnupg
curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
sh -c 'echo "deb [arch=amd64] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# Install packages
apt-get update
apt-get install -y build-essential
apt-get install -y screen
apt-get install -y vim git postgresql-12
apt-get install -y python3 python3-dev python3-distutils python3-testresources python3-venv
debian_upgrade
apt-get install -y supervisor rabbitmq-server nginx 

# Set default Python and install pip
update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1
update-alternatives --set python /usr/bin/python3.8
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py
rm get-pip.py

function setup_gitconfig {
    git clone https://gist.github.com/889248.git ~/gittemp
    cp ~/gittemp/gitconfig /home/$USERNAME/.gitconfig
    chown $USERNAME:$USERNAME /home/$USERNAME/.gitconfig
    chmod 644 /home/$USERNAME/.gitconfig
    rm -rf ~/gittemp
}

function setup_bashalias {
    git clone https://gist.github.com/1239622.git ~/gittemp
    cp ~/gittemp/bash_aliases /home/$USERNAME/.bash_aliases
    chown $USERNAME:$USERNAME /home/$USERNAME/.bash_aliases
    chmod 644 /home/$USERNAME/.bash_aliases
    rm -rf ~/gittemp
}

function setup_bashrc {
    git clone https://gist.github.com/09eb1865347cdd6939186f100c8e654c.git ~/gittemp
    cp ~/gittemp/.bashrc /home/$USERNAME/.bashrc
    chown $USERNAME:$USERNAME /home/$USERNAME/.bashrc
    chmod 644 /home/$USERNAME/.bashrc
    rm -rf ~/gittemp
}

function setup_localbin {
    mkdir /home/$USERNAME/bin
    chown $USERNAME:$USERNAME /home/$USERNAME/bin
}

function setup_projectenv {
    mkdir /home/$USERNAME/.project_env
    chown $USERNAME:$USERNAME /home/$USERNAME/.project_env
}

function setup_screenrc {
    git clone https://gist.github.com/1921155.git ~/gittemp
    cp ~/gittemp/screenrc /home/$USERNAME/.screenrc
    chown $USERNAME:$USERNAME /home/$USERNAME/.screenrc
    chmod 644 /home/$USERNAME/.screenrc
    rm -rf ~/gittemp
}

function setup_psqlrc {
    git clone https://gist.github.com/32fdb27073ae86b3fb017f2d2202da01.git ~/gittemp
    cp ~/gittemp/.psqlrc /home/$USERNAME/.psqlrc
    chown $USERNAME:$USERNAME /home/$USERNAME/.psqlrc
    chmod 644 /home/$USERNAME/.psqlrc
    rm -rf ~/gittemp
}

function setup_pipconfig {
    git clone https://gist.github.com/8c33159a238b5d052fe84fecc9b5fd1e.git ~/gittemp
    mkdir -p /home/$USERNAME/.pip
    chown $USERNAME:$USERNAME /home/$USERNAME/.pip 
    chmod 755 /home/$USERNAME/.pip
    cp ~/gittemp/pip.conf /home/$USERNAME/.pip/pip.conf
    chown $USERNAME:$USERNAME /home/$USERNAME/.pip/pip.conf
    chmod 644 /home/$USERNAME/.pip/pip.conf
    rm -rf ~/gittemp
}

function setup_poetry {
    wget https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py --output-document="/home/$USERNAME/get-poetry.py"
    chown $USERNAME:$USERNAME /home/$USERNAME/get-poetry.py
    su $USERNAME -c "yes no | python /home/$USERNAME/get-poetry.py"
    rm /home/$USERNAME/get-poetry.py
}

function setup_ipython {
    su $USERNAME -c "pip install --user ipython"
    su $USERNAME -c "/home/$USERNAME/.local/bin/ipython profile create"
    git clone https://gist.github.com/02801160aadb5089d77e.git ~/gittemp
    cp ~/gittemp/ipython_config.py /home/$USERNAME/.ipython/profile_default/ipython_config.py
    chown $USERNAME:$USERNAME /home/$USERNAME/.ipython/profile_default/ipython_config.py
    chmod 644 /home/$USERNAME/.ipython/profile_default/ipython_config.py
    rm -rf ~/gittemp
}

function setup_vimrc {
    su $USERNAME -c "git clone https://github.com/Apreche/vim.git ~/.vim"
    su $USERNAME -c "ln -s ~/.vimrc ~/.vim/vimrc"
    su $USERNAME -c "pip install --user -r ~/.vim/requirements.txt"
    su $USERNAME -c "ln -s ~/.config/flake8 ~/.vim/flake8"
    su $USERNAME -c "vim +'PlugInstall --sync' +qall"
    su $USERNAME -c "echo 2 | select-editor"
}

function setup_postgres_user {
    git clone https://gist.github.com/19495f6832534bfa45bd60835a233043.git ~/gittemp
    cp ~/gittemp/create_db_user.sh /home/$USERNAME/bin/create_db_user
    chown $USERNAME:$USERNAME /home/$USERNAME/bin/create_db_user
    chmod 755 /home/$USERNAME/bin/create_db_user
    rm -rf ~/gittemp
    su postgres -c "exec /home/$USERNAME/bin/create_db_user $USERNAME"
    echo "ALTER USER $USERNAME with SUPERUSER;" | su postgres -c psql
}

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
setup_postgres_user
all_set
(sleep 30; shutdown -r -t 0) &
