//
//  Requests.swift
//  ElSuperDT
//
//  Created by Sebastian del Campo on 20/10/2015.
//  Copyright © 2015 Sebastian del Campo. All rights reserved.
//

import UIKit
import CoreData

private let _requestsInstance : Requests = { Requests() }();


class Requests:NSObject,NSURLConnectionDelegate{
    
    static let sharedInstance = Requests()
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext;
    let childObjectContext = NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
    var isSyncing = false
    var currentConnectionString:String?;
    
    var patientExists: NSURLConnection?
    var sendLogs: NSURLConnection?
    var createPatient: NSURLConnection?
    
    
    let server = GlobalVariables.sharedInstance().server
    var data = NSMutableData();
    
    
    fileprivate override init(){
        childObjectContext.parent = managedObjectContext
    }
    
   
    
    //MARK: requests
    
    func updateImageData(_ token:String,image:UIImage?,imageName:String, controller: String, teamID: Int = 0){
        var request = NSMutableURLRequest()
        if controller == "Users" {
            request = NSMutableURLRequest(url: URL(string: "\(server)/Users/updateImageData")!)
        } else if controller == "Teams" {
            request = NSMutableURLRequest(url: URL(string: "\(server)/Teams/updateTeamImageData")!)
        }
        let boundary = "UpdateImageDataBoundary";
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        let boundaryString = "\r\n--\(boundary)\r\n"
        
        let imageContentString = "Content-Disposition: form-data; name=\"image\"; filename=\"\(imageName)\"\r\n"
        let octetString = "Content-Type: application/octet-stream\r\n\r\n"
        
        let tokenContentString = "Content-Disposition: form-data; name=\"token\"\r\n\r\n \(token)"

        let teamIDString = "Content-Disposition: form-data; name=\"team_id\"\r\n\r\n \(teamID)"

        
        if let _image = image{
            let imageData = UIImageJPEGRepresentation(_image,1)
            body.append(boundaryString.data(using: String.Encoding.utf8)!)
            body.append(imageContentString.data(using: String.Encoding.utf8)!)
            body.append(octetString.data(using: String.Encoding.utf8)!)
            body.append(NSData(data: imageData!) as Data)
            body.append(boundaryString.data(using: String.Encoding.utf8)!)
        }
        
        body.append(tokenContentString.data(using: String.Encoding.utf8)!)
        body.append(boundaryString.data(using: String.Encoding.utf8)!)
        body.append(teamIDString.data(using: String.Encoding.utf8)!)
        body.append(boundaryString.data(using: String.Encoding.utf8)!)
        
        request.httpMethod = "POST"
        request.httpBody = body as Data
        
        /*if controller == "Users" {
            updateImageData = NSURLConnection(request: request as URLRequest, delegate: self);
        } else if controller == "Teams" {
            updateTeamImageData = NSURLConnection(request: request as URLRequest, delegate: self)
        }*/
    }
    
    func sendRequest(_ jsonDict:NSDictionary, action:String ){
        currentConnectionString = action;
        let request = NSMutableURLRequest(url: URL(string: "\(server)/\(action)")!);
        request.httpMethod = "POST"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
        } catch _ as NSError {
            
            request.httpBody = nil
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //request.setValue("", forHTTPHeaderField: "Accept-Encoding")
        switch (action) {
            case "patients/patientExists":
                patientExists = NSURLConnection(request: request as URLRequest, delegate: self)
            case "patients/sendLogs":
                sendLogs = NSURLConnection(request: request as URLRequest, delegate: self)
            case "patients/createPatient":
                createPatient = NSURLConnection(request: request as URLRequest, delegate: self)
            default:
                break;
        }
    }
    
    func logError(_ error:String){
        
        NSLog(error);
        
    }
    
    //MARK: NSURLConnectionDelegate
    
    
    func connection(_ connection: NSURLConnection!, didReceiveResponse response: URLResponse!) {
        data = NSMutableData()
    }
    
    func connection(_ connection: NSURLConnection!, didReceiveData data: Data!) {
        self.data.append(data);
    }
    
    
    
