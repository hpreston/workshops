# Vagrant
Vagrant is an Open Source command line utility designed for software developers to quickly instantiate and test software in consistent development environments.  It controls a variety of "providers" which offer the virtualization technology for hosting the environments.  Common providers are VirtualBox and Docker, though many others are available.  

## Pre-Lab Setup 
The exercises in this lab assume that you have already created and added Vagrant Boxes (ie source templates) to your workstation. If you are completing the lab as part of a guided lab, this step has already been done for you.  If you are working on this lab on your own, you will need to create and add boxes for `iosxe/16.09.01` and `nxos/9.2.1` before beginning the lab.  

See these resources for the information needed to complete these steps. 

* [DevNet Learning Lab: Vagrant Up for Network Engineers](http://cs.co/lab-vagrant)
* [Hank's Vagrant Box Building Guide on GitHub](https://github.com/hpreston/vagrant_net_prog/tree/master/box_building)

## Lab Steps

1. Starting from the `netdevops-devenv` directory.  
1. Change into the `vagrant` directory

    ```bash
    cd vagrant
    ```

1. Explore what Vagrant Boxes are available on the system.  

    ```bash
    vagrant box list
    ```

1. Start the Vagrant environment.  

    ```bash
    vagrant up
    ```

    * ***Note: This can take some time to complete, and will generate an error about timeout connecting to the NX-OS device.  When you see this error, enter `vagrant up` again to complete.***
    * ***Note: The initial `vagrant up` may have already been completed before starting the lab and devices `suspended` to save time.***

1. Open up the `Vagrantfile`.  Answer these questions.  
    * How many network devices will be in this environment?
    * What types will they be?  
    * How are they networked together?  
    * On what port will SSH be running?  NETCONF?  HTTPS?

1. Open up **Activity Monitor** and view how much memory is being used by VirtualBox.  

1. SSH to the devices to verify that they are up and working.  

    ```bash
    vagrant ssh iosxe1

    vagrant ssh nxos1
    ```

1. If `nxos1` doesn't respond, it is likely still booting up.  You can verify and watch by telnetting to the console port.  

    ```bash
    telnet 127.0.0.1 2023
    ```

1. Run the sample Ansible Playbook to send some configuration to the devices.  

    ```bash
    ansible-playbook net-config1.yaml
    ```

1. SSH to `iosxe` and verify the configuration was sent.  Try to ping to `nxos1` on GigabitEthernet2.  Did it work?  

1. Destroy the network.  

    ```bash
    vagrant destroy -f
    ```

## Section Summary and Key Points
Vagrant is a very useful tool for exploring network device APIs and learning about automation capabilities.  It has many advantages for the developer.  

1. Can run completely locally.  
2. Is near equivalent to features available on production and physical equipment.
3. Easily installed and available to developers. *Though getting access to box images takes a bit more time*

However it has some limitations as a practical tool for full scale development environments for NetDevOps.  

1. Significant memory load on development workstation.
2. Limited size of network topologies.
3. Data plane between network devices can be questionable.  
