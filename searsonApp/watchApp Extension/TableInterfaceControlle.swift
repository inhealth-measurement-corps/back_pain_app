//
//  TableInterfaceControlle.swift
//  searsonApp
//
//  Created by Matias Eisler on 11/9/16.
//  Copyright © 2016 Matias Eisler. All rights reserved.
//

import WatchKit
import CoreLocation
import WatchConnectivity

@available(watchOSApplicationExtension 3.0, *)
class TableInterfaceController: WKInterfaceController, CLLocationManagerDelegate {
    
    var valueSelected = false
    
    @IBOutlet var table: WKInterfaceTable!
    
    static var locationManager: CLLocationManager!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        TableInterfaceController.locationManager = CLLocationManager()
        TableInterfaceController.locationManager.delegate = self
        TableInterfaceController.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //TableInterfaceController.locationManager.distanceFilter = kCLDistanceFilterNone
        TableInterfaceController.locationManager.distanceFilter = 15
        TableInterfaceController.locationManager.requestAlwaysAuthorization()
        TableInterfaceController.locationManager.setValue(true, forKey: "allowsBackgroundLocationUpdates")
        TableInterfaceController.locationManager.performSelector(inBackground: "pausesLocationUpdatesAutomatically", with: false)
        TableInterfaceController.locationManager.startUpdatingLocation()
        //TableInterfaceController.locationManager.requestLocation()
        //printLocations()
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        loadTable()

    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func sendDataClicked2() {
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
            
            print(heartRatesValues.count)
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
                
            painValues.removeAllObjects()
            messageData.removeAllObjects()
            UserDefaults.standard.removeObject(forKey: "pain")
            UserDefaults.standard.removeObject(forKey: "locations")
            UserDefaults.standard.removeObject(forKey: "heartRates")
            UserDefaults.standard.removeObject(forKey: "stepCounts")
 
            } else {
                print("error creating file")
            }
            
        } else {
            //(WKExtension.shared().delegate as! ExtensionDelegate).perform("suspend")
            WKInterfaceDevice.current().play(.success)
            exit(0)
            
        }
        
    }
    
    func loadTable() {
        var rowTypes = [String]()
        for i in 0...10 {
            rowTypes.append("painRow")
        }
        table.setRowTypes(rowTypes)
        for i in 0...10 {
            let row = table.rowController(at: i) as! PainRowController
            if i == 0 {
                row.image.setImage(UIImage(named: "Pain1White"))
            } else {
                row.image.setImage(UIImage(named: "Pain\(i)White")!)
            }
            row.label.setText(" \(i)")
            row.group.setBackgroundColor(UIColor(hue: 0.35 - 0.035 * CGFloat(i+1), saturation: 0.8, brightness: 0.8, alpha: 0.9))
            //row.label.setTextColor(UIColor(hue: 0.35 - 0.035 * CGFloat(i+1), saturation: 1, brightness: 1, alpha: 0.9))
        
        }
        
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        WKInterfaceDevice.current().play(.click)
        
        let timestamp = Date().timeIntervalSince1970
       
        let defaults = UserDefaults.standard
        let token = defaults.string(forKey: "myKey")
        //var array = ExtensionDelegate.reminder
        //var n = ExtensionDelegate.reminder.count
        //if session.mess == 0 {
        if token == "2" {
        self.presentController(withName: "PercentageInterfaceController", context: ["timestamp": timestamp, "pain": rowIndex])
        } else {
            if valueSelected == false {
                valueSelected = true
                /*for i in 0...(tableView.numberOfRows - 1) {
                 if i != rowIndex {
                 let controller = tableView.rowController(at: i) as! PercentageRowController
                 controller.group.setBackgroundColor(UIColor(red: 196.0/255.0, green: 196.0/255.0, blue: 196.0/255.0, alpha: 1))
                 }
                 }*/
                
                ExtensionDelegate.setValuesForKey(pain: rowIndex, percentage: 0, key: String(timestamp))
                WKInterfaceDevice.current().play(.success)
                exit(0)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        if let loc = locations.last {
            var arr = [CLLocation]()
            arr.append(loc)
            ExtensionDelegate.setLocation(locations: arr)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        print(error.localizedDescription)
    }
    
    func printLocations() {
        let locations = ExtensionDelegate.getLocationValues()
        for location in locations {
            //print(location.timestamp)
            print("\(location.coordinate.latitude), \(location.coordinate.longitude)")
        }
    }

}

