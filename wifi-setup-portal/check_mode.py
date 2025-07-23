import RPi.GPIO as GPIO
import subprocess
import time

PIN_MODE = 17  # GPIO 17 (pin físico 11)

GPIO.setmode(GPIO.BCM)
GPIO.setup(PIN_MODE, GPIO.IN, pull_up_down=GPIO.PUD_UP)
time.sleep(0.1)

if GPIO.input(PIN_MODE) == GPIO.LOW:
    print("Jumper detectado. Entrando en modo portal WiFi.")
    subprocess.run(["/home/pi/start_ap.sh"])
else:
    print("Modo normal. No se inicia portal.")

GPIO.cleanup()