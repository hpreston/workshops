from ncclient import manager
import xmltodict
import os

# Managed Device Details
device_address = os.getenv("DEVICE_ADDRESS")
device_netconf_port = os.getenv("DEVICE_NETCONF_PORT")
device_username = os.getenv("DEVICE_USERNAME")
device_password = os.getenv("DEVICE_PASSWORD")

with open("n9k-switch-baseline.xml") as f:
    baseline = f.read()


with manager.connect(
    host=device_address,
    port=device_netconf_port,
    username=device_username,
    password=device_password,
    hostkey_verify=False,
    ) as m:

    response = m.edit_config(target='running', config=baseline)
    print(response)
