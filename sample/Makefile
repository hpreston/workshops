# Sample Makefile for Workshop

setup:
	python3.6 -m venv venv
	. venv/bin/activate
	pip install -r requirements.txt
	# vboxmanage list runningvms | sed -E 's/.*\{(.*)\}/\1/' | xargs -L1 -I {} VBoxManage controlvm {} savestate
	# vagrant up
	# vagrant suspend
	#
