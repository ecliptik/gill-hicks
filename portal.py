from flask import Flask, request
import requests
import os
application = Flask(__name__)

hardware_host = os.environ.get('HARDWARE_HOST', 'localhost')

@application.route('/')
def dashboard():
    result = requests.get('http://' + hardware_host + ':5001/hardware/').json()
    hardware = [
        '{} - {}: {}'.format(r['provider'], r['name'], r['availability'])
        for r in result
    ]

    return '<br>'.join(hardware)


if __name__ == "__main__":
    application.run(host='0.0.0.0', port=5000)
