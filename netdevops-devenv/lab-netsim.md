# Cisco NSO netsim
Cisco NSO, or Network Service Orchestrator, is mostly known as a powerful network configuration management utility used by large enterprises and service providers.  However, with the push towards network automation and NetDevOps, many network engineers are finding its network automation and orchestration features are widely applicable to all networks.  

NSO also includes a capability called **NetSim** that can be used to instantiate large networks of many devices, of any type supported by NSO quickly.  These simulations provide management plane access only, and can be used to test network automation that leverage NSO or not.  

## Pre-Lab Setup 
The exercises in this lab assume that Cisco NSO has already been installed on your workstation.  The free, non-production version of NSO that is available on [DevNet](https://developer.cisco.com/docs/nso/#!getting-nso) is sufficient for this lab. 

## Lab Steps
1. Starting from the `netdevops-devenv` directory.  

1. Change into the `nso-netsim` directory.

    ```bash
    cd nso-netsim
    ```
    
1. Verify the NSO application is available.  
    
    ```bash
    which ncs-netsim
    
    # Example output 
    ~/ncs47/bin/ncs-netsim
    ```

    1. If a message that `no ncs-netsim` was found, `source` the `nsorc` file.  
    
        ```bash
        source ~/ncs47/ncsrc
        ``` 

1. Explore what device packages (NEDs) are available on the system.  Each listed package is an available device to be simulated.  The installed list is a small subset of what is supported by NSO.  

    ```bash
    ls -l ~/ncs47/packages/neds/
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

1. View how much memory is being used by `confd` (Each `confd` process represents a simulated device).
    * On Linux systems, you can use the command `top`
        1. Run the command `top`. 
        2. Filter for `confd` by pressing `o` to add a filter of `COMMAND=confd`. 
        3. Press `Shift-e` to change the memory units in the summary view. 
        4. Press `q ` to quit

    ```shell
    # Example
    top - 08:10:39 up 18:18,  1 user,  load average: 0.00, 0.01, 0.05
    Tasks: 144 total,   2 running, 142 sleeping,   0 stopped,   0 zombie
    %Cpu(s):  0.3 us,  0.3 sy,  0.0 ni, 99.3 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
    MiB Mem : 1838.992 total,  562.965 free,  581.418 used,  694.609 buff/cache
    MiB Swap: 2047.996 total, 2047.996 free,    0.000 used. 1070.184 avail Mem
    
      PID USER      PR  NI    VIRT    RES    SHR S %CPU %MEM     TIME+ COMMAND
    12342 develop+  20   0  892668 231320   3180 S  0.0 12.3   0:08.64 confd
    12362 develop+  20   0  699312  45452   3176 S  0.0  2.4   0:02.10 confd
    ```        

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