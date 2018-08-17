#! /bin/bash

echo "Clear VIRL Simulation"
cd ~/ciscolive_workshops/netdevops-devenv/virl
virl down
rm -Rf .virl/
rm default-inventory.yaml
rm topology.yaml

echo "Clear NSO Lab"
killall confd
killall confd
cd ~/ciscolive_workshops/netdevops-devenv/nso-netsim
rm -Rf netsim/

echo "End Vagrant Simulation"
cd ~/ciscolive_workshops/netdevops-devenv/vagrant
vagrant destroy -f
echo " "

echo "Deleting Lab Code"
rm -Rf ~/ciscolive_workshops

echo "Disconnect from the VPN."
open /Applications/Cisco/Cisco\ AnyConnect\ Secure\ Mobility\ Client.app/
