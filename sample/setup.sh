#! /bin/bash

echo "Setting up the workstation environment for the lab."
echo " "

echo "Creating Python 3 Virtual Environment"
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
echo " "

echo "Suspending any running VirtualBox VMs"
vboxmanage list runningvms | sed -E 's/.*\{(.*)\}/\1/' | xargs -L1 -I {} VBoxManage controlvm {} savestate
echo " "

echo "Initializing Vagrant Environment"
vagrant up
echo " "

echo "Suspending Vagrant Environment "
vagrant suspend
echo " "

echo "Setup complete.  To begin the lab run: "
echo " "
echo " source start"
echo " "
