#!/bin/bash
ip link set wlan0 up
ip addr add 192.168.4.1/24 dev wlan0
systemctl restart hostapd
systemctl restart dnsmasq
cd /home/barudan-pi/wifi-setup/web || exit
python3 portal.py