var finalizedHeartRates = new Array();
var finalizedHeartDays = new Array();

var myLiveChart;
//var barChart;

function formatDate(timeStamp) {
    var monthNames = [
        "Jan", "Feb", "Mar",
        "Apr", "May", "Jun", "Jul",
        "Aug", "Sept", "Oct",
        "Nov", "Dec"
    ];

    var hoursFormatted = [
        12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
        12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
    ];

    var ed = [
        "am", "am", "am", "am", "am", "am", 
        "am", "am", "am", "am", "am", "am", 
        "pm", "pm", "pm", "pm", "pm", "pm",
        "pm", "pm", "pm", "pm", "pm", "pm"
    ];
    //console.log(timeStamp);

    var date = new Date(timeStamp);
    //date.setSeconds(timeStamp);
    //console.log(logTimestamp);
    var d = date.getDate();
    var monthInd = date.getMonth();
    var y = date.getFullYear();
    var hoursUnformatted = date.getHours();
    var formatted = {
        month: monthNames[monthInd],
        day: d,
        year: y,
        hours: hoursFormatted[hoursUnformatted],
        minutes: ("0" + date.getMinutes()).slice(-2),
        end: ed[hoursUnformatted]
    }

    //var formatted = monthNames[monthInd] + " " + day + ", " + year + "\n" + hoursFormatted[hoursUnformatted] + ":" + ("0" + date.getMinutes()).slice(-2) + " " + end[hoursUnformatted];  
    //console.log(formatted);

    return formatted;
}

