#! /bin/bash

mkdir -p ~/coding/temp
cd ~/coding/temp
git clone https://github.com/hpreston/vagrant_net_prog
cd vagrant_net_prog/lab
virtualenv venv --python=python2.7
source venv/bin/activate
pip install -r requirements.txt
