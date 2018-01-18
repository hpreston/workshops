#! /bin/bash

echo "This script will setup the workstation to run DevNet Workshop: "
echo "    DEVNET-2203 "
echo " "
echo " This script installs pre-reqs and prepares the environment "
echo " "

echo "Beginning Setup"
echo "Step 1: Installing Pre-Reqs"
echo "  - Python"
cd ~/code/ciscolive_workshops/devnet-2203
pwd
virtualenv venv --python=python2.7
source venv/bin/activate
pip install -r requirements.txt

echo "  - Ansible Roles"
ansible-galaxy install zaxos.docker-ce-ansible-role

# echo "  - SSH Pass"
# brew install https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb

echo "Step 3: Verify DevBox Accessible"
ping -c 4 10.10.20.20
if [ $? -ne 0 ]
then
    echo "DevBox Unavailable."
    echo "Please ensure active and then click anykey to continue"
    read CONFIRM
    echo "Testing Connectivity to DevBox."
    ping -c 4 10.10.20.20
    if [ $? -ne 0 ]
    then
      echo "DevBox Unavailable. Killing VPN connection and stopping setup."
      OCPID=$(cat openconnect_pid.txt)
      kill ${OCPID}
    fi
fi


echo "Step 4: Run Setup Pipeline on DevBox"
cd ~/code/ciscolive_workshops/devnet-2203/sbx_setup
ansible-playbook -u root pipeline_setup.yml

echo "Step 5: Setup VIRL for Lab"
source ~/code/ciscolive_workshops/devnet-2203/lab_env
cd ~/code/ciscolive_workshops/devnet-2203/prod_net
echo "  - Clearing Old VIRL Status"
rm -Rf ~/code/ciscolive_workshops/devnet-2203/prod_net/.virl/
echo "  - Shutting down default simulation"
virl ls --all
virl down --sim-name API-Test
echo "  - Bringing up VIRL Simulation for Prod Network"
virl up
virl nodes


echo "Step 6: Clone Down Lab Repo from Gogs "
cd ~/code/ciscolive_workshops/devnet-2203/
git clone http://netdevopsuser@10.10.20.20/gogs/netdevopsuser/network_cicd_lab

echo "Step 7: Getting local Vagrant Dev Prepped"
cd ~/code/ciscolive_workshops/devnet-2203/network_cicd_lab
vagrant up
vagrant suspend
vagrant status

echo "Setup Part 2 Complete.  "
echo "  To start the lab run this command."
echo " "
echo "  source lab_start"