    func connectionDidFinishLoading(_ connection: NSURLConnection) {
        
        
        do {
            let responseDict = try JSONSerialization.jsonObject(with: data as Data, options: []) as! NSDictionary
            
            let status = responseDict.value(forKey: "status") as! String;
            
            if (status == "ok") {
                if connection == patientExists {
                    patientExists(responseDict)
                } else if connection == sendLogs {
                    sendLogs(responseDict)
                } else if connection == createPatient {
                    createPatient(responseDict)
                }
            }
                
            else if (status == "error") {
                if connection == patientExists {
                    sendErrorNotification(responseDict, name: "patientExistsFailed")
                } else if connection == sendLogs {
                    sendErrorNotification(responseDict, name: "sendLogsFailed")
                } else if connection == createPatient {
                    sendErrorNotification(responseDict, name: "createPatientFailed")
                }

            }
            
        } catch {
            
            print("\(error)");
            let jsonString = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)!;
            print(jsonString)
           // logError(jsonString! as String);
        }
    }
    
    
    
    func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        let errorDict: Dictionary<String,String>! = [
            "errorMessage": "Couldn't contact the server.",
        ]
        if connection == patientExists {
            sendErrorNotification(errorDict as NSDictionary, name: "patientExistsFailed");
        } else if connection == sendLogs {
            sendErrorNotification(errorDict as NSDictionary, name: "sendLogsFailed")
        } else if connection == createPatient {
            sendErrorNotification(errorDict as NSDictionary, name: "createPatientFailed")
        }
        
    }
    
    func convertStringToDictionary(_ text: String) -> NSArray? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? NSArray
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
    //MARK: Connection Ok Actions
    
    
    func patientExists(_ responseDict: NSDictionary) {
        if let data = responseDict["data"] as? NSDictionary {
            if let exists = data["exists"] as? String {
                if exists == "true" {
                    print("EXISTS!!!")
                } else {
                    print("DOES NOT EXIST!!!")
                }
            }
        }
    }
    
    func sendLogs(_ responseDict: NSDictionary) {
        if let data = responseDict["data"] as? NSDictionary {
            
            for timestamp in (data["painLogs"] as! NSArray) {
                let log = DatabaseManager.getItem(entityName: "Log", predicateString: "timestamp=\(timestamp)") as? Log
                log?.serverConfirmed = true
            }
            
            for timestamp in (data["locationLogs"] as! NSArray) {
                var log = DatabaseManager.getItem(entityName: "LocationLog", predicateString: "timestamp=\(timestamp)") as? LocationLog

                log?.serverConfirmed = true
            }
            
            for timestamp in (data["heartRateLogs"] as! NSArray) {
                let log = DatabaseManager.getItem(entityName: "HeartRateLog", predicateString: "timestamp = \(timestamp)") as? HeartRateLog
                log?.serverConfirmed = true
            }
            
            for timestamp in (data["stepCountLogs"] as! NSArray) {
                let log = DatabaseManager.getItem(entityName: "StepCountLog", predicateString: "timestamp = \(timestamp)") as? StepCountLog
                log?.serverConfirmed = true
            }
            
            do {
                try (UIApplication.shared.delegate as! AppDelegate).managedObjectContext.save()
            } catch {
                print("EXCEPTION")
            }
        }
    }
            
    func createPatient(_ responseDict: NSDictionary) {
        if let value = responseDict["created"] as? String {
            if value == "true" {
                GlobalVariables.sharedInstance().patientCreated = true
            } else {
                GlobalVariables.sharedInstance().patientCreated = false
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name("createPatientFinished"), object: self)
    }
    
    //MARK: Connection Error Actions
    
    func sendErrorNotification(_ responseDict:NSDictionary, name:String){
        let errorMessage = responseDict.value(forKey: "errorMessage") as! String;
        let errorDict: Dictionary<String,String>! = [
            "error": errorMessage,
        ]
        NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: self, userInfo: errorDict)
    }
}
