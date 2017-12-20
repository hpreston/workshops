#! /bin/bash

echo "This script will setup the workstation to run DevNet Workshop: "
echo "    DEVNET-2203 "
echo " "
echo " This script establishes VPN connection to Sandbox "
echo " and must be run with 'sudo'."
echo " "

echo "What is your assigned Pod Number? (ie 1, 2, 3, etc)"
read DEVNUMBER

echo "What is the VPN Password? (Instructor will provide)"
read VPNPASSWORD

# VPN User Account
VPNUSER=hapresto

echo "Setting up for Pod 'rave${DEVNUMBER}'.  Is this correct? y/n"
read CONFIRM

if [${CONFIRM} != "y"]
then
    echo "Canceling setup"
    exit 1
fi

echo "Step 2: Establish VPN Connection to Pod"
echo "${VPNPASSWORD}" | \
openconnect -u ${VPNUSER} \
  -b \
  --pid-file openconnect_pid.txt \
  --passwd-on-stdin \
  --no-dtls \
  --servercert sha256:1795855fced9de6659b8fe18cb293a22ed1f2717da581daa8c9439c126961a80 \
  devnetsandboxlabs.cisco.com/rave${DEVNUMBER}

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

echo "Lab VPN Connection Successful."
echo "  If instructed, run this command to complete setup. (No 'sudo')"
echo " "
echo "    ./cicd_lab_setup2.sh"
echo " "
echo "  To start the lab run this command."
echo " "
echo "  source lab_start"