function displayData(param) {
    var userInfo = {
        username: sessionStorage.getItem('user'),
        password: sessionStorage.getItem('pass'),
        patientID: sessionStorage.getItem('patientID'),
        token: sessionStorage.getItem('token')
    }

    

    var myData;
    $.ajax ({
        type: "POST",
        //invocation = new XMLHttpRequest(),
        url: "http://127.0.0.1:5000/patients/getPatientData", //http://healthalytics.herokuapp.com/getPatientData
        data: {token: userInfo.token, patientID: userInfo.patientID},
        dataType: "json",
        global: false,
        async: false,

        success: function(data) {
            myData = data;
        },
        error: function(xhr, status, error) {
            alert('error');

        }

    });


    var data = myData["data"];

    var logs = data["logs"].split('\n');    
    var locationLogs = data["locationLogs"].split('\n');
    var heartRateLogs = data["heartRateLogs"].split('\n');
    var stepCountLogs = data["stepCountLogs"].split('\n');

    var logArray;

    var generateTable = document.getElementById("tableTotal");
    while(generateTable.rows.length > 0) {
        generateTable.deleteRow(0);
    }


    var currentDate = Math.floor(Date.now());


    var seconds = 3600;
    var buckets = 60;

    if (param == 'day') {
        seconds *= 24;
        buckets = 24;
    } else if (param == 'week') {
        seconds *= (24 * 7);
        buckets = 7;
    } else if (param == 'month') {
        seconds *= (24 * 7 * 4);
        buckets = 28; //each hour in the past month
    }

        var monthNames = [
        "Jan", "Feb", "Mar",
        "Apr", "May", "Jun", "Jul",
        "Aug", "Sept", "Oct",
        "Nov", "Dec"
    ];

    var hoursFormatted = [
        12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
        12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
    ];

    var end = [
        "am", "am", "am", "am", "am", "am", 
        "am", "am", "am", "am", "am", "am", 
        "pm", "pm", "pm", "pm", "pm", "pm",
        "pm", "pm", "pm", "pm", "pm", "pm"
    ];

    var dates = new Array(buckets);
    var dateSplit = new Array(buckets);


    for (var i = 0; i < buckets; i++) {
        //row = generateTable.insertRow(i + 1);
        //timestamp = row.insertCell(0);
        //painLevel = row.insertCell(1);
        //var percent = row.insertCell(2);
        var date = new Date(currentDate - i * bucketWidth * 1000);
        
        var day = date.getDate();
        var monthInd = date.getMonth();
        var year = date.getFullYear();
        var hoursUnformatted = date.getHours();
        var formatted = monthNames[monthInd] + " " + day + ", " + year + "\n"; //hoursFormatted[hoursUnformatted] + ":" + ("0" + date.getMinutes()).slice(-2) + " " + end[hoursUnformatted];  
        dates[i] = formatted;
        console.log(dates[i]);
        dateSplit.push({d: day, m: monthNames[monthInd], y: year, h: hoursFormatted[hoursUnformatted], m: ("0" + date.getMinutes()).slice(-2), e: end[hoursUnformatted]});
        //timestamp.innerHTML = formatted;
        //painLevel.innerHTML = painBucketValues[i];
        
    }


    var bucketWidth = seconds / buckets;
    var painBucketValues = new Array(buckets);
    var painBucketValues1 = new Array(buckets);
    var painBucketValues2 = new Array(buckets);
    var painBucketValues3 = new Array(buckets);
    var h = 0;
    var j = 0;
    var k = 0;

    var bucketCount = new Array(buckets);

    for (var i = 0; i < buckets; i++) {
        painBucketValues[i] = 0.0;
        painBucketValues1[i] = 0.0;
        painBucketValues2[i] = 0.0;
        painBucketValues3[i] = 0.0;
        bucketCount[i] = 0.0;
    }

    var logArray = logs[1].split(',');
    var timeStamp = logArray[0] * 1000;
    var timeFormat = formatDate(timeStamp);
    var Month = timeFormat.month;
    var Day = parseFloat(timeFormat.day);
    console.log(timeFormat);
    var painLevel = logArray[1];

    if ((parseFloat(timeFormat.hours) >= 8 && parseFloat(timeFormat.hours) < 12 && timeFormat.end == 'am') || (parseFloat(timeFormat.hours) < 2 && timeFormat.end == 'pm')) {
        painBucketValues1[h] = painBucketValues[h] + parseFloat(logArray[1]);
        h++;
    }
            //load second between 2 pm and 8 pm
    else if (timeFormat.hours >= 2 && timeFormat.hours < 8 && timeFormat.end == 'pm') {
        painBucketValues2[j] = parseFloat(logArray[1]);
        j++;
    }
        //load third array, everything else
    else if ((timeFormat.hours >= 8 && timeFormat.hours <= 12 && timeFormat.end == 'pm') || (timeFormat.hours < 8 && timeFormat.end == 'am')) {
        painBucketValues3[k] = parseFloat(logArray[1])
        k++;
    }
    var ha = 1;
    var ka = 1;
    var ja = 1;


    for (var i = 2; i < buckets; i++) {
        logArray = logs[i].split(',');
        timeStamp = logArray[0] * 1000;
        timeFormat = formatDate(timeStamp);
        console.log(timeFormat);
        var painLevel = parseFloat(logArray[1]);
        if (Day == parseFloat(timeFormat.day) && Month == timeFormat.month) {
            if ((parseFloat(timeFormat.hours) >= 8 && parseFloat(timeFormat.hours) <= 12 && timeFormat.end == 'am') || (parseFloat(timeFormat.hours) < 2 && timeFormat.end == 'pm')) {
                painBucketValues1[h] = (painBucketValues[h] * ha + painLevel) / (ha + 1);
                ha++;
                
            }
            //load second between 2 pm and 8 pm
            else if (timeFormat.hours >= 2 && timeFormat.hours < 8 && timeFormat.end == 'pm') {
                painBucketValues2[j] = (painBucketValues[j] * ja + painLevel)/ (ja + 1);
                ja++;
                
            }
            //load third array, everything else
            else if ((timeFormat.hours >= 8 && timeFormat.hours <= 12 && timeFormat.end == 'pm') || (timeFormat.hours < 8 && timeFormat.end == 'am')) {
                painBucketValues3[k] = (painBucketValues[k] * ka + painLevel)/ (ka + 1);
                ka++;
                
            }

        } 
        else { //reformat day
            //console.log("Day = " + Day + ", timeFormat.day = " + timeFormat.day);
            //console.log("Month = " + Month + ", timeFormat.month = " + timeFormat.month);
            Day = parseFloat(timeFormat.day);
            Month = timeFormat.month;
            ha = 1;
            ja = 1;
            ka = 1;
            h++;
            j++;
            k++;

        }

    }

    console.log(painBucketValues1);
    console.log(painBucketValues2);
    console.log(painBucketValues3);
    /*for (var i = 1; i < logs.length; i++) {
        logArray = logs[i].split(',');
        //console.log(logArray);
        var timestamp = logArray[0] * 1000;
        if (timestamp >= currentDate - seconds * 1000) {
            var painLevel = parseFloat(logArray[1]);
            var bucketNumber = Math.floor((currentDate - timestamp) / (bucketWidth * 1000));
//            console.log(bucketNumber);
            painBucketValues[bucketNumber] = (painBucketValues[bucketNumber] * bucketCount[bucketNumber] + painLevel) / (bucketCount[bucketNumber] + 1);
            //console.log(painBucketValues[bucketNumber]);
            bucketCount[bucketNumber] = bucketCount[bucketNumber] + 1;
        }
    } */



/*    var row = generateTable.insertRow(0);
    var timestamp = row.insertCell(0);
    var painLevel = row.insertCell(1);
    logArray = logs[0].split(',');
    timestamp.innerHTML = logArray[0];
    painLevel.innerHTML = logArray[1];

    var monthNames = [
        "Jan", "Feb", "Mar",
        "Apr", "May", "Jun", "Jul",
        "Aug", "Sept", "Oct",
        "Nov", "Dec"
    ];

    var hoursFormatted = [
        12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
        12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
    ];

    var end = [
        "am", "am", "am", "am", "am", "am", 
        "am", "am", "am", "am", "am", "am", 
        "pm", "pm", "pm", "pm", "pm", "pm",
        "pm", "pm", "pm", "pm", "pm", "pm"
    ];

    var dates = new Array(buckets);
    var dateSplit = new Array(buckets);


    for (var i = 0; i < buckets; i++) {
        row = generateTable.insertRow(i + 1);
        timestamp = row.insertCell(0);
        painLevel = row.insertCell(1);
        //var percent = row.insertCell(2);
        var date = new Date(currentDate - i * bucketWidth * 1000);
        
        var day = date.getDate();
        var monthInd = date.getMonth();
        var year = date.getFullYear();
        var hoursUnformatted = date.getHours();
        var formatted = monthNames[monthInd] + " " + day + ", " + year + "\n"; //hoursFormatted[hoursUnformatted] + ":" + ("0" + date.getMinutes()).slice(-2) + " " + end[hoursUnformatted];  
        dates[i] = formatted;
        dateSplit.push({d: day, m: monthNames[monthInd], y: year, h: hoursFormatted[hoursUnformatted], m: ("0" + date.getMinutes()).slice(-2), e: end[hoursUnformatted]});
        timestamp.innerHTML = formatted;
        painLevel.innerHTML = painBucketValues[i];
        
    } */

    var heartRateTuples = new Array();
    var heartRateDates = new Array();
    var minDate = currentDate - (seconds * 1000);
    var timeWidth = currentDate - minDate;


    var maxHeartRate = 0;
    for (var i = 1; i < heartRateLogs.length - 1; i++) {
        var heartRateLog = heartRateLogs[i].split(',');
        var logTimestamp = parseFloat(heartRateLog[0] * 1000);
        //console.log(formatDate(minDate));
        if (logTimestamp >= minDate) {
            if (heartRateLog[1] > maxHeartRate) {
                maxHeartRate = parseInt(heartRateLog[1]);
            }

            heartRateTuples.push(parseFloat(heartRateLog[1]));
        }
        heartRateDates[i - 1] = (formatDate(logTimestamp));
        heartRateTuples[i - 1] = (parseFloat(heartRateLog[1]));


        //console.log(formatDate(logTimestamp));
    }

    //console.log(heartRateDates);
    //console.log(heartRateTuples);

    var prevM = heartRateDates[0].month;
    var prevD = heartRateDates[0].day;
    var prevY = heartRateDates[0].year;
    var prevH = heartRateDates[0].hour;
    var timeOf = heartRateDates[0].end;
    var repeat = 1;
    var total = 0;

//    var finalizedHeartRates = new Array();
//    var finalizedHeartDays = new Array();

    for (var j = 1; j < heartRateTuples.length - 1; j++) {
        if (heartRateDates[j].month == prevM && heartRateDates[j].day == prevD && heartRateDates[j].year == prevY) { //&& heartRateDates[j].hour == prevH && heartRateDates[j].end == timeOf) {
            total += parseFloat(heartRateTuples[j]);
            //console.log(heartRateDates[j].month + " " + heartRateDates[j].day  + ", " + heartRateDates[j].year);
            //console.log(total);
            repeat++;
        } else {
            finalizedHeartRates.push(parseFloat(total/repeat));
            //console.log(total);
            finalizedHeartDays.push(prevM + " " + prevD + ", " + prevY) //+ "\n" + hour + ":00" + end);
            total = 0;
            repeat = 1;
            prevM = heartRateDates[j].month;
            prevD = heartRateDates[j].day;
            prevY = heartRateDates[j].year;
            //prevH = heartRateDates[j].hour;
            //timeOf = heartRateDates[j].end;

        }
    }
    finalizedHeartRates.push(parseFloat(total/repeat));
    finalizedHeartDays.push(prevM + " " + prevD + ", " + prevY) //+ "\n" + hour + ":00" + end);




    var stepCountTuples = new Array();
    var stepCount = 0;
    var division = 1;
    //console.log(minDate);
    for (var i = 0; i < stepCountLogs.length; i++) {
        var stepCountLog = stepCountLogs[i].split(',');
        var logTimestamp = parseFloat(stepCountLog[0] * 1000);
        if (logTimestamp >= minDate) {
            stepCount += parseInt(stepCountLog[1]);
            stepCountTuples.push(stepCount);
        }
    }


    loadGraph(painBucketValues, painBucketValues1, painBucketValues2, painBucketValues3, dates, heartRateTuples, maxHeartRate, stepCountTuples);
    refreshMap(locationLogs, minDate);

    finalizedHeartDays = [];
    finalizedHeartRates = [];
    heartRateDates = [];
    heartRateTuples = [];
}


