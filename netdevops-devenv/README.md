# NetDevOps Development Environments with Vagrant, VIRL and Cisco NSO
Every network engineer needs a lab environment to explore APIs, test code, and experiment with new ideas and technologies.  The days of dumpster diving, and trolling E-bay for old and outdated hardware are a thing of the past when you open up to the possibilities of NetDevOps Development Environments.  In this hands on workshop you’ll get a chance to explore three options from the Open Source (Vagrant) and Cisco portfolio (VIRL and NSO) that provide robust DevOps style methods for quickly instantiating development networks ranging from one or two devices up through topologies mirroring realistic production networks. And even better, you’ll leave with all the knowledge and resources needed to make these part of your own day to day workflow.

* [Lab Setup](#lab-setup)
* [Vagrant](#vagrant)
* [Cisco NSO netsim](#cisco-nso-netsim)
* [Cisco VIRL/CML](#cisco-virl-or-cml)
* [Lab Cleanup](#lab-cleanup)


# Lab Setup 

1. Establish VPN connection to your assigned pod.  

1. Clone the sample lab code down to your workstation.  And change to the lab directory.  

    ```bash
    git clone https://github.com/hpreston/ciscolive_workshops
    cd ciscolive_workshops/netdevops-devenv
    ```

1. Create a Python 3 virtual environment, activate, and install the requirements.  

    ```bash
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    ```
    
1. 

# Vagrant 
Vagrant is an Open Source command line utility designed for software developers to quickly instantiate and test software in consistent development environments.  It controls a variety of "providers" which offer the virtualization technology for hosting the environments.  Common providers are VirtualBox and Docker, though many others are available.  

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
    
    * ***Note: this will take some time to complete, and will generate an error about timeout connecting to the NX-OS device.  When you see this error, enter `vagrant up` again to complete.***

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

1. If `nxos1` doesn't respond, it is likely still booting up.  You can verify and watch by telneting to the console port.  

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
2. Is near equivelant to features available on production and physical equipment. 
3. Easily installed and available to developers. *Though getting access to box images takes a bit more time* 

However it has some limitations as a practical tool for full scale development environments for NetDevOps.  

1. Significant memory load on development workstation. 
2. Limited size of network topologies. 
3. Data plane between network devices can be questionable.  

# Cisco NSO netsim 
Cisco NSO, or Network Service Orchestrator, is mostly known as a powerful network configuration management utility used by large enterprises and service providers.  However, with the push towards network automation and NetDevOps, many network engineers are finding its network automation and orchestration features are widely applicable to all networks.  

NSO also includes a capability called **NetSim** that can be used to instantiate large networks of many devices, of any type supported by NSO quickly.  These simulations provide management plane access only, and can be used to test network automation that leverage NSO or not.  

1. Starting from the `netdevops-devenv` directory.  

1. Change into the `nso-netsim` directory. 

    ```bash
    cd nso-netsim
    ```
    
1. Explore what device packages (NEDs) are available on the system.  Each listed package is an available device to be simulated.  The installed list is a small subset of what is supported by NSO.  

    ```bash
    ls -l ~/ncs471/packages/neds/
    ```

1. Create a netsim simulation with 1 IOS device, and 1 NX-OS device.  

    ```bash
    ncs-netsim create-device cisco-ios iosxe1 
    ncs-netsim add-device cisco-nx nxos1 
    ```
    
1. You will now have a `netsim` directory that contains all the details about your simulated network.  Take a look at the contents.  Each device will have a folder, and in the folder are specifics about each device.  

    ```bash
    ls -l netsim/
    
    total 8
    -rw-r--r--  1 hapresto  staff  979 Aug  8 10:35 README.netsim
    drwxr-xr-x  3 hapresto  staff   96 Aug  8 10:35 iosxe1
    drwxr-xr-x  3 hapresto  staff   96 Aug  8 10:35 nxos1
    ``` 

1. Start the simulation.  This should take just a few seconds to complete.  

    ```bash
    ncs-netsim start
    
    # output 
    DEVICE iosxe1 OK STARTED
    DEVICE nxos1 OK STARTED
    ```

1. Connect to `iosxe1` with SSH.  The command is `ncs-netsim cli-c devname` 

    ```bash
    ncs-netsim cli-c iosxe1
    ```

1. As these are "simulations" not every IOS command will be present.  Often the best way to check the configuration is to look at the actual running-config.  

    ```bash
    show running-config interface
    ```

1. Exit from iosxe1 and connect to nxos1.  Look at the configuration there.  
    * NetSim will start the devices with a basic configuration.  There are ways to stage initial configurations with NetSim, but that is beyond the scope of this lab.  

1. Open up **Activity Monitor** and view how much memory is being used by `confd` (Each `confd` process represents a simulated device). 

1. Since netsim uses so little memory for each device, let's start a bigger network.  First stop the current simulation and delete.

    ```bash
    ncs-netsim stop 
    rm -Rf netsim/
    ```
    
1. Create a new simulation network with 12 IOS devices.  Then start it.  

    ```bash
    ncs-netsim create-network cisco-ios 12 iosxe
    ncs-netsim start 
    ```

1. Check the memory usage now.  

1. Exit from any device and explore the port mappings used by `netsim` for devices.  We can use this information to build and test automation scripts.  
    * You'll see that SSH (cli), netconf and snmp are all available for each device.  

    ```bash
    ncs-netsim list
    ```

1. Open `net-config2.py` in a text editor.  This is a simple `netmiko` script that will push out interface configurations to devices over CLI.  The configuration details are stored in the file `netsim_inventory.yaml`, open it up as well.  

1. Run `python net-config2.py` to execute the configuration.  Partial sample output below.  

    ```bash
    python net-config2.py

    Configuring iosxe0
    The following configuration was sent:
    config term
    Enter configuration commands, one per line. End with CNTL/Z.
    iosxe0(config)# interface GigabitEthernet1/1
    iosxe0(config-if)# ip address 172.16.0.1 255.255.255.0
    iosxe0(config-if)# no shutdown
    iosxe0(config-if)# end
    iosxe0#
    Configuring iosxe1
    The following configuration was sent:
    config term
    Enter configuration commands, one per line. End with CNTL/Z.
    iosxe1(config)# interface GigabitEthernet1/1
    iosxe1(config-if)# ip address 172.16.1.1 255.255.255.0
    iosxe1(config-if)# no shutdown
    iosxe1(config-if)# end
    iosxe1#
    ```

1. Stop the NetSim and delete the network.  

    ```bash
    ncs-netsim stop
    rm -Rf netsim/
    ```

## Section Summary and Key Points
NSO NetSim is a great tool for NetDevOps engineers who are serious about their development environment.  It's ability to quickly and efficiently generate large "networks" of a variety of devices that can be used to test out automation scripts and tools is excellent.  And though not shown here, NSO also is an excellent network configuration management tool that can help enterprises accelerate their journey towards Network as Code.  

To summarize it's advantages as a dev environment: 

1. Can run completely local
2. Relatively small impact on host resources 
3. Able to generate large numbers of simulated devices quickly 

But there are some elements to keep in mind as well.  

1. It provides a simulated management plane for the devices, so not all commands and interfaces work exactly the same.  
2. There is no data plane or device connectivity.  

# Cisco VIRL or CML
Cisco VIRL and CML are platforms for designing and working with large and complex network topologies.  VIRL is targeted at "personal use" while CML is designed for enterprise multi-user environments, however both provide similar capabilities and features.  VIRL has been used by network engineers as part of their certification studies, and organizations for testing out configurations for several years, but it also provides a great opportunity for NetDevOps developers looking for a full featured dev environment.  And with the availability of `virlutils`, a Python CLI wrapper for controlling VIRL, this use has become even better.  

1. Starting from the `netdevops-devenv` directory.

1. Change into the `virl` directory.  

    ```bash
    cd virl
    ```

1. First let's see if any simulations are currently running on your server.  

    ```bash
    virl ls --all
    ```

1. If any are listed, `down` them with `virl down --sim-name SIMNAME`.  For example: 

    ```bash
    virl down --sim-name sbx_nxos_default_h3SOrk
    ```
    
1. `virlutils` offers the ability to start a simulation from a GitHub repo, and the organization https://github.com/virlfiles provides a number of example simulations.  Let's see what is availble.  
    
    ```bash
    virl search
    ```

1. Start an instance of the `virlfiles/core-dist-access` simulation.  

    ```bash
    virl up virlfiles/core-dist-access
    ```
    
1. While the simulation is booting, let's explore what `virlutils` allow the developer to do while interacting with their network.  

1. Start by checking the status of the nodes.  

    ```bash
    virl nodes 
    ```

1. Let's monitor the boot status of `dist1`.  

    ```bash
    virl console dist1
    ``` 

1. You should see it booting up... let's not interfere with it.  Go ahead and disconnect with `^]` to get the telnet prompt, and then type "quit". 

1. Use `virl --help` to see the variety of commands that are available.  

    ```bash
    virl --help
    Usage: virl [OPTIONS] COMMAND [ARGS]...
    
    Options:
      --help  Show this message and exit.
    
    Commands:
      console   console for node
      down      stop a virl simulation
      generate  generate inv file for various tools
      id        gets sim id for local environment
      logs      Retrieves log information for the provided...
      ls        lists running simulations in the current...
      nodes     get nodes for sim_name
      pull      pull topology.virl from repo
      save      save simulation to local virl file
      search    lists virl topologies available via github
      ssh       ssh to a node
      start     start a node
      stop      stop a node
      swagger   manage local swagger ui server
      telnet    telnet to a node
      up        start a virl simulation
      use       use virl simulation launched elsewhere
      uwm       opens UWM for the sim
      version   version information
      viz       opens live visualization for the sim
    ```
    
1. There is also a `--help` for each command for more details.  

    ```bash
    virl generate --help
    
    Usage: virl generate [OPTIONS] COMMAND [ARGS]...
    
      generate inv file for various tools
    
    Options:
      --help  Show this message and exit.
    
    Commands:
      ansible  generate ansible inventory
      nso      generate nso inventory
      pyats    Generates a pyats testbed config for an...
    ```
    
    * How handy... `virlutils` can generate an Ansible inventory file for us.  We'll use that in a moment.  

1. You can also quickly launch the web interface for VIRL with `virl uwm`.  

1. By now your nodes should be coming up.  Try connecting to them with `virl ssh NODE`.  

1. Once the nodes are available, use `virl generate ansible` to create the default inventory file.  *This command can take a long time to complete*

1. Once complete, open the file `default_inventory.yaml`.  See how the file is organized into the "core / dist / access" as expected.  

1. This is driven by an extension included in the VIRL topology file (`topology.virl`).  If you are building topologies to work with Ansible, you can simply include this key to organize into groups.  

    ```xml
    <!--- EXAMPLE ---> 
    <entry key="ansible_group" type="String">distribution</entry>
    ```
    
1. Open the `topology.virl` file and look at how the simulation is described in the XML doc.  How would you add an additional access switch?  

1. Run the included Ansible playbook, `network_deploy.yaml` against the topology.  

    ```bash
    ansible-playbook network_deploy.yaml
    ```

    * If the playbook errors, run it again.  You can limit the devices or groups included by adding `-l core` to target just the core group, or `-l core1` to target just a single device.  

1. Once the playbook has completed, let's verify that the network is operating as expected.  Connect to `core1` and check the routing table.  Do you see any OSPF routes?  
    
    ```bash
    virl ssh core1
    
    show ip route
    ```

1. Try to ping from `core1` to a vlan interface on `dist2`. 

    ```bash
    ping 172.16.102.3
    ```

1. Disconnect from the switches and `down` the network.  

    ```bash
    virl down 
    ```

## Section Summary and Key Points
Cisco VIRL and CML provide the NetDevOps developer with an excellent development environment for their work.  These simulations can be robust and align to production topologies where the automation scripts and configuration management workflows will be put to use.  Furthermore, VIRL and CML support including a variety of network and non-network devices in the topologies.  Anything providing a KVM image can be included.  

And with the addition of `virlutils`, the NetDevOps experience is made even better.  

To summarize the advantages of VIRL as the development environment: 

1. Robust support for large topologies mimicing production 
2. Simulations can include servers and applications in addition to network.  
3. Full data plane within the simulation to test traffic flows and protocol behavior. 
4. Off-load simulation to remote server. 

But there are definite caveats to consider as well.  

1. For typical uses, not a fully local dev environment. 
2. Significant time to instantiate networks. 
3. Not an insignificant resource requirement for large topologies.  

# Lab Cleanup

1. Make sure all simulations are have been stopped.  

    ```bash
    # Vagrant 
    vagrant global-status 
    vagrant destroy ID
    
    # NSO NetSim
    killall confd 
    
    # Virl - from the ciscolive_workshops/netdevops_devenv/virl directory 
    virl ls --all 
    virl down 
    ```
    
1. Delete the lab repository.  

    ```bash
    cd ~
    rm -Rf ciscolive_workshops/
    ```
    
1. Disconnect from the VPN.  