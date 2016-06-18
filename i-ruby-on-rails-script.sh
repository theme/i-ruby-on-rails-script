#! /bin/bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

################################################################################
# System Require: Ubuntu 16.04 LTS
################################################################################

clear
echo "###########################################################################"
echo "# Install ruby on rails using rbenv"
echo "# ref: https://gorails.com/setup/ubuntu/16.04"
echo "# by: theme"
echo "# thx: quericy"
echo "###########################################################################"

# Install rails 
main(){
    rootness
    is_use_tsocks
    is_ubuntu
    install_ruby_depends
    install_rbenv
    install_ruby
    git_config
    install_nodejs
    install_rails
    # setup_SQL_server
    success_info
}

is_use_tsocks(){
    read -p 'use tsocks for gem install? (Y/n)' str
    if [ "$str" = "" ] || [ "$str" = "y" ] || [ "$str" = "Y" ]; then
        use_tsocks=0
        echo "will use tsocks for gem install."
    else
        use_tsocks=1
    fi
}

# Make sure only root can run our script
rootness(){
if [[ $EUID -eq 0 ]]; then
    echo "Error:This script (usually) should not be run as root... (edit me or quit.)" 1>&2
   exit 1
fi
}
 
# is Ubuntu?
is_ubuntu(){
    echo ">>>>> check OS"
	get_system_str=`cat /etc/issue`
    echo "$get_system_str" |grep -Fq "Ubuntu 16.04"
    if [ $? -eq 0 ]
    then
        system_str="1"
        echo "... OS = Ubuntu 16.04."
    else
        echo "Error: This Script should be running on Ubuntu 16.04 (... let me quit)"
        exit 1
    fi
}

# Install ruby depends
install_ruby_depends(){
    echo ">>>>> install_ruby_depends"
    echo " sudo "
    sudo apt-get -y update
    sudo apt-get -y install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev
}

# Install rbenv
install_rbenv(){
    echo ">>>>> install_rbenv"
    # rbenv
    if [ ! -d ~/.rbenv ]; then
        git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    elif [ ! -d ~/.rbenv/.git ]; then
        rm -r ~/.rbenv
        git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    fi

    pushd ~/.rbenv
    # git pull
    popd
     
    if [ -s ~/.bashrc ] && ! grep -Fq 'export PATH="$HOME/.rbenv/bin:$PATH"' ~/.bashrc ; then
        echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
        echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    fi

    # ruby-build
    if [ ! -d ~/.rbenv/plugins/ruby-build ]; then
        git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
    elif [ ! -d ~/.rbenv/.git ]; then
        rm -r ~/.rbenv/plugins/ruby-build
        git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
    fi
    pushd ~/.rbenv/plugins/ruby-build
    # git pull
    popd
    if [ -s ~/.bashrc ] && ! `grep -Fq 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' ~/.bashrc` ; then
        echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
    fi

    # . ~/.bashrc
    PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
    PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"
}

install_ruby(){
    echo ">>>>> install_ruby"
    if ! `ruby -v | grep -Fq 'ruby 2.3.1'`; then
        echo 'rbenv install ruby 2.3.1' 
        rbenv install 2.3.1
        rbenv global 2.3.1
        ruby -v
    else
        echo 'ruby is already installed.'
    fi
    if ! `gem list --local | grep -Fq 'bundler'`; then
        if [ $use_tsocks -eq 0 ]; then
            echo 'tsocks gem install bundler'
            tsocks gem install bundler
        else
            echo 'gem install bundler'
            gem install bundler
        fi
    else
        echo 'gem bundler is already installed.'
    fi
    rbenv rehash
}

# just print
git_conf(){
    def=`$1`
    read -p "$1 (${def})" opt
    if [ "$opt" = "" ]; then
        `$1 $def`
    else
        `$1 $opt`
    fi
}
git_config(){
    echo ">>>>> config git"
    git_conf 'git config --global color.ui'
    git_conf 'git config --global user.name'
    git_conf 'git config --global user.email'
}

install_nodejs(){
    echo ">>>>> install_nodejs"
    if ! `node -v | grep -Fq 'v4.'`; then
        echo " sudo "
        curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
        sudo apt-get install -y nodejs
    else
        echo 'nodejs is already installed'
    fi
}

# install rails
install_rails(){
    echo ">>>>> install_rails"
    if ! `gem list --local | grep -Fq 'rails'`; then
        if [ $use_tsocks -eq 0 ]; then
            echo ' tsocks gem install rails -v 4.2.6 '
            tsocks gem install rails -v 4.2.6
        else
            echo 'gem install rails -v 4.2.6'
            gem install rails -v 4.2.6
        fi

        if ! `gem list --local | grep -Fq 'rake'`; then
            echo 'gem rails install failed... (are u behind firewall?)'
            exit
        fi
    else
        echo 'gem rails is already installed'
    fi
    rbenv rehash
    rails -v
}

# info
success_info(){
    echo ">>>>> Done."
}

# run
main