function loadGraph(painBucketValues, painBucketValues1, painBucketValues2, painBucketValues3, labels, heartRateTuples, maxHeartRate, stepCountTuples) {


    for (var i = 0; i < painBucketValues.length / 2; i++) {
        var aux = painBucketValues[i];
        painBucketValues[i] = painBucketValues[painBucketValues.length - i - 1];
        painBucketValues[painBucketValues.length - i - 1] = aux;

        aux = labels[i];
        labels[i] = labels[labels.length - i - 1];
        labels[labels.length - i - 1] = aux;
    }

    //console.log(labels);

    /*var colorsOfChart1 = new Array(painBucketValues1.length);
    var colorsOfChart2 = new Array(painBucketValues2.length);
    var colorsOfChart3 = new Array(painBucketValues3.length);
    for (var i = 0; i < colorsOfChart1.length; i ++) {
        var color = numberToColorHsl(100 - Math.floor(painBucketValues1[i] * 10));
        //colors[i] = 'rgba(255, 0, 0, 0.6)';
        colorsOfChart1[i] = color;
    }
    for (var i = 0; i < colorsOfChart2.length; i ++) {
        var color = numberToColorHsl(100 - Math.floor(painBucketValues2[i] * 10));
        //colors[i] = 'rgba(255, 0, 0, 0.6)';
        colorsOfChart2[i] = color;
    }
    for (var i = 0; i < colorsOfChart3.length; i ++) {
        var color = numberToColorHsl(100 - Math.floor(painBucketValues3[i] * 10));
        //colors[i] = 'rgba(255, 0, 0, 0.6)';
        colorsOfChart3[i] = color;
    } */



    var maxStepCountY = 0;
    if (stepCountTuples.length > 0) {
        maxStepCountY = stepCountTuples[stepCountTuples.length - 1] * 1.1;
    }

    var heartRateChart = new Highcharts.Chart('heartRate', {

        heartRateChart: {
           height: 300,
           //marginTop: 10,
           //marginBottom: 10
        },

        title: {
            text: 'Heart Rate'
        },


        xAxis: {
            categories: finalizedHeartDays, //labels
            max: 8, 
            scrollbar: {
                enabled: true,
                showFull: false
            }
        },

        yAxis : {
            min: 0,
            max: maxHeartRate + 10 - (maxHeartRate % 10),
            minRange: 10
        }, 
        
        legend: {
            verticalAlign: 'top',
            //y: 100,
            align: 'right'
        },

        rangeSelector: {
            selected: 1
        },


        series: [{
            name: 'Heart Rate',
            data: finalizedHeartRates,
            tooltip: {
                valueDecimals: 2
            }
        }]
    });


    var stepCountChart = new Highcharts.Chart('stepCount', {

        stepCountChart: {
           height: 300,
           //marginTop: 10,
           //marginBottom: 10
        },

        title: {
            text: 'Step Count'
        },

        xAxis: {
            categories: labels,
            max: 8, 
            scrollbar: {
                enabled: true,
                showFull: false
            }
        },

        yAxis : {
            min: 0,
            //max: maxStepCountY,
            minRange: 10
        }, 
        
        legend: {
            verticalAlign: 'top',
            //y: 100,
            align: 'right'
        },

        rangeSelector: {
            selected: 1
        },

        series: [{
            name: 'Step Count',
            data: stepCountTuples.slice(0, labels.length)
        }]
    });

    var painLevelBefore = Highcharts.chart('barChartBeforeOp', {
        chart: {
            type: 'column'

        },
        title: {
            text: 'Pain Level Prior to Operation'
        },

        series: [{
            name: 'painLevel',
            data: [3],

        }]

    });


    var painLevels = Highcharts.chart('barChart', {
        chart: {
            type: 'column'
        },
        title: {
            text: 'Pain Level'
        },
        xAxis: {
            //categories: finalizedHeartDays,//labels,
            max: 15, 
            scrollbar: {
                enabled: true,
                showFull: false
            }
        },
        yAxis: {
            allowDecimals: true,
            title: {
                text: 'Pain Level'
            }
        },
        series: [{
            name: '8 am',
            data: painBucketValues1,
            //colorByPoint: true,
            //color: 'blue'
        }, {
            name: '2 pm',
            data: painBucketValues2, 
            //colorByPoint: true, 
            //color: 'red'

        }, {
            name: '8 pm', 
            data: painBucketValues3,
            //colorByPoint: true,
            //color: 'green'

        }]
    });


}

