//
//  PercentageInterfaceController.swift
//  searsonApp
//
//  Created by Matias Eisler on 12/17/16.
//  Copyright © 2016 Matias Eisler. All rights reserved.
//

import WatchKit

class PercentageInterfaceController: WKInterfaceController {
    
    @IBOutlet var tableView: WKInterfaceTable!
    @IBOutlet var acceptButton: WKInterfaceButton!
    
    var timestamp = 0.0
    var pain = 0
    var valueSelected = false
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        
        let dict = context as! Dictionary<String, Any>
        
        pain = dict["pain"] as! Int
        timestamp = dict["timestamp"] as! Double
        
        var rowTypes = [String]()
        for i in 0...20 {
            rowTypes.append("percentageRow")
        }
        tableView.setRowTypes(rowTypes)
        
        for i in 0...20 {
            let row = tableView.rowController(at: i) as! PercentageRowController
            //row.label.setText("\(5 * i)% - \(5 * i + 5)%")
            row.label.setText("\(5 * i) % Relief")
            row.group.setBackgroundColor(UIColor(hue: 0.35 - 0.035 * CGFloat(19 - i) / 2, saturation: 1, brightness: 0.8, alpha: 0.9))
        }
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        if valueSelected == false {
            valueSelected = true
            /*for i in 0...(tableView.numberOfRows - 1) {
                if i != rowIndex {
                    let controller = tableView.rowController(at: i) as! PercentageRowController
                    controller.group.setBackgroundColor(UIColor(red: 196.0/255.0, green: 196.0/255.0, blue: 196.0/255.0, alpha: 1))
                }
            }*/
            if rowIndex == 0 {
                ExtensionDelegate.setValuesForKey(pain: pain, percentage: (rowIndex * 5) + 1, key: String(timestamp))
            } else {
                ExtensionDelegate.setValuesForKey(pain: pain, percentage: (rowIndex * 5) , key: String(timestamp))
            }
            WKInterfaceDevice.current().play(.success)
            exit(0)
        }
    }
    
    
    @IBAction func sendDataClicked() {
        if ExtensionDelegate.session!.isReachable {
            //let messageData = ["timestamp": timestamp, "pain": pain, "percentage": 5.0 * Double(rowIndex) + 2.5] as [String : Any]
            let painValues = ExtensionDelegate.getPainValues()
            let locations = ExtensionDelegate.getLocationValues()
            var locationArray = [NSDictionary]()
            for location in locations {
                let locationDict = NSMutableDictionary()
                locationDict.setValue(location.timestamp.timeIntervalSince1970.description, forKey: "timestamp")
                locationDict.setValue(location.coordinate.latitude.description, forKey: "latitude")
                locationDict.setValue(location.coordinate.longitude.description, forKey: "longitude")
                locationArray.append(locationDict)
            }
            
            let heartRatesValues = NSMutableDictionary(dictionary: ExtensionDelegate.getHeartRateValues())
            let stepCountValues = NSMutableDictionary(dictionary: ExtensionDelegate.getStepCountValues())
            
            //let patientID = ExtensionDelegate.getUserID()
            
            let messageData = NSMutableDictionary()
            //messageData.setValue(patientID, forKey: "patient_id")
            messageData.setValue(painValues, forKey: "pain_logs")
            messageData.setValue(locationArray, forKey: "location_logs")
            messageData.setValue(heartRatesValues, forKey: "heart_rate_logs")
            messageData.setValue(stepCountValues, forKey: "step_count_logs")
            /*ExtensionDelegate.session?.sendMessage((messageData as NSDictionary) as! [String : AnyObject], replyHandler: { replyMessage in
             let replyDict = replyMessage as NSDictionary
             if replyDict["status"] as? String == "received" {
             WKInterfaceDevice.current().play(.success)
             //(WKExtension.shared().delegate as! ExtensionDelegate).perform("suspend")
             exit(0)
             } else {
             //(WKExtension.shared().delegate as! ExtensionDelegate).perform("suspend")
             print("ERROR")
             WKInterfaceDevice.current().play(.failure)
             exit(0)
             }
             }, errorHandler: {error in
             //some code
             print(error.localizedDescription)
             WKInterfaceDevice.current().play(.failure)
             //(WKExtension.shared().delegate as! ExtensionDelegate).perform("suspend")
             exit(0)
             })*/
            
            ExtensionDelegate.transferringFile = true
            let fileDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/dataToTransfer"
            
            if messageData.write(toFile: fileDirectory, atomically: false) == true {
                ExtensionDelegate.session?.transferFile(URL(string: "file://" + fileDirectory)!, metadata: nil)
            
            messageData.removeAllObjects()
            /*
            UserDefaults.standard.removeObject(forKey: "pain")
            UserDefaults.standard.removeObject(forKey: "locations")
            UserDefaults.standard.removeObject(forKey: "heartRates")
            UserDefaults.standard.removeObject(forKey: "stepCounts")
             */
            } else {
                print("error creating file")
            }
            
        } else {
            //(WKExtension.shared().delegate as! ExtensionDelegate).perform("suspend")
            WKInterfaceDevice.current().play(.success)
            exit(0)
            
        }
        
    }
}
