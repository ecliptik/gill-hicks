from flask import Flask, request, jsonify
import sqlite3 as sql
import time
import random
import os
application = Flask(__name__)

#Setup mysql connection using flask-mysql
from flaskext.mysql import MySQL
mysql = MySQL()

#Set variables using ENV vars or use defaults
application.config['MYSQL_DATABASE_HOST'] = os.environ.get('MYSQL_HOST', 'mysql')
application.config['MYSQL_DATABASE_USER'] = os.environ.get('MYSQL_USER', 'mysql')
application.config['MYSQL_DATABASE_PASSWORD'] = os.environ.get('MYSQL_PASSWORD', 'mysql')
application.config['MYSQL_DATABASE_DB'] = os.environ.get('MYSQL_DATABASE', 'hardware')
mysql.init_app(application)

def slow_process_to_calculate_availability(provider, name):
    time.sleep(5)
    return random.choice(['HIGH', 'MEDIUM', 'LOW'])


@application.route('/hardware/')
def hardware():
    con = mysql.connect()
    c = con.cursor()
    c.execute('SELECT * from hardware')

    statuses = [
        {
            'provider': row[1],
            'name': row[2],
            'availability': slow_process_to_calculate_availability(
                row[1],
                row[2]
            ),
        }
        for row in c.fetchall()
    ]

    con.close()

    return jsonify(statuses)


if __name__ == "__main__":
    application.run(host='0.0.0.0', port=5001)
