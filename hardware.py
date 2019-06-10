from flask import Flask, request, jsonify
import sqlite3 as sql
import time
import random
application = Flask(__name__)


def slow_process_to_calculate_availability(provider, name):
    time.sleep(5)
    return random.choice(['HIGH', 'MEDIUM', 'LOW'])


@application.route('/hardware/')
def hardware():
    con = sql.connect('database.db')
    c = con.cursor()

    statuses = [
        {
            'provider': row[1],
            'name': row[2],
            'availability': slow_process_to_calculate_availability(
                row[1],
                row[2]
            ),
        }
        for row in c.execute('SELECT * from hardware')
    ]

    con.close()

    return jsonify(statuses)


if __name__ == "__main__":
    application.run(host='0.0.0.0', port=5001)
