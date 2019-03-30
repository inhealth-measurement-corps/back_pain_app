
import os
import flask
from flask import Flask, request, jsonify, send_from_directory, send_file, Blueprint
from flaskext.mysql import MySQL
import csv
import hashlib
from flask import Blueprint, current_app
from extensions import mysql
from tools import *

app = Flask(__name__, static_folder='../static')
patients = Blueprint('Patients', __name__)

"""@patients.route('/patientExists', methods=['POST'])
def patientExists():
    if request.method == 'POST':
        conn = mysql.connect()
        cursor = conn.cursor()
        json = request.get_json()
        id = json["id"]

        if not nonNegativeFloat([id]):
            return 'error'

        cursor.execute("SELECT * from patients WHERE id=%s;", (id,))
        data = cursor.fetchone()

        if data is None:
            data = {"exists": "false"}
        else:
            data = {"exists": "true"}

        returnDict = {"status": "ok", "data": data}
        cursor.close()
        conn.close()
        return jsonify(returnDict)"""

@patients.route('/createPatient', methods=['POST'])
def createPatient():
    if request.method == 'POST':
        conn = mysql.connect()
        cursor = conn.cursor()
        json = request.get_json()
        id = json["id"]

        if not nonNegativeFloat([id]):
            return 'error'

        cursor.execute("SELECT * from patients WHERE id=%s;", (id,))
        data = cursor.fetchone()

        currentDate = getDateTime()

        if data is None:
            cursor.execute('INSERT INTO patients (id, date_updated, date_created) VALUES (%s, "%s", "%s");' % (str(id), currentDate, currentDate))
        else:
            return jsonify({"status": "ok", "created": "false"})

        conn.commit()
        cursor.close()
        conn.commit()

        return jsonify({"status": "ok", "created": "true"})


