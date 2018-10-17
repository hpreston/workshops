# Sample Workshop Lab Guide 
This is a quick template for a hands on workshop.  

* [Lab Prerequisites](#lab-prerequisites)
* [Lab Environment Setup](#lab-environment-setup)
* [Lab Start](#lab-start)
* [Exercise: Foo](lab-foo.md)
* [Exercise: Bar](lab-bar.md)
* [Lab Cleanup](#lab-cleanup)
* [Suggested Resources](#suggested-resources)

# Lab Prerequisites 
To complete the exercises in this lab you will need to be working from a development environment that has the following tools installed and functional. 

*Example List* 

* [Vagrant](https://vagrantup.com)
* [VirtualBox](http://virtualbox.org)
* [Cisco NSO](https://developer.cisco.com/docs/nso/#!getting-nso)
* [Python 3.6+](https://python.org)
* [IOS XE 16.9.1 Vagrant Box](https://github.com/hpreston/vagrant_net_prog/tree/master/box_building#cisco-csr-1000v)

# Lab Environment Setup 
Complete these steps after installing the prerequisites to setup the environment for this workshop. 

> "Setup" is expected to be completed in advance of the actual lab by the instructor to complete time consuming steps.  

1. Clone the sample lab code down to your workstation.  And change to the lab directory.  

    ```bash
    git clone https://github.com/hpreston/workshops
    cd workshops/sample
    ```

1. Run `./setup.sh` to initialize the lab environment.  This will do the following: 
    * Create Python virtual environment, activate, and install requirements 
    * Suspend any running VirtualBox VMs 
    * Start Vagrant Environment 
    * Suspend Vagrant Environment 

    <details>
    <summary>Sample Setup Output</summary>
    <pre>
    Setting up the workstation environment for the lab.
    
    Creating Python 3 Virtual Environment
    Collecting requests==2.19.1 (from -r requirements.txt (line 1))
      Using cached https://files.pythonhosted.org/packages/65/47/7e02164a2a3db50ed6d8a6ab1d6d60b69c4c3fdf57a284257925dfc12bda/requests-2.19.1-py2.py3-none-any.whl
    Collecting idna<2.8,>=2.5 (from requests==2.19.1->-r requirements.txt (line 1))
      Using cached https://files.pythonhosted.org/packages/4b/2a/0276479a4b3caeb8a8c1af2f8e4355746a97fab05a372e4a2c6a6b876165/idna-2.7-py2.py3-none-any.whl
    Collecting certifi>=2017.4.17 (from requests==2.19.1->-r requirements.txt (line 1))
      Using cached https://files.pythonhosted.org/packages/56/9d/1d02dd80bc4cd955f98980f28c5ee2200e1209292d5f9e9cc8d030d18655/certifi-2018.10.15-py2.py3-none-any.whl
    Collecting urllib3<1.24,>=1.21.1 (from requests==2.19.1->-r requirements.txt (line 1))
      Using cached https://files.pythonhosted.org/packages/bd/c9/6fdd990019071a4a32a5e7cb78a1d92c53851ef4f56f62a3486e6a7d8ffb/urllib3-1.23-py2.py3-none-any.whl
    Collecting chardet<3.1.0,>=3.0.2 (from requests==2.19.1->-r requirements.txt (line 1))
      Using cached https://files.pythonhosted.org/packages/bc/a9/01ffebfb562e4274b6487b4bb1ddec7ca55ec7510b22e4c51f14098443b8/chardet-3.0.4-py2.py3-none-any.whl
    Installing collected packages: idna, certifi, urllib3, chardet, requests
    Successfully installed certifi-2018.10.15 chardet-3.0.4 idna-2.7 requests-2.19.1 urllib3-1.23
    You are using pip version 9.0.3, however version 18.1 is available.
    You should consider upgrading via the 'pip install --upgrade pip' command.
    
    Suspending any running VirtualBox VMs
    
    Initializing Vagrant Environment
    Bringing machine 'iosxe1' up with 'virtualbox' provider...
    ==> iosxe1: Importing base box 'iosxe/16.09.01'...
    ==> iosxe1: Matching MAC address for NAT networking...
    ==> iosxe1: Setting the name of the VM: sample_iosxe1_1539737120462_38285
    ==> iosxe1: Clearing any previously set network interfaces...
    ==> iosxe1: Preparing network interfaces based on configuration...
        iosxe1: Adapter 1: nat
        iosxe1: Adapter 2: intnet
        iosxe1: Adapter 3: intnet
    ==> iosxe1: Forwarding ports...
        iosxe1: 830 (guest) => 3123 (host) (adapter 1)
        iosxe1: 80 (guest) => 2224 (host) (adapter 1)
        iosxe1: 443 (guest) => 3125 (host) (adapter 1)
        iosxe1: 8443 (guest) => 3126 (host) (adapter 1)
        iosxe1: 22 (guest) => 3122 (host) (adapter 1)
    ==> iosxe1: Running 'pre-boot' VM customizations...
    ==> iosxe1: Booting VM...
    ==> iosxe1: Waiting for machine to boot. This may take a few minutes...
        iosxe1: SSH address: 127.0.0.1:3122
        iosxe1: SSH username: vagrant
        iosxe1: SSH auth method: private key
    ==> iosxe1: Machine booted and ready!
    ==> iosxe1: Checking for guest additions in VM...
        iosxe1: No guest additions were detected on the base box for this VM! Guest
        iosxe1: additions are required for forwarded ports, shared folders, host only
        iosxe1: networking, and more. If SSH fails on this machine, please install
        iosxe1: the guest additions and repackage the box to continue.
        iosxe1:
        iosxe1: This is not an error message; everything may continue to work properly,
        iosxe1: in which case you may ignore this message.
    
    ==> iosxe1: Machine 'iosxe1' has a post `vagrant up` message. This is a message
    ==> iosxe1: from the creator of the Vagrantfile, and not from Vagrant itself:
    ==> iosxe1:
    ==> iosxe1:
    ==> iosxe1:     Welcome to the IOS XE VirtualBox.
    ==> iosxe1:     To connect to the XE via ssh, use: 'vagrant ssh'.
    ==> iosxe1:     To ssh to XE's NETCONF or RESTCONF agent, use:
    ==> iosxe1:     'vagrant port' (vagrant version > 1.8)
    ==> iosxe1:     to determine the port that maps to the guestport,
    ==> iosxe1:
    ==> iosxe1:     The password for the vagrant user is vagrant
    ==> iosxe1:
    ==> iosxe1:     IMPORTANT:  READ CAREFULLY
    ==> iosxe1:     The Software is subject to and governed by the terms and conditions
    ==> iosxe1:     of the End User License Agreement and the Supplemental End User
    ==> iosxe1:     License Agreement accompanying the product, made available at the
    ==> iosxe1:     time of your order, or posted on the Cisco website at
    ==> iosxe1:     www.cisco.com/go/terms (collectively, the 'Agreement').
    ==> iosxe1:     As set forth more fully in the Agreement, use of the Software is
    ==> iosxe1:     strictly limited to internal use in a non-production environment
    ==> iosxe1:     solely for demonstration and evaluation purposes. Downloading,
    ==> iosxe1:     installing, or using the Software constitutes acceptance of the
    ==> iosxe1:     Agreement, and you are binding yourself and the business entity
    ==> iosxe1:     that you represent to the Agreement. If you do not agree to all
    ==> iosxe1:     of the terms of the Agreement, then Cisco is unwilling to license
    ==> iosxe1:     the Software to you and (a) you may not download, install or use the
    ==> iosxe1:     Software, and (b) you may return the Software as more fully set forth
    ==> iosxe1:     in the Agreement.
    
    Suspending Vagrant Environment
    ==> iosxe1: Saving VM state and suspending execution...
    
    Setup complete.  To begin the lab run:
    
     source start
    </pre>
    </details>

# Lab Start 
When ready to run this lab, follow these steps.  

1. Run `source start` to prepare the workstation.  This will do the following: 
    * Activate the pre-create virtual environment 
    * Resume the Vagrant Environment 
    * Open the Lab Guide in an Incognito Chrome Window 
    * Open Webex Teams Developer Page in Incognito Chrome Window Make 

    <details>
    <summary>Sample Start Output</summary>
    <pre>
    Preparing the Workstation to Run this lab
    
    Note: This command script should be run with 'source start'
    to prepare the active terminal session.
    
    Activating Python Virtual Environment
    
    Resuming Vagrant Environment
    Bringing machine 'iosxe1' up with 'virtualbox' provider...
    ==> iosxe1: Resuming suspended VM...
    ==> iosxe1: Booting VM...
    ==> iosxe1: Waiting for machine to boot. This may take a few minutes...
        iosxe1: SSH address: 127.0.0.1:3122
        iosxe1: SSH username: vagrant
        iosxe1: SSH auth method: private key
    ==> iosxe1: Machine booted and ready!
    ==> iosxe1: Machine already provisioned. Run `vagrant provision` or use the `--provision`
    ==> iosxe1: flag to force provisioning. Provisioners marked to run always will still run.
    
    ==> iosxe1: Machine 'iosxe1' has a post `vagrant up` message. This is a message
    ==> iosxe1: from the creator of the Vagrantfile, and not from Vagrant itself:
    ==> iosxe1:
    ==> iosxe1:
    ==> iosxe1:     Welcome to the IOS XE VirtualBox.
    ==> iosxe1:     To connect to the XE via ssh, use: 'vagrant ssh'.
    ==> iosxe1:     To ssh to XE's NETCONF or RESTCONF agent, use:
    ==> iosxe1:     'vagrant port' (vagrant version > 1.8)
    ==> iosxe1:     to determine the port that maps to the guestport,
    ==> iosxe1:
    ==> iosxe1:     The password for the vagrant user is vagrant
    ==> iosxe1:
    ==> iosxe1:     IMPORTANT:  READ CAREFULLY
    ==> iosxe1:     The Software is subject to and governed by the terms and conditions
    ==> iosxe1:     of the End User License Agreement and the Supplemental End User
    ==> iosxe1:     License Agreement accompanying the product, made available at the
    ==> iosxe1:     time of your order, or posted on the Cisco website at
    ==> iosxe1:     www.cisco.com/go/terms (collectively, the 'Agreement').
    ==> iosxe1:     As set forth more fully in the Agreement, use of the Software is
    ==> iosxe1:     strictly limited to internal use in a non-production environment
    ==> iosxe1:     solely for demonstration and evaluation purposes. Downloading,
    ==> iosxe1:     installing, or using the Software constitutes acceptance of the
    ==> iosxe1:     Agreement, and you are binding yourself and the business entity
    ==> iosxe1:     that you represent to the Agreement. If you do not agree to all
    ==> iosxe1:     of the terms of the Agreement, then Cisco is unwilling to license
    ==> iosxe1:     the Software to you and (a) you may not download, install or use the
    ==> iosxe1:     Software, and (b) you may return the Software as more fully set forth
    ==> iosxe1:     in the Agreement.
    
    Opening Incognito browser windows for lab
    No matching processes belonging to you were found
    </pre>
    </details>
    
    
# Lab Cleanup 
After running the lab, follow these steps to reset the environment to potentially `setup` and `start` again.  

1. Run `./cleanup.sh` to fully reset the environment.  The following will be done: 
    * Destroy the Vagrant Environment 
    * Delete the Python 3 Virtual Environment.  

    <details>
    <summary>Sample Cleanup Output</summary>
    <pre>
    Destroying Vagrant Environment
    ==> iosxe1: Forcing shutdown of VM...
    ==> iosxe1: Destroying VM and associated drives...
    
    Deleting Python 3 Virtual Environment
    </pre>
    </details>
