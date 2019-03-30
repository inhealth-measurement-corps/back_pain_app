//
//  GlobalVariables.swift
//  searsonApp
//
//  Created by Matias Eisler on 2/7/17.
//  Copyright © 2017 Matias Eisler. All rights reserved.
//

import Foundation


private let _globalVariablesInstance : GlobalVariables = { GlobalVariables() } ();

class GlobalVariables {
    
    //let server = "http://127.0.0.1:5000"
    //let server = "http://10.162.80.138:5000"
    let server = "https://painlog.herokuapp.com/"
    //let patientID = "1"
    var patientCreated = false
    var newPatientID = -1
        
    class func sharedInstance() -> GlobalVariables {
        return _globalVariablesInstance;
    }
}

class Main {
    
    var patientID:String
    init(patientID:String) {
        
        self.patientID = patientID
    }
}

var mainInstance = Main(patientID:"My Global Class")


