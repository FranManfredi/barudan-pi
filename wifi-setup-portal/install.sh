#!/bin/bash
set -e

BASE_DIR="/home/barudan-pi/barudan-pi/wifi-setup-portal"

echo "Instalando dependencias..."
sudo apt update
sudo apt install -y hostapd dnsmasq python3-flask python3-rpi.gpio

echo "Configurando red..."

# Configuración IP estática para wlan0
sudo tee -a /etc/dhcpcd.conf > /dev/null <<EOF
interface wlan0
    static ip_address=192.168.4.1/24
    nohook wpa_supplicant
EOF
sudo systemctl restart dhcpcd

# Configurar dnsmasq
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig || true
sudo tee /etc/dnsmasq.conf > /dev/null <<EOF
interface=wlan0
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h
EOF

# Configurar hostapd
sudo tee /etc/hostapd/hostapd.conf > /dev/null <<EOF
interface=wlan0
driver=nl80211
ssid=ConfiguraWiFi
hw_mode=g
channel=7
wmm_enabled=0
auth_algs=1
ignore_broadcast_ssid=0
EOF

# Apuntar hostapd a su config
sudo sed -i 's|#DAEMON_CONF=""|DAEMON_CONF="/etc/hostapd/hostapd.conf"|' /etc/default/hostapd

echo "Creando scripts en $BASE_DIR..."
mkdir -p "$BASE_DIR"

# Crear portal Flask
cat > "$BASE_DIR/wifi_portal.py" <<'EOF'
from flask import Flask, request, render_template_string
import os

HTML = """
<h2>Configurá tu WiFi</h2>
<form method="post">
  SSID: <input name="ssid"><br>
  Contraseña: <input name="password" type="password"><br>
  <button type="submit">Conectar</button>
</form>
"""

app = Flask(__name__)

@app.route("/", methods=["GET", "POST"])
def index():
    if request.method == "POST":
        ssid = request.form["ssid"]
        password = request.form["password"]
        os.system(f'nmcli dev wifi connect "{ssid}" password "{password}"')
        return "Intentando conectar a la red WiFi..."
    return render_template_string(HTML)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
EOF

# Script que lanza el AP
cat > "$BASE_DIR/start_ap.sh" <<EOF
#!/bin/bash
echo "Iniciando Access Point"
sudo ip link set wlan0 up
sudo ifconfig wlan0 192.168.4.1
sudo systemctl start hostapd
sudo systemctl start dnsmasq
python3 "$BASE_DIR/wifi_portal.py"
EOF
chmod +x "$BASE_DIR/start_ap.sh"

# Script que chequea jumper
cat > "$BASE_DIR/check_mode.py" <<EOF
import RPi.GPIO as GPIO
import subprocess
import time

PIN_MODE = 17  # GPIO17, pin físico 11

GPIO.setmode(GPIO.BCM)
GPIO.setup(PIN_MODE, GPIO.IN, pull_up_down=GPIO.PUD_UP)
time.sleep(0.1)

if GPIO.input(PIN_MODE) == GPIO.LOW:
    print("Jumper detectado. Entrando en modo portal.")
    subprocess.run(["$BASE_DIR/start_ap.sh"])
else:
    print("Modo normal. No se inicia portal.")

GPIO.cleanup()
EOF

# Servicio systemd
sudo tee /etc/systemd/system/wifi-setup.service > /dev/null <<EOF
[Unit]
Description=Start WiFi AP and Portal on boot if jumper is detected
After=network.target

[Service]
ExecStart=/usr/bin/python3 $BASE_DIR/check_mode.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

echo "Habilitando servicios..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable hostapd
sudo systemctl enable dnsmasq
sudo systemctl enable wifi-setup.service

echo "Instalación completa. Reiniciá la Raspberry Pi con el jumper conectado (pin 9 a pin 11) para activar el portal WiFi."