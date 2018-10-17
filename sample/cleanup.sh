#! /bin/bash

echo "Destroying Vagrant Environment"
vagrant destroy -f
echo " "

echo "Deleting Python 3 Virtual Environment"
rm -Rf venv
echo " "
