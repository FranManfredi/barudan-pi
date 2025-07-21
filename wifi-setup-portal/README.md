# Barudan Setup Portal

Este proyecto permite que una Raspberry Pi (como la Pi Zero) cree un portal cautivo WiFi automáticamente al encenderse, para configurar el acceso a una red WiFi real.

## 🚀 Funcionalidad

- Emite una red WiFi llamada `Barudan-Setup`
- Lanza un portal local accesible desde cualquier dispositivo
- Permite ingresar SSID y contraseña de la red real
- Intenta conectar y guarda la configuración

## 🧰 Requisitos

- Raspberry Pi con WiFi integrado (Zero W, 3, 4)
- Raspberry Pi OS (Bookworm o Bullseye)
- Acceso SSH o físico para la instalación inicial

## 🔧 Instalación

```bash
git clone https://github.com/FranManfredi/barudan-setup-portal.git
cd barudan-setup-portal
chmod +x install.sh start_ap.sh
sudo ./install.sh
sudo reboot