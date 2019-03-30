
import os
import flask
from flask import Flask, request, jsonify, send_from_directory, send_file, Blueprint, current_app
from flaskext.mysql import MySQL
import csv
import hashlib
from time import gmtime, strftime
from extensions import mysql
from tools import *

app = Flask(__name__, static_folder='static')

app.config['MYSQL_DATABASE_USER'] = 'mmcorps'
app.config['MYSQL_DATABASE_PASSWORD'] = '4yi7ekG4DIvz2WFi'
app.config['MYSQL_DATABASE_DB'] = 'mmcorps'
app.config['MYSQL_DATABASE_HOST'] = '10.162.80.9'

mysql.init_app(app)


def updateValues():
    conn = mysql.connect()
    cursor = conn.cursor()

    print("done")
    cursor.execute("SELECT * FROM heart_rate_logs;")
    data = cursor.fetchall()
    for item in data:
        timestamp = float(item[2]) + 2592000.0
        cursor.execute("UPDATE heart_rate_logs SET timestamp=%d WHERE id=%i;" % (timestamp, int(item[0])))

    print("done")
    cursor.execute("SELECT * FROM location_logs;")
    data = cursor.fetchall()
    for item in data:
        timestamp = float(item[2]) + 2592000
        cursor.execute("UPDATE location_logs SET timestamp=%d WHERE id=%i;" % (timestamp, int(item[0])))

    print("done")

    cursor.execute("SELECT * FROM logs;")
    data = cursor.fetchall()
    for item in data:
        timestamp = float(item[2]) + 2592000
        cursor.execute("UPDATE logs SET timestamp=%d WHERE id=%i;" % (timestamp, int(item[0])))


    print("done")
    cursor.execute("SELECT * FROM step_count_logs;")
    data = cursor.fetchall()
    for item in data:
        timestamp = float(item[2]) + 2592000
        cursor.execute("UPDATE step_count_logs SET timestamp=%d WHERE id=%i;" % (timestamp, int(item[0])))


    conn.commit()
    cursor.close()
    conn.close()
    print("done")

if __name__ == "__main__":
    #port = int(os.environ.get('PORT', 5000))
    #app.run(debug=False, host="0.0.0.0", port=port)
    updateValues()
    app.run(debug = True)



