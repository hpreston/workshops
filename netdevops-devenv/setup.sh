#! /bin/bash

echo "Press ENTER when USB stick installed"
echo ""
read CONFIRM
echo ""

echo "Please connect to your VPN using the pod info."
echo "Press ENTER when connected"
open /Applications/Cisco/Cisco\ AnyConnect\ Secure\ Mobility\ Client.app/
echo ""
read CONFIRM
echo ""

echo "Please confirm there are no running Vagrant environments."
echo " If there are, please `vagrant suspend` them before continuing."
echo " "
vagrant global-status
echo " "
echo "Press ENTER when ready to continue"
read CONFIRM

echo "Cloning the code samples to your computer"
cd ~
git clone https://github.com/hpreston/ciscolive_workshops
cd ~/ciscolive_workshops/netdevops-devenv
echo ""

echo "Setting up Python Virtual Environment"
python3 -m venv venv
source ~/ciscolive_workshops/netdevops-devenv/venv/bin/activate
pip install -r requirements.txt

echo "Adding needed Vagrant Boxes to Inventory"
vagrant box add -f --name nxos/9.2.1 /Volumes/HANKLAB/files/vagrant/nxosv-final.9.2.1.box
vagrant box add -f --name iosxe/16.09.01 /Volumes/HANKLAB/files/vagrant/serial-csr1000v-universalk9.16.09.01.box
echo " "

echo "Starting, then Suspending the Vagrant Environment for Lab"
echo "  Note: Red text and as an 'error' is expected"
cd ~/ciscolive_workshops/netdevops-devenv/vagrant
vagrant up
vagrant suspend
echo ""
vagrant status
echo ""

echo "Installing NSO 4.7"
cd /Volumes/HANKLAB/files/nso/4_7/
chmod +x *.bin
./nso-4.7.darwin.x86_64.installer.bin --local-install ~/ncs47
source ~/ncs47/ncsrc
rm -Rf ~/ncs47/packages/neds/cisco*
cd ~/ncs47/packages/neds
tar -zxvf /Volumes/HANKLAB/files/nso/4_7/ncs-4.7-cisco-ios-6.0.12.tar.gz
tar -zxvf /Volumes/HANKLAB/files/nso/4_7/ncs-4.7-cisco-iosxr-7.0.10.tar.gz
tar -zxvf /Volumes/HANKLAB/files/nso/4_7/ncs-4.7-cisco-nx-5.5.2.tar.gz


echo "Pre-staging the VIRL simulation"
cd ~/ciscolive_workshops/netdevops-devenv/virl
CURRENT_SIM=$(virl ls --all | awk '/sbx_nxos/ { print $2 }')
# echo "Current Sim Name: ${CURRENT_SIM}"
if [ ! -z ${CURRENT_SIM} ]
then
  echo "  Shutting down default simulation from pod."
  virl down --sim-name ${CURRENT_SIM}
  # Pausing for 10 seconds to clear simulation
  sleep 10
fi
echo "Starting VIRL Simulation and generating inventory."
virl up virlfiles/core-dist-access --provision
virl generate ansible
echo " "
virl nodes
echo " "
echo "If any nodes show 'UNREACHABLE' please fix them."
echo "  1) virl console NODE and boot"
echo "  2) virl stop NODE && virl start NODE"
echo " "

echo "Complete!!!"
echo "  To begin the lab run these commands."
echo " "
echo "  cd ~/ciscolive_workshops/netdevops-devenv"
echo "  source venv/bin/activate"
