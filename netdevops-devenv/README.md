# NetDevOps Development Environments with Vagrant, VIRL and Cisco NSO
Every network engineer needs a lab environment to explore APIs, test code, and experiment with new ideas and technologies.  The days of dumpster diving, and trolling E-bay for old and outdated hardware are a thing of the past when you open up to the possibilities of NetDevOps Development Environments.  In this hands on workshop you’ll get a chance to explore three options from the Open Source (Vagrant) and Cisco portfolio (VIRL and NSO) that provide robust DevOps style methods for quickly instantiating development networks ranging from one or two devices up through topologies mirroring realistic production networks. And even better, you’ll leave with all the knowledge and resources needed to make these part of your own day to day workflow.

* [Lab Setup and Prerequisites](#lab-setup-and-prerequisites)
* [Exercise: Vagrant](lab-vagrant.md)
* [Exercise: Cisco NSO netsim](lab-netsim.md)
* [Exercise: Cisco VIRL/CML](lab-virl.md)
* [Lab Cleanup](#lab-cleanup)
* [Suggested Resources](#suggested-resources)


# Lab Setup and Prerequisites
## Prerequisites 
To complete the exercises in this lab you will need to be working from a development environment that has the following tools installed and functional. 

* [Vagrant](https://vagrantup.com)
* [VirtualBox](http://virtualbox.org)
* [Cisco NSO](https://developer.cisco.com/docs/nso/#!getting-nso)
* [Cisco VIRL](https://virl.cisco.com)
* [Python 3.6+](https://python.org)

To make this lab easy to consume, the exercises can be executed leveraging [DevNet Sandboxes](https://developer.cisco.com/sandbox). 

* [DevBox Sandbox](http://cs.co/sbx-devbox) - **Exercise: Vagrant**
* [Multi-IOS Sandbox](http://cs.co/sbx-multi) - **Exercise: Cisco NSO netsim** & **Exercise: VIRL/CML**

## Guided Lab Setup
If you are completing this lab as part of a guided lab at an in person or online event you will have been assigned a lab pod.  Along with your instructor, complete these steps to connect to your pod. 

1. Establish VPN connection to your assigned pod.  

1. Clone the sample lab code down to your workstation.  And change to the lab directory.  

    ```bash
    git clone https://github.com/hpreston/workshops
    cd workshops/netdevops-devenv
    ```

1. Create a Python 3 virtual environment, activate, and install the requirements.  

    ```bash
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    ```

<!--## Pre-workshop start steps for timing.  

1. `vagrant up && vagrant suspend`
1. `virl up --provision && virl generate ansible`
-->


# Lab Cleanup

1. Run `./cleanup.sh` to ensure the lab is fully shutdown and cleared.  

    ```bash
    ./cleanup.sh 
    ```

# Suggested Resources