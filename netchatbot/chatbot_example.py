# -*- coding: utf-8 -*-
"""
Sample code for creating a network management chatbot.

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

import os
import requests
from webexteamsbot import TeamsBot
from webexteamsbot.models import Response
from ats.topology import loader
from library.system_info import *
from library.netmiko_commands import *

# Retrieve required details from environment variables
# Bot Details
bot_email = os.getenv("TEAMS_BOT_EMAIL")
teams_token = os.getenv("TEAMS_BOT_TOKEN")
bot_url = os.getenv("TEAMS_BOT_URL")
bot_app_name = os.getenv("TEAMS_BOT_APP_NAME")
testbed_file = os.getenv("TESTBED_FILE")
device_name = os.getenv("TESTBED_DEVICE")

# Managed Device Details - Used for netmiko connection
device_address = os.getenv("DEVICE_ADDRESS")
device_type = os.getenv("DEVICE_TYPE")
device_username = os.getenv("DEVICE_USERNAME")
device_password = os.getenv("DEVICE_PASSWORD")

# Setup pyATS and Genie device
testbed = testbed_file
testbed = loader.load(testbed)
testbed = Genie.init(testbed)
device = testbed.devices[device_name]

# Create a Bot Object
#   Note: debug mode prints out more details about processing to terminal
bot = TeamsBot(
    bot_app_name,
    teams_bot_token=teams_token,
    teams_bot_url=bot_url,
    teams_bot_email=bot_email,
    debug=True,
)


# Create a function to respond to messages that lack any specific command
# The greeting will be friendly and suggest how folks can get started.
def greeting(incoming_msg):
    # Loopkup details about sender
    sender = bot.teams.people.get(incoming_msg.personId)

    # Retrieve Platform details
    platform = get_platform_info(device)

    # Create a Response object and craft a reply in Markdown.
    response = Response()
    response.markdown = "Hello {}, I'm a friendly network switch.  ".format(
        sender.firstName
    )
    response.markdown += "My name is **{}**, and my serial number is **{}**. ".format(
        platform.device.name, platform.chassis_sn
    )
    response.markdown += "\n\nSee what I can do by asking for **/help**."
    return response


# Create functions that will be linked to bot commands to add capabilities
# ------------------------------------------------------------------------
def check_crc_errors(incoming_msg):
    """See if any interfaces have CRC Errors
    """
    response = Response()
    device_crc_errors = crc_errors(device)

    if len(device_crc_errors) > 0:
        response.markdown = "The following interfaces have CRC errors:\n\n"
        for interface, counters in device_crc_errors.items():
            crc = counters["in_crc_errors"]
            response.markdown += "Interface {} has {} errors.".format(
                interface, crc
            )
    else:
        response.markdown = "No CRC Errors found"

    return response


def vlan_list(incoming_msg):
    """Return the list of VLANs configured on device
    """
    response = Response()
    vlan_list = get_vlans(device)

    response.markdown = "I have the following VLANs configured: "
    for vlan, details in vlan_list.items():
        response.markdown += "`{} - {}`, ".format(vlan, details["name"])
    # Trim the last comma
    response.markdown = response.markdown[:-2]
    return response


def vlan_interfaces(incoming_msg):
    """Return the interfaces configured for a given vlan.
       Will look for a VLAN id as the FIRST contents following the command in
       the message.
    """
    response = Response()

    vlan_to_check = bot.extract_message(
        "/vlan-interfaces", incoming_msg.text
    ).strip()
    vlan_to_check = vlan_to_check.split()[0]

    # Get VLAN details from device
    vlans = get_vlans(device)

    # If the vlan provided is configured
    if vlan_to_check in list(vlans.keys()):
        # Reply back with the list of interfaces in a vlan
        response.markdown = "The following interfaces are configured for VLAN ID {}.\n\n".format(
            vlan_to_check
        )
        for interface in vlans[vlan_to_check]["interfaces"]:
            response.markdown += "* {}\n".format(interface)

    # Next get vlan list, and process for given vlan.
    return response


# Create help message for vlan_interfaces command
vlan_interfaces_help = "See what interfaces are configured for a given vlan. "
vlan_interfaces_help += "_Example: **/vlan-interfaces 301**_"


def arp_list(incoming_msg):
    """Return the arp table from device
    """
    response = Response()
    arps = get_arps(device)

    if len(arps) == 0:
        response.markdown = "I don't have any entries in my ARP table."
    else:
        response.markdown = "Here is the ARP information I know. \n\n"
        for arp, details in arps.items():
            response.markdown += "* IP {} and MAC {} are available on interface {}.\n".format(
                arp, details["MAC Address"], details["Interface"]
            )

    return response


def netmiko_interface_details(incoming_msg):
    """Retrieve the interface details from the configuration
       using netmiko example
    """
    response = Response()

    # Find the interface to check from the incoming message
    interface_to_check = bot.extract_message(
        "/interface-config", incoming_msg.text
    ).strip()
    interface_to_check = interface_to_check.split()[0]

    # Use the netmiko function
    interface = get_interface_details(
        device_address,
        device_type,
        device_username,
        device_password,
        interface_to_check,
    )
    print(interface)

    # Create and Return the message
    response.markdown = """
    {}
    """.format(
        interface
    )
    return response


# Create help message for interface-config command
interface_config_help = "Retrieve the configuration for an interface. "
interface_config_help += "_Example: **/interface-config Ethernet1/1**_"

# Set the bot greeting.
bot.set_greeting(greeting)

# Add new commands to the box.
bot.add_command(
    "/crc", "See if any interfaces have CRC Errors.", check_crc_errors
)
bot.add_command("/vlanlist", "See what VLANs I have configured.", vlan_list)
bot.add_command("/vlan-interfaces", vlan_interfaces_help, vlan_interfaces)
bot.add_command(
    "/arplist", "See what ARP entries I have in my table.", arp_list
)
bot.add_command(
    "/interface-config", interface_config_help, netmiko_interface_details
)

# Every bot includes a default "/echo" command.  You can remove it, or any
# other command with the remove_command(command) method.
bot.remove_command("/echo")


if __name__ == "__main__":
    # Run Bot
    bot.run(host="0.0.0.0", port=5000)
