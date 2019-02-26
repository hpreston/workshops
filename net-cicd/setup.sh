#! /bin/bash

echo "Cloning the code samples to your computer"
cd ~
git clone https://github.com/hpreston/workshops
cd ~/workshops/net-cicd
echo ""

# echo "Setting up Python Virtual Environment"
# python3 -m venv venv
# source ~/ciscolive_workshops/netdevops-devenv/venv/bin/activate
# pip install -r requirements.txt


# echo "Installing NSO 4.7"
# cd /Volumes/HANKLAB/files/nso/4_7/
# chmod +x *.bin
# ./nso-4.7.darwin.x86_64.installer.bin --local-install ~/ncs47
# source ~/ncs47/ncsrc
# rm -Rf ~/ncs47/packages/neds/cisco*
# cd ~/ncs47/packages/neds
# tar -zxvf /Volumes/HANKLAB/files/nso/4_7/ncs-4.7-cisco-ios-6.0.12.tar.gz
# tar -zxvf /Volumes/HANKLAB/files/nso/4_7/ncs-4.7-cisco-iosxr-7.0.10.tar.gz
# tar -zxvf /Volumes/HANKLAB/files/nso/4_7/ncs-4.7-cisco-nx-5.5.2.tar.gz

echo "Starting Lab Environment"
make lab

echo "Complete!!!"
