#! /bin/bash

echo "This script will reset the workstation to run DevNet Workshop: "
echo "    DEVNET-2203 "
echo " "
echo " This script clears out any remnants from previous runs of class."
echo " "

cd ~/code/ciscolive_workshops/devnet-2203
vagrant destroy -f
git reset --hard
git pull
rm -Rf ~/code/ciscolive_workshops/devnet-2203/network_cicd_lab
rm -Rf ~/code/ciscolive_workshops/devnet-2203/venv
rm -Rf ~/code/ciscolive_workshops/devnet-2203/prod_net/.virl/
