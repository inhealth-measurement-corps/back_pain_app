import StringIO
import os
import flask
from flask import Flask, request, jsonify, send_from_directory, send_file, Blueprint
from flaskext.mysql import MySQL
import csv
import hashlib
from time import gmtime, strftime

app = Flask(__name__, static_folder='static')
#app = Flask(__name__, static_folder='static')

app.config['MYSQL_DATABASE_USER'] = 'mmcorps'
app.config['MYSQL_DATABASE_PASSWORD'] = '4yi7ekG4DIvz2WFi'
app.config['MYSQL_DATABASE_DB'] = 'mmcorps'
app.config['MYSQL_DATABASE_HOST'] = '10.162.80.9'

mysql = MySQL()
mysql.init_app(app)

@app.errorhandler(Exception)
def unhandled_exception(e):
    print('ERROR: %s' % e)
    return 'An unexpected error has occurred.'

@app.route('/')
def homepage():
    return send_from_directory(app.static_folder, "homepage.html")

@app.route('/index')
def index():
    return send_from_directory(app.static_folder, "index.html")


@app.route('/<path:path>')
def catch_all(path):
    return 'PAGE NOT FOUND'

@app.route('/patientExists', methods=['POST'])
def userExists():
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
        return jsonify(returnDict)


@app.route('/sendLogs', methods=['POST'])
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

                if not nonNegativeFloat([latitude, longitude]):
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


@app.route('/getPatientData', methods=['POST'])
def getPatientData():
    conn = mysql.connect()
    cursor = conn.cursor()

    dictionary = request.form
    username = dictionary["usernameInput"]
    password = dictionary["passwordInput"]
    password = hashlib.sha224(password.encode()).hexdigest()

    if hasInvalidCharacters(username) or hasInvalidCharacters(password):
        return 'error'

    patient_id = dictionary["patientCodeInput"]

    if not nonNegativeFloat([patient_id]):
        return 'error'

    cursor.execute("SELECT * FROM users WHERE username = %s;", (username,))
    data = cursor.fetchone()
    
    if data is not None:
        password_attempts = int(data[2])
        if password_attempts == 5:
            cursor.close()
            conn.close()
            response = flask.jsonify({"status": "error", "error": "User has been locked due to many incorrect attempts to log in."})
            response.headers.add('Access-Control-Allow-Origin', '*')
            return response
        user_id = data[0]
        print("password attempts: %s" % password_attempts)
        cursor.execute(
            "SELECT * FROM user_passwords WHERE user_id = %s;", (user_id,))
        data = cursor.fetchone()

        if data is not None:
            if password == data[2]:
                print("CORRECT PASSWORD")
                cursor.execute("UPDATE users SET password_attempts=0, date_updated='%s' WHERE id=%i;" %  (getDateTime(), user_id))
                conn.commit()
                '''cursor.execute(
                    "SELECT * FROM logs WHERE patient_id = %s;", (user_id,))
                data = cursor.fetchall()

                for log in data:
                    createCSV(data)'''
                cursor.close()
                conn.close()
                csvString = createCSV(patient_id)

                response = flask.jsonify({"status": "ok", "data": csvString})
                response.headers.add('Access-Control-Allow-Origin', '*')
                return response
                # return send_from_directory(app.static_folder, "temp.csv")

            else:
                password_attempts += 1
                cursor.execute('UPDATE users SET password_attempts=%i, date_updated="%s" WHERE id=%i;' % (password_attempts, getDateTime(), user_id))
                conn.commit()
                cursor.close()
                conn.close()
                print("WRONG PASSWORD")
                response = flask.jsonify({"status": "error", "error": "Incorrect username or password."})
                response.headers.add('Access-Control-Allow-Origin', '*')
                return response

        print("USERNAME DOES NOT EXIST")
        cursor.close()
        conn.close()

        response = flask.jsonify({"status": "error", "error": "Incorrect username or password."})
        response.headers.add('Access-Control-Allow-Origin', '*')
        return response



    else:
        cursor.close()
        conn.close()
        response = flask.jsonify({"status": "error", "error": "Incorrect username or password."})
        response.headers.add('Access-Control-Allow-Origin', '*')
        return response


@app.route('/checkIDAvailability', methods=['POST'])
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
        "SELECT * from location_logs WHERE patient_id=%s;" %
        patient_id)
    locationLogs = cursor.fetchall()

    cursor.execute(
        "SELECT * from heart_rate_logs WHERE patient_id=%s;" %
        patient_id)
    heartRateLogs = cursor.fetchall()

    cursor.execute(
        "SELECT * from step_count_logs WHERE patient_id=%s;" %
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

'''
def createCSVFile(data):
    with open('static/temp.csv', 'w') as csvfile:
        fieldnames = ["Log ID", "Patient ID",
                      "Timestamp", "Pain", "Percentage"]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()

        for log in data:
            writer.writerow({'Log ID': log[0], 'Patient ID': log[1], 'Timestamp': log[
                            2], 'Pain': log[3], 'Percentage': log[4]})
'''

def nonNegativeFloat(strings):
    try:
        for string in strings:
            if float(string) < 0.0:
                return False
        return True
    except:
        return False

def hasInvalidCharacters(string):
    if set('[~!@#$%^& =*()_+{}":;]+$\\\'').intersection(string):
        print("string %s has invalid characters." % (string))
        return True
    return False



def getDateTime():
    return strftime("%Y-%m-%d %H:%M:%S", gmtime())




if __name__ == "__main__":
    #port = int(os.environ.get('PORT', 5000))
    #app.run(debug=False, host="0.0.0.0", port=port)
    app.run(debug = True)
