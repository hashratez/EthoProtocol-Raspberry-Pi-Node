# EthoProtocol-Raspberry-Pi-Node
How to run a EthoProtocol Node on a Raspberry Pi

Get the upgrade script from the EthoProtocol Node Dashboard, it will look something like this:

```
mkdir -p /tmp/ethoprotocol && cd /tmp/ethoprotocol
rm -rf upgrade-debian.sh && wget https://nodes.ethoprotocol.com/download/upgrade-debian.sh
chmod +x upgrade-debian.sh
./upgrade-debian.sh -n 'gatewaynode' -u 'cdbd1320bab64184d8022af65fe9da92df21a81d' -w '0XAFF4A8AFB0CE10057DD2534C1CF34D016DF96E11'

```
And swap out the WGET line with this:

