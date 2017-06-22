#! /bin/bash

echo "This script will setup the workstation to run DevNet Workshop: " 
echo "    DEVNET-2203 "
echo " "

echo "What is your assigned Dev Number? (ie 1, 2, 3, etc)"
read DEVNUMBER 

echo "Setting up for account 'labdev${DEVNUMBER}'.  Is this correct? y/n"
read CONFIRM 

if [${CONFIRM} != "y"]
then 
    echo "Canceling setup" 
    exit 1
fi

echo "Beginning Setup"
echo " " 
echo "Step 1: Pull down lab code." 
mkdir ~/coding
cd ~/coding 
git clone http://labdev${DEVNUMBER}@cleur-gogs.lab.apps.imapex.io/labdev${DEVNUMBER}/cicd_demoapp
cd cicd_demoapp
git config user.email "labdev${DEVNUMBER}@imapex.io"
git config user.name "Lab Dev${DEVNUMBER}"


echo " " 
echo "Step 2: Backup lab files for cleanup" 
mkdir backups
cp testing.py backups/testing.py 
cp demoapp.py backups/demoapp.py 

echo " " 
echo "Step 3: Open lab_notes.txt file" 
open lab_notes.txt  

echo " " 
echo "Step 4: Open Browser Window for Tools" 
open http://cleur-gogs.lab.apps.imapex.io \
    http://cleur-drone.lab.apps.imapex.io \
    https://web.ciscospark.com \
    -a /Applications/Google\ Chrome.app/

echo " " 
echo "Setup complete." 
echo "  Your lab account information is: " 
echo "    Username: labdev${DEVNUMBER}" 
echo "    Password: Ask Instructor "
echo "    Email: labdev${DEVNUMBER}@imapex.io" 
echo " " 
echo "Execute this command to move into the coding directory for the lab"
echo "   cd ~/coding/cicd_demoapp "
echo " "