@patients.route('/sendLogs', methods=['POST'])
def sendLogs():
    if request.method == 'POST':
        conn = mysql.connect()
        cursor = conn.cursor()
        json = request.get_json()
        logs = json["data"]

        storedLogs = {
            "painLogs": [],
            "locationLogs": [],
            "heartRateLogs": [],
            "stepCountLogs": []}

        painLogs = logs[0]
        locationLogs = logs[1]
        heartRateLogs = logs[2]
        stepCountLogs = logs[3]

        for log in painLogs:
            timestamp = log["timestamp"]
            patient_id = log["patient_id"]

            if not nonNegativeFloat([timestamp, patient_id]):
                print('error 1')
                return 'error'

            cursor.execute(
                "SELECT * from logs WHERE patient_id=%s AND timestamp=%s;",
                (str(patient_id),
                 str(timestamp),
                 ))
            data = cursor.fetchone()

            if data is None:
                pain = log["pain"]
                percentage = log["percentage"]
               
                if not nonNegativeFloat([pain, percentage]):
                    print('error 2')
                    return 'error'

                time = getDateTime()
                cursor.execute(
                    "INSERT INTO logs (patient_id, timestamp, pain, percentage, date_updated, date_created) VALUES (%s,%s,%s,%s,%s,%s);",
                    (str(patient_id),
                     str(timestamp),
                        str(pain),
                        str(percentage),
                        time,
                        time,
                     ))
                cursor.execute(
                    "SELECT * from logs WHERE patient_id=%s AND timestamp=%s;",
                    (str(patient_id),
                     str(timestamp),
                     ))
                data = cursor.fetchone()

                if data is not None:
                    # successfully inserted into DB, so add the timestamp to
                    storedLogs["painLogs"].append(timestamp)
            else:
                storedLogs["painLogs"].append(timestamp)

        for log in locationLogs:
            timestamp = log["timestamp"]
            patient_id = log["patient_id"]

            if not nonNegativeFloat([timestamp, patient_id]):
                print('error 3')
                return 'error'

            cursor.execute(
                "SELECT * from location_logs WHERE patient_id=%s AND timestamp=%s;",
                (str(patient_id),
                 str(timestamp),
                 ))
            data = cursor.fetchone()

            if data is None:
                latitude = log["latitude"]
                longitude = log["longitude"]
                print(latitude, longitude)
                if not isFloat([latitude, longitude]):
                    print('error 4')
                    return 'error'

                time = getDateTime()
                cursor.execute(
                    "INSERT INTO location_logs (patient_id, timestamp, latitude, longitude, date_updated, date_created) VALUES (%s,%s,%s,%s,%s,%s);",
                    (str(patient_id),
                     str(timestamp),
                        str(latitude),
                        str(longitude),
                        time,
                        time,
                     ))
                cursor.execute(
                    "SELECT * from location_logs WHERE patient_id=%s AND timestamp=%s;",
                    (str(patient_id),
                     str(timestamp),
                     ))
                data = cursor.fetchone()

                if data is not None:
                    # successfully inserted into DB, so add the timestamp to
                    storedLogs['locationLogs'].append(timestamp)

            else:
                storedLogs['locationLogs'].append(timestamp)

        for log in heartRateLogs:
            timestamp = log["timestamp"]
            patient_id = log["patient_id"]

            if not nonNegativeFloat([timestamp, patient_id]):
                print('error 6')
                return 'error'

            cursor.execute(
                "SELECT * from heart_rate_logs WHERE patient_id=%s AND timestamp=%s;",
                (str(patient_id),
                 str(timestamp),
                 ))
            data = cursor.fetchone()

            if data is None:
                heartRate = log["heartRate"]

                if not nonNegativeFloat([heartRate]):
                    print('error 7')
                    return 'error'

                time = getDateTime()
                cursor.execute(
                    "INSERT INTO heart_rate_logs (patient_id, timestamp, heart_rate, date_updated, date_created) VALUES (%s,%s,%s,%s,%s);",
                    (str(patient_id),
                     str(timestamp),
                        str(heartRate),
                        time,
                        time,
                     ))
                cursor.execute(
                    "SELECT * from heart_rate_logs WHERE patient_id=%s AND timestamp=%s;",
                    (str(patient_id),
                     str(timestamp),
                     ))
                data = cursor.fetchone()

                if data is not None:
                    # successfully inserted into DB, so add the timestamp to
                    storedLogs['heartRateLogs'].append(timestamp)
            else:
                storedLogs['heartRateLogs'].append(timestamp)

        for log in stepCountLogs:
            timestamp = log["timestamp"]
            patient_id = log["patient_id"]

            if not nonNegativeFloat([timestamp, patient_id]):
                print('error 8')
                return 'error'

            cursor.execute(
                "SELECT * from step_count_logs WHERE patient_id=%s AND timestamp=%s;",
                (str(patient_id),
                 str(timestamp),
                 ))
            data = cursor.fetchone()

            if data is None:
                steps = log["stepCount"]

                if not nonNegativeFloat([steps]):
                    print('error 9')
                    return 'error'

                time = getDateTime()
                cursor.execute(
                    "INSERT INTO step_count_logs (patient_id, timestamp, steps, date_updated, date_created) VALUES (%s,%s,%s,%s,%s);",
                    (str(patient_id),
                     str(timestamp),
                        str(steps),
                        time,
                        time,
                     ))
                cursor.execute(
                    "SELECT * from step_count_logs WHERE patient_id=%s AND timestamp=%s;",
                    (str(patient_id),
                     str(timestamp),
                     ))
                data = cursor.fetchone()

                if data is not None:
                    # successfully inserted into DB, so add the timestamp to
                    storedLogs['stepCountLogs'].append(timestamp)
            else:
                storedLogs['stepCountLogs'].append(timestamp)

        conn.commit()

        cursor.close()
        conn.close()
        returnDict = {"status": "ok", "data": storedLogs}
        return jsonify(returnDict)


@patients.route('/getPatientData', methods=['POST'])
def getPatientData():
    conn = mysql.connect()
    cursor = conn.cursor()

    dictionary = request.form
    token = dictionary["token"]

    if hasInvalidCharacters(token):
        return 'error'

    patient_id = dictionary["patientID"]

    if not nonNegativeFloat([patient_id]):
        return 'error'

    cursor.execute("SELECT * FROM tokens WHERE code='%s' AND deleted=0;" % token)
    data = cursor.fetchone()
    if data is None:
        return jsonify({"status": "error", "error": "Invalid token."})

    cursor.close()
    conn.close()

    csvString = createCSV(patient_id)
    response = flask.jsonify({"status": "ok", "data": csvString})
    response.headers.add('Access-Control-Allow-Origin', '*')
    return response


