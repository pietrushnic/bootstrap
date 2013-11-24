#!/bin/bash
sudo apt-get update
sudo apt-get -y install curl
curl -L https://get.rvm.io | bash -s stable --ruby
bash -l -c 'source $HOME/.rvm/scripts/rvm;gem install puppet'