function numberToColorHsl(i) {
    // as the function expects a value between 0 and 1, and red = 0° and green = 120°
    // we convert the input to the appropriate hue value
    var hue = i * 1.2 / 360;
    // we convert hsl to rgb (saturation 100%, lightness 50%)
    var rgb = hslToRgb(hue, 0.6, 0.5);
    // we format to css value and return
    return 'rgb(' + rgb[0] + ',' + rgb[1] + ',' + rgb[2] + ')'; 
}

function compareCoordinates(a, b) {
        if (a['x'] < b['x']) {
            return 1;
        }
        return -1;
    }

function refreshMap(locationLogs, minDate) {
    var map = new google.maps.Map(document.getElementById('map'), {
      zoom: 10,
      center: {lat: 39.294734, lng: -76.613838}
  });


    var firstLine = locationLogs[1].split(',');
    var minLat = parseFloat(firstLine[1]);
    var maxLat = parseFloat(firstLine[1]);
    var minLong = parseFloat(firstLine[2]);
    var maxLong = parseFloat(firstLine[2]);

    for (var i = 1; i < locationLogs.length; i++) {
        var locationLog = locationLogs[i].split(',');
        if (parseFloat(locationLog[0]) * 1000 >= minDate){
        var lat = parseFloat(locationLog[1]);
        var lng = parseFloat(locationLog[2]);
        if (lat < minLat) {
            minLat = lat;
        } else if (lat > maxLat) {
            maxLat = lat;
        }

        if (lng < minLong) {
            minLong = lng;
        } else if (lng > maxLong) {
            maxLong = lng;
        }

        var marker = new google.maps.Marker({
            position: {lat: lat, lng: lng},
            map: map
        });
    }
    }

    map.setCenter(new google.maps.LatLng((minLat + maxLat) / 2, (minLong + maxLong) / 2));
    var bounds = new google.maps.LatLngBounds();
    bounds.extend(new google.maps.LatLng(minLat, minLong));
    bounds.extend(new google.maps.LatLng(minLat, maxLong));
    bounds.extend(new google.maps.LatLng(maxLat, minLong));
    bounds.extend(new google.maps.LatLng(maxLat, maxLong));
    map.fitBounds(bounds);
}

