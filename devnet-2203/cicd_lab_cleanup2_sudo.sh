#! /bin/bash

echo "Step 2: Killing VPN Connection to Pod"
cd ~/code/ciscolive_workshops/devnet-2203
OCPID=$(cat openconnect_pid.txt)
kill ${OCPID}
rm openconnect_pid.txt
