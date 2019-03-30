//
//  AppDelegate.swift
//  searsonApp
//
//  Created by Matias Eisler on 9/30/16.
//  Copyright © 2016 Matias Eisler. All rights reserved.
//

import UIKit
import CoreData
import WatchConnectivity
import SystemConfiguration.CaptiveNetwork
import MessageUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate, MFMailComposeViewControllerDelegate {
    
    var logsArrays = [NSDictionary]()
    var locationLogsArrays = [NSDictionary]()
    var heartRateLogsArrays = [NSDictionary]()
    var stepCountLogsArrays = [NSDictionary]()
    var datas = [Any]()
    
    
    /** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
    @available(iOS 9.3, *)
    public func sessionDidDeactivate(_ session: WCSession) {
    }

    /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
    @available(iOS 9.3, *)
    public func sessionDidBecomeInactive(_ session: WCSession) {
    }

    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(iOS 9.3, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        /*if session.isPaired && session.isWatchAppInstalled && session.isReachable {
            
            let pLogs = DatabaseManager.getFromDatabase(entityName: "Log", predicateString: "serverConfirmed = true") as! [Log]
            let lLogs = DatabaseManager.getFromDatabase(entityName: "LocationLog", predicateString: "serverConfirmed = true") as! [LocationLog]
            let hLogs = DatabaseManager.getFromDatabase(entityName: "HeartRateLog", predicateString: "serverConfirmed = true") as! [HeartRateLog]
            let sLogs = DatabaseManager.getFromDatabase(entityName: "StepCountLog", predicateString: "serverConfirmed = true") as! [StepCountLog]
            
            let dict = NSMutableDictionary()
            var timestamps = [Double]()
            
            for log in pLogs {
                timestamps.append(log.timestamp)
            }
            dict.setValue(timestamps, forKey: "painLogs")
            timestamps = [Double]()
            
            for log in lLogs {
                timestamps.append(log.timestamp)
            }
            dict.setValue(timestamps, forKey: "locationLogs")
            timestamps = [Double]()
            
            for log in hLogs {
                timestamps.append(log.timestamp)
            }
            dict.setValue(timestamps, forKey: "heartRateLogs")
            timestamps = [Double]()
            
            for log in sLogs {
                timestamps.append(log.timestamp)
            }
            dict.setValue(timestamps, forKey: "stepCountLogs")
            
                session.sendMessage(["data": dict], replyHandler: {
                    replyMessage in
                    if let reply = replyMessage["status"] as? String {
                        if reply == "removed" {
                            let painLogs = dict["painLogs"] as! NSArray
                            for timestamp in painLogs {
                                let object = DatabaseManager.getItem(entityName: "Log", predicateString: "timestamp=\(timestamp)") as! Log
                                object.modelDeleted = true
                            }
                            
                            let locationLogs = dict["locationLogs"] as! NSArray
                            for timestamp in locationLogs {
                                let object = DatabaseManager.getItem(entityName: "LocationLog", predicateString: "timestamp=\(timestamp)") as! LocationLog
                                object.modelDeleted = true
                            }
                            
                            let heartRateLogs = dict["heartRateLogs"] as! NSArray
                            for timestamp in heartRateLogs {
                                let object = DatabaseManager.getItem(entityName: "HeartRateLog", predicateString: "timestamp=\(timestamp)") as! HeartRateLog
                                object.modelDeleted = true
                            }
                            
                            let stepCountLogs = dict["stepCountLogs"] as! NSArray
                            for timestamp in stepCountLogs {
                                let object = DatabaseManager.getItem(entityName: "StepCountLog", predicateString: "timestamp=\(timestamp)") as! StepCountLog
                                object.modelDeleted = true
                            }
                            
                            do {
                                try (UIApplication.shared.delegate as! AppDelegate).managedObjectContext.save()
                            } catch {
                                print("EXCEPTION")
                            }
                        }
                    }
                }, errorHandler: nil)
            }*/
    }
    
    

    var window: UIWindow?
    var session: WCSession?
    static var fromNotification = false
    var applicationIsOnBackground = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        session = WCSession.default()
        session?.delegate = self
        session?.activate()
        
        let statusBar = UIApplication.shared.value(forKey: "statusBar") as! UIView
        statusBar.backgroundColor = UIColor(red: 90.0/255.0, green: 189.0/255.0, blue: 134.0/255.0, alpha: 1)
                
        sendUserLogsToServer()
        
        AppDelegate.printAllData()
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if application.applicationState == UIApplicationState.inactive || application.applicationState == UIApplicationState.background {
            AppDelegate.fromNotification = true
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        applicationIsOnBackground = true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if applicationIsOnBackground {
            AppDelegate.fromNotification = true
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.mEisler.searsonApp" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "searsonApp", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
        print(message.count)
        
        let patientID = Int16(message["patient_id"] as! String)!
        
        for key in (message["pain_logs"] as! [String : Any]).keys {
            let logData = (message["pain_logs"] as! [String : Any])[key] as! NSDictionary
            if DatabaseManager.getItem(entityName: "Log", predicateString: "timestamp = \(key)") == nil {
            
                //log pain into database
                
                let pain = logData["pain"] as! Int
                let percentage = logData["percentage"] as! Float
                let object = DatabaseManager.insertObject(entityName: "Log") as! Log
                
                object.patientID = patientID
                object.pain = Int16(pain)
                object.timestamp = Double(key)!
                object.percentagePain = Float(percentage)
                object.serverConfirmed = false
                object.modelDeleted = false
            }
        }
        
        for dict in (message["location_logs"] as! [NSDictionary]) {
            let timestamp = Double(dict["timestamp"] as! String)!
            if DatabaseManager.getItem(entityName: "LocationLog", predicateString: "timestamp = \(timestamp)") == nil {
                let object = DatabaseManager.insertObject(entityName: "LocationLog") as! LocationLog
                
                object.patientID = patientID
                object.timestamp = timestamp
                object.latitude = Double("\(dict["latitude"]!)")!
                object.longitude = Double("\(dict["longitude"]!)")!
                object.modelDeleted = false
                object.serverConfirmed = false
            }
        }
        
        var dict = message["heart_rate_logs"] as! NSDictionary
        for tuple in dict {
            let timestamp = Double(tuple.key as! String)!
            if DatabaseManager.getItem(entityName: "HeartRateLog", predicateString: "timestamp = \(timestamp)") == nil {
                let object = DatabaseManager.insertObject(entityName: "HeartRateLog") as! HeartRateLog
                
                object.patientID = patientID
                object.timestamp = timestamp
                object.heartRate = Double(tuple.value as! NSNumber)/60
                object.modelDeleted = false
                object.serverConfirmed = false
            }
        }
        
        dict = message["step_count_logs"] as! NSDictionary
        for tuple in dict {
            let timestamp = Double(tuple.key as! String)!
            if DatabaseManager.getItem(entityName: "StepCountLog", predicateString: "timestamp = \(timestamp)") == nil {
                let object = DatabaseManager.insertObject(entityName: "StepCountLog") as! StepCountLog
                
                object.patientID = patientID
                object.timestamp = timestamp
                object.deltaStep = Int16(tuple.value as! NSNumber)
                object.modelDeleted = false
                object.serverConfirmed = false
            }
        }
        
        do {
            try (UIApplication.shared.delegate as! AppDelegate).managedObjectContext.save()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateTable"), object: self)
            replyHandler(["status": "received"])
        } catch {
            print("EXCEPTION")
            replyHandler(["status": "error"])
        }

        
        
        
        if session.isPaired && session.isWatchAppInstalled && session.isReachable {
            session.sendMessage(["serverMessage": "Please take care of yourself"], replyHandler: { replyMessage in
                
                }, errorHandler: {(error) in
                    print(error.localizedDescription)
            })
        } else {
            print("cell phone not reachable")
        }
        
        sendUserLogsToServer()
    }
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        DispatchQueue.main.sync {
        do {
            let contents = try NSDictionary(contentsOf: file.fileURL)
            let message = contents as! [String: Any]
            //let patientID = Int16(message["patient_id"] as! String)!

            for key in (message["pain_logs"] as! [String : Any]).keys {
                let logData = (message["pain_logs"] as! [String : Any])[key] as! NSDictionary
                if DatabaseManager.getItem(entityName: "Log", predicateString: "timestamp = \(key)") == nil {
                    
                    //log pain into database
                    
                    let pain = logData["pain"] as! Int
                    let percentage = logData["percentage"] as! Float
                    let object = DatabaseManager.insertObject(entityName: "Log") as! Log
                    
                    //object.patientID = patientID
                    object.pain = Int16(pain)
                    object.timestamp = Double(key)!
                    object.percentagePain = Float(percentage)
                    object.serverConfirmed = false
                    object.modelDeleted = false
                }
            }
            
            for dict in (message["location_logs"] as! [NSDictionary]) {
                let timestamp = Double(dict["timestamp"] as! String)!
                if DatabaseManager.getItem(entityName: "LocationLog", predicateString: "timestamp = \(timestamp)") == nil {
                    let object = DatabaseManager.insertObject(entityName: "LocationLog") as! LocationLog
                    
                    //object.patientID = patientID
                    object.timestamp = timestamp
                    object.latitude = Double("\(dict["latitude"]!)")!
                    object.longitude = Double("\(dict["longitude"]!)")!
                    object.modelDeleted = false
                    object.serverConfirmed = false
                }
            }
            
            var dict = message["heart_rate_logs"] as! NSDictionary
            for tuple in dict {
                let timestamp = Double(tuple.key as! String)!
                if DatabaseManager.getItem(entityName: "HeartRateLog", predicateString: "timestamp = \(timestamp)") == nil {
                    let object = DatabaseManager.insertObject(entityName: "HeartRateLog") as! HeartRateLog
                    
                    //object.patientID = patientID
                    object.timestamp = timestamp
                    object.heartRate = Double(tuple.value as! NSNumber)
                    object.modelDeleted = false
                    object.serverConfirmed = false
                }
            }
            
            dict = message["step_count_logs"] as! NSDictionary
            for tuple in dict {
                let timestamp = Double(tuple.key as! String)!
                if DatabaseManager.getItem(entityName: "StepCountLog", predicateString: "timestamp = \(timestamp)") == nil {
                    let object = DatabaseManager.insertObject(entityName: "StepCountLog") as! StepCountLog
                    
                    //object.patientID = patientID
                    object.timestamp = timestamp
                    object.deltaStep = Int16(tuple.value as! NSNumber)
                    object.modelDeleted = false
                    object.serverConfirmed = false
                }
            }
            
            
            
            sendUserLogsToServer()
            print("done")
        } catch {
            print("error")
        }
        }
        do {
            try (UIApplication.shared.delegate as! AppDelegate).managedObjectContext.save()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateTable"), object: self)
        } catch {
            print("EXCEPTION")
        }
    }
    
    func sendUserLogsToServer() {
        
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        
        guard let network = ssid else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showHopkinsNetworkAlert"), object: self)
            return
        }
        
        guard network == "hopkins" else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showHopkinsNetworkAlert"), object: self)
            return
        }
        
        print(network)
        
        
        let logs = DatabaseManager.getFromDatabase(entityName: "Log", predicateString: "serverConfirmed=false") as! [Log]
        let locationLogs = DatabaseManager.getFromDatabase(entityName: "LocationLog", predicateString: "serverConfirmed=false") as! [LocationLog]
        let heartRateLogs = DatabaseManager.getFromDatabase(entityName: "HeartRateLog", predicateString: "serverConfirmed=false") as! [HeartRateLog]
        let stepCountLogs = DatabaseManager.getFromDatabase(entityName: "StepCountLog", predicateString: "serverConfirmed=false") as! [StepCountLog]
        
        var logsArray = [NSDictionary]()
        var locationLogsArray = [NSDictionary]()
        var heartRateLogsArray = [NSDictionary]()
        var stepCountLogsArray = [NSDictionary]()
        
        if logs.count > 0 {
            for log in logs {
                logsArray.append(["timestamp": log.timestamp, "pain": log.pain, "percentage": log.percentagePain, "patient_id": log.patientID])
                logsArrays.append(["timestamp": log.timestamp, "pain": log.pain, "percentage": log.percentagePain, "patient_id": log.patientID])
            }
        }
        
        if locationLogs.count > 0 {
            for locationLog in locationLogs {
                locationLogsArray.append(["timestamp": locationLog.timestamp, "latitude": locationLog.latitude, "longitude": locationLog.longitude, "patient_id": locationLog.patientID])
                locationLogsArrays.append(["timestamp": locationLog.timestamp, "latitude": locationLog.latitude, "longitude": locationLog.longitude, "patient_id": locationLog.patientID])
            }
        }
        
        if heartRateLogs.count > 0 {
            for heartRateLog in heartRateLogs {
                heartRateLogsArray.append(["timestamp": heartRateLog.timestamp, "heartRate": heartRateLog.heartRate, "patient_id": heartRateLog.patientID])
                heartRateLogsArrays.append(["timestamp": heartRateLog.timestamp, "heartRate": heartRateLog.heartRate, "patient_id": heartRateLog.patientID])
            }
        }
        
        if stepCountLogs.count > 0 {
            for stepCountLog in stepCountLogs {
                stepCountLogsArray.append(["timestamp": stepCountLog.timestamp, "stepCount": stepCountLog.deltaStep, "patient_id": stepCountLog.patientID])
                stepCountLogsArrays.append(["timestamp": stepCountLog.timestamp, "stepCount": stepCountLog.deltaStep, "patient_id": stepCountLog.patientID])
            }
        }
        
        var data = [Any]()
        data.append(logsArray)
        data.append(locationLogsArray)
        data.append(heartRateLogsArray)
        data.append(stepCountLogsArray)
        
        
        datas.append(logsArray)
        datas.append(locationLogsArray)
        datas.append(heartRateLogsArray)
        datas.append(stepCountLogsArray)
        
        //let data = [logsArray, locationLogsArray]
        let dict = ["data": data] as NSDictionary
        Requests.sharedInstance.sendRequest(NSDictionary(dictionary: dict), action: "patients/sendLogs")
    }

    static func printAllData() -> (String?) {
        let painLogs = DatabaseManager.getAllFromDatabase(entityName: "Log") as! [Log]
        let locationLogs = DatabaseManager.getAllFromDatabase(entityName: "LocationLog") as! [LocationLog]
        let heartRateLogs = DatabaseManager.getAllFromDatabase(entityName: "HeartRateLog") as! [HeartRateLog]
        let stepCountLogs = DatabaseManager.getAllFromDatabase(entityName: "StepCountLog") as! [StepCountLog]
        
        var dict = "{"
        
        dict.append("\"painLogs\":[")
        for painLog in painLogs {
            var painLogDict = "{\"timestamp\":"
            painLogDict.append("\(painLog.timestamp)")
            
            painLogDict.append(", \"patientID\":")
            painLogDict.append("\(mainInstance.patientID)")
            
            painLogDict.append(", \"pain\":")
            painLogDict.append("\(painLog.pain)")
            
            painLogDict.append(", \"percentage\":")
            painLogDict.append("\(painLog.percentagePain)},")
            dict.append(painLogDict)
        }
        dict.characters.removeLast()
        dict.append("],")
    /*
        dict.append("'locationLogs':[")
        for locationLog in locationLogs {
            var locationLogDict = "{'timestamp':"
            locationLogDict.append("\(locationLog.timestamp)")
            
            locationLogDict.append(", 'latitude':")
            locationLogDict.append("\(locationLog.latitude)")
            
            locationLogDict.append(", 'longitude':")
            locationLogDict.append("\(locationLog.longitude)")
            
            locationLogDict.append(", 'patientID':")
            locationLogDict.append("\(locationLog.patientID)},")
            dict.append(locationLogDict)
            
        }
        dict.characters.removeLast()
        dict.append("],")
        */
        dict.append("\"heartRateLogs\":[")
        for heartRateLog in heartRateLogs {
            var heartRateLogDict = "{\"timestamp\":"
            heartRateLogDict.append("\(heartRateLog.timestamp)")
            
            heartRateLogDict.append(", \"heartRate\":")
            heartRateLogDict.append("\(heartRateLog.heartRate)")
            
            
            heartRateLogDict.append(", \"patientID\":")
            heartRateLogDict.append("\(mainInstance.patientID)},")
            
            dict.append(heartRateLogDict)
            
        }
        dict.characters.removeLast()
        dict.append("],")
        
        dict.append("\"stepCountLogs\":[")
        for stepCountLog in stepCountLogs {
            var stepCountLogDict = "{\"timestamp\":"
            stepCountLogDict.append("\(stepCountLog.timestamp)")
            
            stepCountLogDict.append(", \"stepCount\":")
            stepCountLogDict.append("\(stepCountLog.deltaStep)")
            
            
            stepCountLogDict.append(", \"patientID\":")
            stepCountLogDict.append("\(mainInstance.patientID)},")
            
            dict.append(stepCountLogDict)
            
        }
        dict.characters.removeLast()
        dict.append("]}")
        return (dict)
    }
    
    static func printPainTimestamps() -> ([Array<Any>]) {
        let painLogs = DatabaseManager.getAllFromDatabase(entityName: "Log") as! [Log]
        
        var dict = [Double()]
        
        for painLog in painLogs {
            //dict.append(painLog[0])
            dict.append(painLog.timestamp)
        }
        
        let sorted = dict.sorted()
        let startEnd = [sorted[1], sorted[sorted.count - 1]]
        
        return ([startEnd])
    }
    
    static func printPainData() -> ([Array<Any>]) {
        let painLogs = DatabaseManager.getAllFromDatabase(entityName: "Log") as! [Log]
        
        var dict = [[Any]()]
        
        for painLog in painLogs {
            var painLogDict = [Any]()
            painLogDict.append(painLog.timestamp)
            painLogDict.append(painLog.pain)
            painLogDict.append(painLog.percentagePain)
            painLogDict.append(mainInstance.patientID)
            dict.append(painLogDict)
        }
        return (dict)
    }
    
    static func printStepData() -> ([Array<Any>]) {
        let stepCountLogs = DatabaseManager.getAllFromDatabase(entityName: "StepCountLog") as! [StepCountLog]
        
        var dict = [[Any]()]
        
        for stepCountLog in stepCountLogs {
            
            var stepCountLogDict = [Any]()
            stepCountLogDict.append(stepCountLog.timestamp)
            stepCountLogDict.append(stepCountLog.deltaStep)
            stepCountLogDict.append(mainInstance.patientID)
            dict.append(stepCountLogDict)
            
        }
        return (dict)
    }
    
    static func printHRData() -> ([Array<Any>]) {
        let heartRateLogs = DatabaseManager.getAllFromDatabase(entityName: "HeartRateLog") as! [HeartRateLog]
        
        var dict = [[Any]()]
        
        let id:Int = Int(mainInstance.patientID) ?? 0
        for heartRateLog in heartRateLogs {
            
            var heartRateLogDict = [Any]()
            heartRateLogDict.append(heartRateLog.timestamp)
            heartRateLogDict.append(heartRateLog.heartRate)
            heartRateLogDict.append(id)
            dict.append(heartRateLogDict)
            
        }
        
        return (dict)
    }
    
}

