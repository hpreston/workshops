# Cisco VIRL or CML
Cisco VIRL and CML are platforms for designing and working with large and complex network topologies.  VIRL is targeted at "personal use" while CML is designed for enterprise multi-user environments, however both provide similar capabilities and features.  VIRL has been used by network engineers as part of their certification studies, and organizations for testing out configurations for several years, but it also provides a great opportunity for NetDevOps developers looking for a full featured dev environment.  And with the availability of `virlutils`, a Python CLI wrapper for controlling VIRL, this use has become even better.  

## Pre-Lab Setup 
The exercises in this lab assume that you have a VIRL or CML server reachable from your workstation.  If you need one, you can reserve a [DevNet Multi-IOS Sandbox](http://cs.co/sbx-multi) to work with. 

> If you are using your own VIRL/CML server, you will need to update the [`.virlrc`](virl/.virlrc) file with the address and credentials. The included file had details for the DevNet Sandbox.

## Lab Steps
1. Starting from the `netdevops-devenv` directory.

1. Change into the `virl` directory.  

    ```bash
    cd virl
    ```

1. Install `virlutils` using pip. *This library is included in [`requirements.txt`](requirements.txt) so may already show as installed.* 

    ```bash
    pip install virlutils
    ```

1. `virlutils` lets you interact with a VIRL or CML server through the command line. There are several ways to provide the address and credentials to the tool, but a common way is the use of a file `.virlrc` located in the project directory (or user home folder). Take a look at the `.virlrc` file in this project. 

    ```bash
    cat .virlrc
    
    # Output
    VIRL_HOST=10.10.20.160
    VIRL_USERNAME=guest
    VIRL_PASSWORD=guest
    ```
    
1. The settings provided are for the DevNet Sandbox instance of VIRL.  If you are using a different VIRL server, update the details as needed.  

1. First let's see if any simulations are currently running on your server.  

    ```bash
    virl ls --all
    ```

<!--***NOTE: THESE STEPS WERE COMPLETED TO SAVE TIME.***-->

1. If any are listed, `down` them with `virl down --sim-name SIMNAME`.  For example:

    ```bash
    virl down --sim-name sbx_nxos_default_h3SOrk
    ```

1. `virlutils` offers the ability to start a simulation from a GitHub repo, and the organization https://github.com/virlfiles provides a number of example simulations.  Let's see what is available.  

    ```bash
    virl search
    ```

1. Start an instance of the `virlfiles/5_router_mesh` simulation.  

    ```bash
    virl up virlfiles/5_router_mesh
    ```

<!--***END NOTE: THESE STEPS WERE COMPLETED TO SAVE TIME.***-->

1. While the simulation is booting, let's explore what `virlutils` allow the developer to do while interacting with their network.  

1. Start by checking the status of the nodes.  

    ```bash
    virl nodes
    ```

1. Let's monitor the boot status of a device.  Pick one that shows `ACTIVE` for the state.  For example `iosv-1 `.  

    ```bash
    virl console iosv-1
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
    * ***NOTE: This step may have already been completed to save time.  Before running, see if there is a file `default_inventory.yaml` in your directory.***

1. Once complete, open the file `default_inventory.yaml`.  See how the file is organized into the groups "datacenter / headquarters / branch".  

1. This is driven by an extension included in the VIRL topology file (`topology.virl`).  If you are building topologies to work with Ansible, you can simply include this key to organize into groups.  

    ```xml
    <!--- EXAMPLE --->
    <entry key="ansible_group" type="String">datacenter</entry>
    ```

1. Open the `topology.virl` file and look at how the simulation is described in the XML doc.  How would you add an additional access device?  

1. Run the included Ansible playbook, `ansible_config.yaml` against the topology.  

    ```bash
    ansible-playbook ansible_config.yaml
    ```

1. Once the playbook has completed, let's verify that it was applied.  
1. Connect to `iosv-1` and check the routing table.  

    ```bash
    virl ssh iosv-1
    ```
    * Did you see the expected banner? 

1. Check the OSPF status 

    ```
    show ip ospf neighbor
    show ip route ospf 
    ```

1. Try to ping from `iosv-1` to a loopback interface on `iosv-2`.

    ```bash
    ping 192.168.0.2
    ```

1. Disconnect from the switches and `down` the network.  

    ```bash
    virl down
    ```

## Section Summary and Key Points
Cisco VIRL and CML provide the NetDevOps developer with an excellent development environment for their work.  These simulations can be robust and align to production topologies where the automation scripts and configuration management workflows will be put to use.  Furthermore, VIRL and CML support including a variety of network and non-network devices in the topologies.  Anything providing a KVM image can be included.  

And with the addition of `virlutils`, the NetDevOps experience is made even better.  

To summarize the advantages of VIRL as the development environment:

1. Robust support for large topologies mimicking production
2. Simulations can include servers and applications in addition to network.  
3. Full data plane within the simulation to test traffic flows and protocol behavior.
4. Off-load simulation to remote server.

But there are definite caveats to consider as well.  

1. For typical uses, not a fully local dev environment.
2. Significant time to instantiate networks.
3. Not an insignificant resource requirement for large topologies.  
