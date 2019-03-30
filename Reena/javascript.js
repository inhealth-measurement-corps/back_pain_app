    
var obj;


function verifyUserInput() {
    var userInfo = {
        username: $("#usernameInput").val(),
        password: $("#passwordInput").val(),
        patientCode: $("#patientCodeInput").val()
    }

    sessionStorage.setItem('user', userInfo.username);
    sessionStorage.setItem('pass', userInfo.password);
    sessionStorage.setItem('iD', userInfo.patientCode);

    console.log(userInfo.username);
    console.log(userInfo.password);
    console.log(userInfo.patientCode);
    
    //userInfo.username = $("#usernameInput").val();
    //userInfo.password = = $("#passwordInput").val();
    //userInfo.patientCode = = $("#patientCodeInput").val();

    $.ajax ({
        type: "POST",
        //invocation = new XMLHttpRequest(),
        url: "https://healthalytics.herokuapp.com/getPatientData", //http://healthalytics.herokuapp.com/getPatientData
        data: {usernameInput: userInfo.username, passwordInput: userInfo.password, patientCodeInput: userInfo.patientCode},
        dataType: "json",
        global: false,
        async: false,

        success: function(data) {
            //console.log(data);
            sessionStorage.setItem('theData', data);
        },
        error: function(xhr, status, error) {
            //console.log("status: " + status);
            alert('error');

        }

    });

    window.location.href = 'index.html';

};



    
    
    //console.log(obj);
    
//});

