 
 //
 //  ExtensionDelegate.swift
 //  watchApp Extension
 //
 //  Created by Matias Eisler on 9/30/16.
 //  Copyright © 2016 Matias Eisler. All rights reserved.
 //
 
 import WatchKit
 import WatchConnectivity
 import CoreLocation
 import HealthKit
 
 class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate, CLLocationManagerDelegate {
    
    static var reminder = [String]()
    static var session: WCSession?
    static var transferringFile = false
    
    let healthStore = HKHealthStore()
    var lastHeartRateDate: Date!
    var lastStepCountDate: Date!
    
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //print("abc")
    }
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        ExtensionDelegate.session = WCSession.default()
        ExtensionDelegate.session?.delegate = self
        ExtensionDelegate.session?.activate()
        
        let defaults = UserDefaults.standard
        let defaultValue = ["myKey" : ""]
        defaults.register(defaults: defaultValue)
        
        /*let a = ExtensionDelegate.getPainValues()
        let pref = UserDefaults.standard
        pref.setValue(NSDictionary(dictionary: a), forKey: "pain")
        pref.synchronize()*/
        
        let steps = ExtensionDelegate.getStepCountValues()
        for step in steps {
            print(step)
        }
        
        let prefs = UserDefaults.standard
        if let value = prefs.value(forKey: "lastHeartRateDate") as? Double {
            lastHeartRateDate = Date(timeIntervalSince1970: value)
        } else {
            lastHeartRateDate = Date(timeIntervalSince1970: 0)//0)
        }
        
        if let value = prefs.value(forKey: "lastStepCountDate") as? Double {
            lastStepCountDate = Date(timeIntervalSince1970: value)
        } else {
            lastStepCountDate = Date(timeIntervalSince1970: 0.0)
        }
        
        self.retrieveHeartRateData()
        self.retrieveStepCountData()
    }
    
    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //active = true
    }
    
    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
        //active = false
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        //process message and reply
        /*if let dict = message["data"] as? NSDictionary {
            ExtensionDelegate.removeConfirmedLogs(dict: dict)
        }
        
        replyHandler(["status": "removed"])*/
        let value = message["Value"] as? String
        let reminders = value!
        ExtensionDelegate.reminder.append(reminders)
        //use this to present immediately on the screen
        let defaults = UserDefaults.standard
        defaults.set(reminders, forKey: "myKey")
        defaults.synchronize()
        DispatchQueue.main.async() {
            
        }
        //send a reply
        replyHandler(["Value":"Yes" as AnyObject])
        
        /*
        if let id = message["resetWithID"] as? Int {
            let defaults = UserDefaults.standard
            defaults.setValue("\(id)", forKey: "patientID")
            defaults.removeObject(forKey: "stepCounts")
            defaults.removeObject(forKey: "lastStepCountDate")
            defaults.removeObject(forKey: "lastHeartRateDate")
            defaults.removeObject(forKey: "locations")
            defaults.removeObject(forKey: "heartRates")
            defaults.removeObject(forKey: "stepCounts")
            defaults.removeObject(forKey: "pain")
            defaults.synchronize()
            replyHandler(["status": "ok"])
          */
      //}
    }
    
    func didReceive(_ notification: UILocalNotification) {
        print("received Notification")
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("reachable: \(session.isReachable)")
    }
    
    static func setValuesForKey(pain: Int, percentage: Int, key: String) {
        let prefs = UserDefaults.standard
        let dict = getPainValues()
        var value = Dictionary<String, Int>()
        value["pain"] = pain
        value["percentage"] = percentage
        
        dict.setValue(value, forKey: key)
        prefs.setValue(dict, forKey: "pain")
        prefs.synchronize()
        print("just saved pain value \(value) for timestamp \(key)")
    }
    
    static func getPainValues() -> NSMutableDictionary {
        let prefs = UserDefaults.standard
        if let value = prefs.value(forKey: "pain") {
            return NSMutableDictionary(dictionary: value as! NSDictionary)
        } else {
            return NSMutableDictionary()
        }
        /*let prefs = UserDefaults.standard
        if let value = prefs.value(forKey: "pain") as? NSData {
            return NSKeyedUnarchiver.unarchiveObject(with: value as Data) as! NSDictionary as! NSMutableDictionary
        } else {
            return NSMutableDictionary()
        }*/

    }
    
    static func setLocation(locations: [CLLocation]) {
        let prefs = UserDefaults.standard
        var locationArray = getLocationValues()
        
        for location in locations {
            locationArray.append(location)
        }
        //prefs.setValue(locationArray, forKey: "locations")
        let data = NSKeyedArchiver.archivedData(withRootObject: locationArray)
        prefs.set(data, forKey: "locations")
        prefs.synchronize()
        print("just saved location data")
    }
    
    static func getLocationValues() -> [CLLocation] {
        let prefs = UserDefaults.standard
        if let value = prefs.value(forKey: "locations") as? NSData {
            return NSKeyedUnarchiver.unarchiveObject(with: value as Data) as! [CLLocation]
        } else {
            return [CLLocation]()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        ExtensionDelegate.setLocation(locations: locations)
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
    
    func retrieveStepCountData() {
        
        let stepCountSampleType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        let dict = ExtensionDelegate.getPainValues()
        
        //if dict.count == 0 {
        //} else {
        
            let currentDate = Date()
            //let timestamp = dict.allKeys[0]
            //guard let numStr = timestamp as? String else {
            //    return
            //}
            //let firstPainTimestamp = Double(numStr)
            
            //let date = Date(timeIntervalSince1970: firstPainTimestamp!)
            let predicate = HKQuery.predicateForSamples(withStart: currentDate.addingTimeInterval(-3600 * 24 * 14), end: currentDate, options: [.strictStartDate, .strictEndDate])
            
            let query = HKSampleQuery(sampleType: stepCountSampleType!, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, result, error) -> Void in
                
                if error != nil {
                    return
                }
                
                let prefs = UserDefaults.standard
                prefs.setValue(currentDate.timeIntervalSince1970, forKey: "lastStepCountDate")
                prefs.synchronize()
                
                if result != nil {
                    var stepCounts = NSMutableDictionary()
                    for res in result! {
                        let sample = res as! HKQuantitySample
                        let steps = Double(sample.quantity.description.characters.split{$0 == " "}.map(String.init)[0])!
                        //print("Step:","\(res.startDate.timeIntervalSince1970.description) \(steps)")
                        stepCounts.setValue(Int(steps), forKey: res.startDate.timeIntervalSince1970.description)
                    }
                    ExtensionDelegate.setStepCountValues(steps: stepCounts)
                }
            }
            self.healthStore.execute(query)
        //}
    }
    
    func retrieveHeartRateData() {
        
        let heartRateSampleType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
        
        let dict = ExtensionDelegate.getPainValues()
        
        
        //if dict.count == 0 {
            
        //} else {
            let currentDate = Date()
            //let timestamp = dict.allKeys[0]
            //guard let numStr = timestamp as? String else {
            //    return
            //}
            //let firstPainTimestamp = Double(numStr)
            
            //let date = Date(timeIntervalSince1970: firstPainTimestamp!)
            
            let predicate = HKQuery.predicateForSamples(withStart: currentDate.addingTimeInterval(-3600 * 24 * 14) , end: currentDate, options: [.strictStartDate, .strictEndDate])
            
            let query = HKSampleQuery(sampleType: heartRateSampleType!, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, result, error) -> Void in
                
                if error != nil {
                    return
                }
                let prefs = UserDefaults.standard
                prefs.setValue(currentDate.timeIntervalSince1970, forKey: "lastHeartRateDate")
                prefs.synchronize()
                
                if result != nil {
                    var heartRates = NSMutableDictionary()
                    for res in result! {
                        let sample = res as! HKQuantitySample
                        let rate = Double(sample.quantity.description.characters.split{$0 == " "}.map(String.init)[0])!
                        //print("\(res.startDate.timeIntervalSince1970) \(rate)")
                        heartRates.setValue(rate, forKey: res.startDate.timeIntervalSince1970.description)
                    }
                    ExtensionDelegate.setHeartRateValues(rates: heartRates)
                }
            }
        self.healthStore.execute(query)
        //}
    }
    
    static func setHeartRateValues(rates: NSDictionary) {
        let prefs = UserDefaults.standard
        var heartRates = getHeartRateValues()
        
        for rate in rates {
            heartRates.setValue(rate.value, forKey: rate.key as! String)
        }
        let data = NSKeyedArchiver.archivedData(withRootObject: heartRates)
        prefs.set(data, forKey: "heartRates")
        prefs.synchronize()
        print("just saved heart-rate data")
    }
    
    static func getHeartRateValues() -> NSMutableDictionary {
        let prefs = UserDefaults.standard
        if let value = prefs.value(forKey: "heartRates") as? NSData {
            return NSKeyedUnarchiver.unarchiveObject(with: value as Data) as! NSMutableDictionary
        } else {
            return NSMutableDictionary()
        }
    }
    
    static func setStepCountValues(steps: NSDictionary) {
        let prefs = UserDefaults.standard
        var stepCounts = getStepCountValues()
        
        for step in steps {
            stepCounts.setValue(step.value, forKey: step.key as! String)
        }
        let data = NSKeyedArchiver.archivedData(withRootObject: stepCounts)
        prefs.set(data, forKey: "stepCounts")
        prefs.synchronize()
        print("just saved step-count data")
    }
    
    static func getStepCountValues() -> NSMutableDictionary {
        let prefs = UserDefaults.standard
        if let value = prefs.value(forKey: "stepCounts") as? NSData {
            return NSKeyedUnarchiver.unarchiveObject(with: value as Data) as! NSMutableDictionary
        } else {
            return NSMutableDictionary()
        }
    }
    
    /*
    static func getUserID() -> String {
        let prefs = UserDefaults.standard
        if let value = prefs.value(forKey: "patientID") as? String {
            return value
        }
        exit(99)
    }
*/
    
    /*static func replacePainValues(with: NSDictionary) {
        let prefs = UserDefaults.standard
        prefs.set(with, forKey: "pain")
        prefs.synchronize()
    }
    
    static func replaceLocationValues(with: [CLLocation]) {
        let prefs = UserDefaults.standard
        let data = NSKeyedArchiver.archivedData(withRootObject: with)
        prefs.set(data, forKey: "locations")
        prefs.synchronize()
    }
    
    static func replaceHeartRateValues(with: NSDictionary) {
        let prefs = UserDefaults.standard
        let data = NSKeyedArchiver.archivedData(withRootObject: with)
        prefs.set(data, forKey: "heartRates")
        prefs.synchronize()
    }
    
    static func replaceStepCountValues(with: NSDictionary) {
        let prefs = UserDefaults.standard
        let data = NSKeyedArchiver.archivedData(withRootObject: with)
        prefs.set(data, forKey: "stepCounts")
        prefs.synchronize()
    }
    
    static func removeConfirmedLogs(dict: NSDictionary) {
            if let painLogs = dict["painLogs"] as? NSArray {
                let storedLogs = ExtensionDelegate.getPainValues()
                for timestamp in painLogs {
                    storedLogs.removeObject(forKey: "\(timestamp)")
                }
                ExtensionDelegate.replacePainValues(with: storedLogs)
            }
            
            if let locationLogs = dict["locationLogs"] as? NSArray {
                var storedLogs = ExtensionDelegate.getLocationValues()
                for timestamp in locationLogs {
                    let count = storedLogs.count - 1
                    for i in 0...count {
                        if storedLogs[count - i].timestamp.timeIntervalSince1970.description == ("\(timestamp)") {
                            storedLogs.remove(at: count - i)
                        }
                        
                    }
                }
                ExtensionDelegate.replaceLocationValues(with: storedLogs)
            }
            
            if let heartRateLogs = dict["heartRateLogs"] as? NSArray {
                let storedLogs = ExtensionDelegate.getHeartRateValues()
                for timestamp in heartRateLogs {
                    storedLogs.removeObject(forKey: "\(timestamp)")
                }
                ExtensionDelegate.replaceHeartRateValues(with: storedLogs)
            }
            
            if let stepCountLogs = dict["stepCountLogs"] as? NSArray {
                let storedLogs = ExtensionDelegate.getStepCountValues()
                for timestamp in stepCountLogs {
                    storedLogs.removeObject(forKey: "\(timestamp)")
                }
                ExtensionDelegate.replaceStepCountValues(with: storedLogs)
            }
    }*/
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        //print(fileTransfer.file.fileURL.lastPathComponent)
        //print(ExtensionDelegate.transferringFile)
        if fileTransfer.file.fileURL.lastPathComponent == "dataToTransfer" && ExtensionDelegate.transferringFile == true {
            WKInterfaceDevice.current().play(.success)
            exit(0)
        }
    }
 }
 
