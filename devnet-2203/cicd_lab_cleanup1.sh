#! /bin/bash

echo "Beginning Cleanup"
echo "Step 7: Destroy local Vagrant Dev"
cd ~/code/ciscolive_workshops/devnet-2203/network_cicd_lab
# Can't do this in SUDO because of VirtualBox Limitation
vagrant destroy -f

echo "Step 6: Delete Lab Repo from Gogs "
cd ~/code/ciscolive_workshops/devnet-2203/
rm -Rf network_cicd_lab

echo "Step 5: Kill Prod Network VIRL for Lab"
source ~/code/ciscolive_workshops/devnet-2203/lab_env
cd ~/code/ciscolive_workshops/devnet-2203/prod_net
echo "  - Shutting Down VIRL Simulation for Prod"
virl ls
virl down

echo "Step 4: Destroy Pipeline on DevBox"
cd ~/code/ciscolive_workshops/devnet-2203/sbx_setup
ansible-playbook -u root pipeline_clear.yml

echo "Step 1: Removing Pre-Reqs"
echo "  - Python"
cd ~/code/ciscolive_workshops/devnet-2203
rm -Rf venv

echo "Cleanup Part 1 Complete.  "
echo "  Please run this command to complete cleanup. (Needs 'sudo')"
echo " "
echo "    sudo ./cicd_lab_cleanup2_sudo.sh"
echo " "
