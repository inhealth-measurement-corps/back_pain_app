
import os
import flask
from flask import Flask, request, jsonify, send_from_directory, send_file, Blueprint, current_app
from flaskext.mysql import MySQL
import csv
import hashlib
from time import gmtime, strftime
from Models.Patients import patients
from Models.Users import users
from extensions import mysql
from tools import *

app = Flask(__name__, static_folder='static')
app.register_blueprint(patients, url_prefix = '/patients')
app.register_blueprint(users, url_prefix = '/users')

app.config['MYSQL_DATABASE_USER'] = 'mmcorps'
app.config['MYSQL_DATABASE_PASSWORD'] = '4yi7ekG4DIvz2WFi'
app.config['MYSQL_DATABASE_DB'] = 'mmcorps'
app.config['MYSQL_DATABASE_HOST'] = '10.162.80.9'

mysql.init_app(app)

import time, threading
#threading.Timer(10, updateTokens, []).start()

def updateTokens():
    threading.Timer(300, updateTokens, []).start()
    conn = mysql.connect()
    cursor = conn.cursor()
    timeAgo = timestampXMinutesAgo(5)
    cursor.execute('SELECT * FROM tokens WHERE deleted=0 AND timestamp <=%s' % timeAgo)
    results = cursor.fetchall()
    for result in results:
        cursor.execute('UPDATE tokens SET deleted=1 WHERE id=%s' % result[0])
    conn.commit()
    cursor.close()
    conn.close()
    print('updated tokens')

#updateTokens()


@app.errorhandler(Exception)
def unhandled_exception(e):
    print('ERROR: %s' % e)
    return 'An unexpected error has occurred.'

@app.route('/')
def homepage():
    return send_from_directory(app.static_folder, "index.html")

@app.route('/patientData')
def index():
    return send_from_directory(app.static_folder, "patientData.html")

@app.route('/gps')
def gps():
    return send_from_directory(app.static_folder, "gps.html")

@app.route('/<path:path>')
def catch_all(path):
    return 'PAGE NOT FOUND'


if __name__ == "__main__":
    #port = int(os.environ.get('PORT', 5000))
    #app.run(debug=False, host="0.0.0.0", port=port)
    app.run(debug = True)
