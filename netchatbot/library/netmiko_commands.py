""" Sample functions for gathering basic system info using netmiko.

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

from netmiko import ConnectHandler
import re
import sys


def get_interface_details(
    device_address, device_type, username, password, interface
):
    """Retrieve the Interface Configuration
    """
    # Create a CLI command template
    show_interface_config_temp = "show running-config interface {}"

    # Open CLI connection to device
    with ConnectHandler(
        ip=device_address,
        username=username,
        password=password,
        device_type=device_type,
    ) as ch:

        # Create desired CLI command and send to device
        command = show_interface_config_temp.format(interface)
        interface = ch.send_command(command)

        # Return the info
        return interface
