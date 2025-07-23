#!/bin/bash

echo "Iniciando Access Point"

# Configurar IP
sudo ip link set wlan0 up
sudo ifconfig wlan0 192.168.4.1

# Iniciar servicios
sudo systemctl start hostapd
sudo systemctl start dnsmasq

# Iniciar el portal
python3 /home/barudan-pi/wifi-setup-portal/web/portal.py