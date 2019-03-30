

/*window.onload = function() {
    var userInfo = {
        username: sessionStorage.getItem('user'),
        patientID: sessionStorage.getItem('ID')
    }
};*/


function displayDay() {
    var userInfo = {
        username: sessionStorage.getItem('user'),
        password: sessionStorage.getItem('pass'),
        patientID: sessionStorage.getItem('iD')
    }

    var myData;
    $.ajax ({
        type: "POST",
        //invocation = new XMLHttpRequest(),
        url: "https://healthalytics.herokuapp.com/getPatientData", //http://healthalytics.herokuapp.com/getPatientData
        data: {usernameInput: userInfo.username, passwordInput: userInfo.password, patientCodeInput: userInfo.patientID},
        dataType: "json",
        global: false,
        async: false,

        success: function(data) {
            myData = data;
        },
        error: function(xhr, status, error) {
            //console.log("status: " + status);
            alert('error');

        }

    });


    var data = myData["data"];

    var logs = data["logs"].split('\n');    
    var locationLogs = data["locationLogs"];
    var heartRateLogs = data["heartRateLogs"];
    var stepCountLogs = data["stepCountLogs"];
    var logArray;
    var logArraySplit;

    console.log(logs);

    var generateTable = document.getElementById("tableTotal");
    generateTable.innerHTML = "<tr><th>Time Stamp</th><th>Pain</th><th>Percentage</th></tr>";
    
    for (var i = 1; i < logs.length; i++) {
        var row = generateTable.insertRow(i-1);
        var timestamp = row.insertCell(0);
        var painlevel = row.insertCell(1);
        var percent = row.insertCell(0);
        logArray = logs[i].split(',');
        for (var j = 0; j < 3; j++) {
            timestamp.innerHTML = logArray[j];
            painlevel.innerHTML = logArray[j+1];
            percent.innerHTML = logArray[j+2];
            
            console.log(logArray[j]); //timestamp
            console.log(logArray[j+1]); //pain level
            console.log(logArray[j+2]); //percentage
            break;
        }
        
    }

    //var element = document.createElement('div');
    var num = 20; //the number of cols we want in our chart
    //document.getElementById("trial") = logArraySplit[i];
    //console.log(logArraySplit[i]);

};