@patients.route('/checkIDAvailability', methods=['POST'])
def checkIDAvailability():
    if request.method == 'POST':
        conn = mysql.connect()
        cursor = conn.cursor()
        json = request.get_json()
        id = json["id"]

        if not nonNegativeFloat([id]):
            return 'error'

        cursor.execute("SELECT * from patients WHERE id=%s;", (id,))
        data = cursor.fetchone()
        cursor.close()
        conn.close()
        if data is None:
            return jsonify({"status": "ok", "available": "true"})
        else:
            return jsonify({"status": "ok", "available": "false"})


def createCSV(patient_id):
    conn = mysql.connect()
    cursor = conn.cursor()
    cursor.execute("SELECT * from logs WHERE patient_id=%s;" % patient_id)
    logs = cursor.fetchall()

    cursor.execute(
        "SELECT * from location_logs WHERE patient_id=%s ORDER BY timestamp ASC;" %
        patient_id)
    locationLogs = cursor.fetchall()

    cursor.execute(
        "SELECT * from heart_rate_logs WHERE patient_id=%s ORDER BY timestamp ASC;" %
        patient_id)
    heartRateLogs = cursor.fetchall()

    cursor.execute(
        "SELECT * from step_count_logs WHERE patient_id=%s ORDER BY timestamp ASC;" %
        patient_id)
    stepCountLogs = cursor.fetchall()

    cursor.close()
    conn.close()

    logsString = "Timestamp,Pain,Percentage\n"
    for log in logs:
        logsString += str(log[2]) + ',' + str(log[3]) + \
            ',' + str(log[4]) + '\n'

    locationLogsString = "Timestamp,Latitude,Longitude\n"
    for log in locationLogs:
        locationLogsString += str(log[2]) + ',' + \
            str(log[3]) + ',' + str(log[4]) + '\n'

    heartRateLogsString = "Timestamp,Heart Rate\n"
    for log in heartRateLogs:
        heartRateLogsString += str(log[2]) + ',' + str(log[3]) + '\n'

    stepCountLogsString = "Timestamp, Steps\n"
    for log in stepCountLogs:
        stepCountLogsString += str(log[2]) + ',' + str(log[3]) + '\n'
    return {
        "logs": logsString,
        "locationLogs": locationLogsString,
        "heartRateLogs": heartRateLogsString,
        "stepCountLogs": stepCountLogsString}


def createLocationCSV(patientID):
    conn = mysql.connect()
    cursor = conn.cursor()
    cursor.execute("SELECT * from location_logs WHERE patient_id=%s;" % patientID)
    logs = cursor.fetchall()
    with open('static/temp.csv', 'w') as csvfile:
        fieldnames = ["Timestamp", "Latitude", "Longitude"]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()

        for log in logs:
            writer.writerow({'Timestamp': log[
                            2], 'Latitude': log[3], 'Longitude': log[4]})

    cursor.close()
    conn.close()
   


"""
def createCSVFile(data):
    with open('static/temp.csv', 'w') as csvfile:
        fieldnames = ["Log ID", "Patient ID",
                      "Timestamp", "Pain", "Percentage"]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()

        for log in data:
            writer.writerow({'Log ID': log[0], 'Patient ID': log[1], 'Timestamp': log[
                            2], 'Pain': log[3], 'Percentage': log[4]})

"""



@patients.route('/getPatientLocationData', methods=['POST'])
def getPatientLocationData():
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
        print("inside if statement")
        patient_id = dictionary["patientIDInput"]
        print("id:", patient_id)
        if not nonNegativeFloat([patient_id]):
            return 'error'

        createLocationCSV(patient_id)

    cursor.close()
    conn.close()
    print("before return")
    return send_from_directory(app.static_folder, "temp.csv")