function hslToRgb(h, s, l){
    var r, g, b;

    if(s == 0){
            r = g = b = l; // achromatic
        }else{
            var hue2rgb = function hue2rgb(p, q, t){
                if(t < 0) t += 1;
                if(t > 1) t -= 1;
                if(t < 1/6) return p + (q - p) * 6 * t;
                if(t < 1/2) return q;
                if(t < 2/3) return p + (q - p) * (2/3 - t) * 6;
                return p;
            }

            var q = l < 0.5 ? l * (1 + s) : l + s - l * s;
            var p = 2 * l - q;
            r = hue2rgb(p, q, h + 1/3);
            g = hue2rgb(p, q, h);
            b = hue2rgb(p, q, h - 1/3);
        }

        return [Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)];
    }

    function changePatientID() {
        var field = document.getElementById('patientIDField');
        if (field.value != '') {
            sessionStorage.setItem('patientID', parseInt(field.value));
            var heading = document.getElementById('patientIDHeading');
            heading.innerHTML = '<center>Patient ID: ' + parseInt(field.value) + '</center>';
        }
        displayData('hour');
    }

    window.onload = function() {
        displayData('month');
        var heading = document.getElementById('patientIDHeading');
        heading.innerHTML = '<center>Patient ID: ' + sessionStorage.getItem('patientID') + '</center>';
    }

