"""Sample code using the functions in the library/system_info folder.
Meant to be run in "interactive" mode to explore the data models available.

ex: ipython -i pyats_explore.py

Copyright (c) 2018 Cisco and/or its affiliates.
This software is licensed to you under the terms of the Cisco Sample
Code License, Version 1.0 (the "License"). You may obtain a copy of the
License at
               https://developer.cisco.com/docs/licenses
All use of the material herein must be in accordance with the terms of
the License. All rights not expressly granted by the License are
reserved. Unless required by applicable law or agreed to separately in
writing, software distributed under the License is distributed on an "AS
IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
or implied.
"""

from ats.topology import loader
from library.system_info import *


testbed = 'pyats-testbed.yaml'
testbed = loader.load(testbed)
testbed = Genie.init(testbed)

n9k = testbed.devices['NetChatBot1']
n9k.connect()
n9k.execute('show version')

n9k_platform = get_platform_info(n9k)
n9k_interfaces = get_interfaces(n9k)
n9k_routing = get_routing_info(n9k)
n9k_ospf = get_ospf_info(n9k)
n9k_vlans = get_vlans(n9k)
n9k_crc_errors = crc_errors(n9k)
n9k_arps = get_arps(n9k)

print("\n\n")
print("We've now gathered a lot of details about our device with pyATS and made them available to use.")
print("Here we'll use some of the details.\n\n")


print("First let's look at some details about the OSPF interfaces configured.")
for interface, details in n9k_ospf["vrf"]["default"]["address_family"]["ipv4"]["instance"]["1"]["areas"]["0.0.0.0"]["interfaces"].items():
    print("Interface {} has cost of {}, is a {} interface, and passive state is {}".format(interface, details["cost"], details["interface_type"], details["passive"]))
print("--------------------------------------------------------------------------------\n")

print("Now we'll look at the next hops for all ipv4 routes in the routing default vrf table")
for prefix, details in n9k_routing["vrf"]["default"]["address_family"]["ipv4"]["routes"].items():
    print("For prefix {} the next hop is {} out interface {}.".format(prefix,
    details["next_hop"]["next_hop_list"][1]["next_hop"],
    details["next_hop"]["next_hop_list"][1]["outgoing_interface"]
    )
    )
print("--------------------------------------------------------------------------------\n")
