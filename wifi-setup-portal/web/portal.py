from flask import Flask, request, render_template_string
import os

app = Flask(__name__)

HTML = """
<h2>Configurá tu WiFi</h2>
<form method="post">
  SSID: <input name="ssid"><br>
  Password: <input name="password" type="password"><br>
  <button type="submit">Conectar</button>
</form>
"""

@app.route("/", methods=["GET", "POST"])
def index():
    if request.method == "POST":
        ssid = request.form["ssid"]
        password = request.form["password"]
        os.system(f'nmcli dev wifi connect "{ssid}" password "{password}"')
        return "Intentando conectar..."
    return render_template_string(HTML)

app.run(host="0.0.0.0", port=80)