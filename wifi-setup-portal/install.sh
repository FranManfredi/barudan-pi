#!/bin/bash
set -e

echo "[1/6] Instalando dependencias..."
sudo apt update
sudo apt install -y hostapd dnsmasq python3 python3-pip net-tools

echo "[2/6] Parando servicios conflictivos..."
sudo systemctl stop hostapd
sudo systemctl stop dnsmasq
sudo systemctl disable dhcpcd

echo "[3/6] Configurando interfaces de red..."
sudo bash -c 'cat > /etc/dhcpcd.conf <<EOF
interface wlan0
    static ip_address=192.168.4.1/24
    nohook wpa_supplicant
EOF'

echo "[4/6] Configurando dnsmasq..."
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
sudo cp dnsmasq.conf /etc/dnsmasq.conf

echo "[5/6] Configurando hostapd..."
sudo cp hostapd.conf /etc/hostapd/hostapd.conf
sudo bash -c 'cat > /etc/default/hostapd <<EOF
DAEMON_CONF="/etc/hostapd/hostapd.conf"
EOF'

echo "[6/6] Habilitando servicios..."
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl enable dnsmasq

echo "Instalando portal web..."
cd web
pip3 install flask
cd ..

echo "Creando script de inicio..."
sudo bash -c 'cat > /etc/systemd/system/wifi-setup.service <<EOF
[Unit]
Description=Start WiFi AP and Portal
After=network.target

[Service]
ExecStart=/bin/bash /home/barudan-pi/wifi-setup/start_ap.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl enable wifi-setup.service

echo "Instalación completa. Reboot para aplicar."