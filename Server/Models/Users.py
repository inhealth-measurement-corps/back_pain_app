
import os
import flask
from flask import Flask, request, jsonify, send_from_directory, send_file, Blueprint
from flaskext.mysql import MySQL
import csv
import hashlib
from flask import Blueprint, current_app
from extensions import mysql
import random, string
from tools import *
import time

users = Blueprint('Users', __name__)

@users.route('/logIn', methods=['POST'])
def logIn():
    if request.method == 'POST':
        conn = mysql.connect()
        cursor = conn.cursor()

        dictionary = request.form
        username = dictionary["usernameInput"]
        password = dictionary["passwordInput"]
        password = hashlib.sha224(password.encode()).hexdigest()

        if hasInvalidCharacters(username) or hasInvalidCharacters(password):
            print("error in users")
            return 'error'

        cursor.execute("SELECT * FROM users WHERE username = %s;", (username,))
        userData = cursor.fetchone()
    
        if userData is not None:
            user_id = userData[0]
            password_attempts = int(userData[2])
            if password_attempts == 5:
                cursor.close()
                conn.close()
                response = flask.jsonify({"status": "error", "error": "User has been locked due to many incorrect attempts to log in."})
                print("error in users")
                response.headers.add('Access-Control-Allow-Origin', '*')
                return response

            cursor.execute(
            "SELECT * FROM user_passwords WHERE user_id = %s;", (user_id,))
            data = cursor.fetchone()
            if data is not None:
                if password == data[2]:
                    currentDate = getDateTime()
                    cursor.execute("UPDATE users SET password_attempts=0, date_updated='%s' WHERE id=%i;" %  (getDateTime(), user_id))
                    word = ''.join(random.choice(string.ascii_uppercase + string.digits) for i in range(45))
                    cursor.execute("SELECT * FROM tokens WHERE code='%s' AND deleted=0" % word)
                    data = cursor.fetchone()
                    currentDate = getDateTime()
                    while data is not None:
                        word = ''.join(random.choice(string.ascii_uppercase + string.digits) for i in range(45))
                        cursor.execute("SELECT * FROM tokens WHERE code='%s' AND deleted=0" % (word))
                        data = cursor.fetchone()

                    #need to invalidate all prior tokens from same user
                    cursor.execute("INSERT INTO tokens (code, user_id, timestamp, date_created) VALUES ('%s',%s,'%s','%s');" % (word, str(userData[0]), time.time(), currentDate))
                    conn.commit()
                    cursor.close()
                    conn.close()
                    return jsonify({"status": "ok", "token": word}) 
                else:
                    password_attempts += 1
                    cursor.execute('UPDATE users SET password_attempts=%i, date_updated="%s" WHERE id=%i;' % (password_attempts, getDateTime(), user_id))
                    conn.commit()
                    cursor.close()
                    conn.close()
                    print("WRONG PASSWORD")
                    response = flask.jsonify({"status": "error", "error": "Incorrect username or password."})
                    print("error in users")
                    response.headers.add('Access-Control-Allow-Origin', '*')
                    return response
            else:
                print("USERNAME DOES NOT EXIST")
                cursor.close()
                conn.close()
                response = flask.jsonify({"status": "error", "error": "Incorrect username or password."})
                print("error in users")
                response.headers.add('Access-Control-Allow-Origin', '*')
                return response

        else:
            cursor.close()
            conn.close()
            response = flask.jsonify({"status": "error", "error": "Incorrect username or password."})
            print("error in users")
            response.headers.add('Access-Control-Allow-Origin', '*')
            return response






