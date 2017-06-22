#! /bin/bash

echo "This script will reset the workstation to run DevNet Workshop: " 
echo "    DEVNET-2203 "
echo " "

echo "What is your assigned Dev Number? (ie 1, 2, 3, etc)"
read DEVNUMBER 
UNIVERSE_URL="http://cleurcicd-labdev${DEVNUMBER}.sandbox.imapex.io/hello/universe"

echo "Setting up for account 'labdev${DEVNUMBER}'.  Is this correct? y/n"
read CONFIRM 

if [${CONFIRM} != "y"]
then 
    echo "Canceling setup" 
    exit 1
fi


echo " " 
echo "Step 1: Reset application code and tests" 
cd ~/coding/cicd_demoapp
cp -f backups/testing.py testing.py
cp -f backups/demoapp.py demoapp.py 
git add testing.py demoapp.py 
git commit -m "Reset Application to Start"
git push 

echo " " 
echo "Checking if reset is complete."
HTTP_STATUS=$(curl -sL -w "%{http_code}" "${UNIVERSE_URL}" -o /dev/null)
while [ $HTTP_STATUS -ne 404 ]
do
    HTTP_STATUS=$(curl -sL -w "%{http_code}" "${UNIVERSE_URL}" -o /dev/null)
    echo "App reset not complete, checking again in 30 seconds. "
    sleep 30
done
echo
echo "Application reset complete."
echo

echo " " 
echo "Step 2: Deactivate Repo in Drone." 
echo "  Press Enter to go to the Drone web interface.  "
echo "  Once open, login as the lab user (if needed) and " 
echo "  scroll to the bottom of the Settings page and click " 
echo "  DELETE to deactivate the repo in Drone."
echo " "
echo "  Once deactivated, return to this window and confirm." 

read ENTER 

open "http://cleur-drone.lab.apps.imapex.io/labdev${DEVNUMBER}/cicd_demoapp/settings" \
    -a /Applications/Google\ Chrome.app/

echo " " 
echo "Did you deactivate the repo in Drone?  y/n"
read CONFIRM 
while [ ${CONFIRM} != "y" ]
do
    echo "Please deactivate the repo in Drone " 
    open "http://cleur-drone.lab.apps.imapex.io/labdev${DEVNUMBER}/cicd_demoapp/settings" \
        -a /Applications/Google\ Chrome.app/
    echo " " 
    echo "Did you deactivate the repo in Drone?  y/n"
    read CONFIRM 
done

echo " " 
echo "Step 3: deleting the .drone.yml file" 
rm .drone.yml
git add .drone.yml
git commit -m "Removing .drone.yml to delete pipeline" 
git push

echo " " 
echo "Step 4: Deleting the local code repository" 
cd ~/coding 
rm -Rf cicd_demoapp 

echo " " 
echo "Step 5: Quitting Google Chrome" 
osascript -e 'quit app "Google Chrome"'

echo " " 
echo "All done, lab has been reset and workstation cleared"
echo " " 