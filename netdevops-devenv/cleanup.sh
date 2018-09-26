#! /bin/bash

echo "Clear VIRL Simulation"
cd virl
virl down
rm -Rf .virl/
rm default-inventory.yaml
rm topology.yaml
cd ..

echo "Clear NSO Lab"
killall confd
killall confd
cd nso-netsim
rm -Rf netsim/
cd ..

echo "End Vagrant Simulation"
cd vagrant
vagrant destroy -f
echo " "
cd ..

echo "Disconnect from the Pod and VPN."
# open /Applications/Cisco/Cisco\ AnyConnect\ Secure\ Mobility\ Client.app/
