


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
        url: "http://127.0.0.1:5000/getPatientData", //http://healthalytics.herokuapp.com/getPatientData
        data: {usernameInput: userInfo.username, passwordInput: userInfo.password, patientCodeInput: userInfo.patientCode},
        dataType: "json",
        global: false,
        async: false,

        success: function(data) {
            //console.log(data);
            sessionStorage.setItem('theData', data);
            window.location.href = 'index';
        },
        error: function(xhr, status, error) {
            //console.log("status: " + status);
            alert('error');

        }

    });

};

window.onload = function() {
    document.getElementById('submit').onclick = function() {
        verifyUserInput();
    }
}
    
    
    //console.log(obj);
    
//});

