//
//  WatchSettingsController.swift
//  searsonApp
//
//  Created by Matias Eisler on 3/6/17.
//  Copyright © 2017 Matias Eisler. All rights reserved.
//

import UIKit
import WatchConnectivity
import EventKit
import MessageUI
import HealthKit




class WatchSettingsController: UIViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate {
    
    var reminder = "1"
    
    var session: WCSession!
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        //handle received message
        let value = message["Value"] as? String
        //use this to present immediately on the screen
        DispatchQueue.main.async() {
            self.reminder = value!
        }
        //send a reply
        replyHandler(["Value":"Yes" as AnyObject])
    }
    
    @IBAction func clearDataButton(_ sender: UIButton) {
        
        var savedLogs = DatabaseManager.getAllFromDatabase(entityName: "Log")
        var savedLocationLogs = DatabaseManager.getAllFromDatabase(entityName: "LocationLog")
        var savedHeartRateLogs = DatabaseManager.getAllFromDatabase(entityName: "HeartRateLog")
        var savedStepCountLogs = DatabaseManager.getAllFromDatabase(entityName: "StepCountLog")
        let heartRateSampleType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
        
        let currentDate = Date()
        let predicate = HKQuery.predicateForSamples(withStart: currentDate.addingTimeInterval(-800000), end: currentDate, options: [.strictStartDate, .strictEndDate])
        
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
            }
        }
        
        //print(savedLogs)
        //print(savedLocationLogs)
        //print(savedHeartRateLogs)
        //print(savedStepCountLogs)
        let alert = UIAlertController(title: "Clear Data", message: "Are you sure you want to clear the data?", preferredStyle: .alert)
        let clearAction = UIAlertAction(title: "Clear", style: .destructive) { (alert: UIAlertAction!) -> Void in
            
            DatabaseManager().deleteAllData(entity: "Log")
            DatabaseManager().deleteAllData(entity: "LocationLog")
            DatabaseManager().deleteAllData(entity: "HeartRateLog")
            DatabaseManager().deleteAllData(entity: "StepCountLog")
            UserDefaults.standard.removeObject(forKey: "pain")
            UserDefaults.standard.removeObject(forKey: "locations")
            UserDefaults.standard.removeObject(forKey: "heartRates")
            UserDefaults.standard.removeObject(forKey: "stepCounts")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (alert: UIAlertAction!) -> Void in
            //print("You pressed Cancel")
        }
        
        alert.addAction(clearAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion:nil)
        
        print(savedLogs)
        print(savedLocationLogs)
        print(savedHeartRateLogs)
        print(savedStepCountLogs)
        //let alert = UIAlertController(title: "Finished", message: "The data has been cleared.", preferredStyle: .actionSheet)
        //alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: nil))
        //self.present(alert, animated: true, completion: nil)

    }
    
    @IBOutlet weak var datePickerOutlet: UIDatePicker!
    
    @IBAction func datePicker(_ sender: Any) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        let strDate = dateFormatter.string(from: datePickerOutlet.date)
        //dateLabel.text = strDate
    }
    
    func painLogServer() {
        let pain = AppDelegate.printPainData()
        
        var timestamps = [Double]()
        if pain.count > 1 {
            for i in 1...(pain.count-1) {
                let new = pain[i]
                let timestamp = new[0]
                timestamps.append(timestamp as! Double)
                let pain = new[1]
                let percentage = new[2]
                let patient_id = new[3]
                
                
                //let b = AppDelegate().logsArrays
                //var somedata = b?.data(using: String.Encoding.utf8)
                //let parameter = ["data": test]
                let parameters = ["timestamp": timestamp, "pain": pain, "percentage": percentage, "patient_id": patient_id] as [String : Any]
                
                //create the url with URL
                let url = URL(string: "http://10.162.80.9:90/painmanagement/insert_to_database2.php")! //change the url
                
                //create the session object
                let session = URLSession.shared
                
                //now create the URLRequest object using the url object
                var request = URLRequest(url: url)
                request.httpMethod = "POST" //set http method as POST
                //request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
                
                
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
                    
                } catch let error {
                    print(error.localizedDescription)
                }
                
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                
                //create dataTask using the session object to send data to the server
                let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                    
                    guard error == nil else {
                        return
                    }
                    
                    guard let data = data else {
                        return
                    }
                    
                    do {
                        //create json object from data
                        if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                            print(json)
                            // handle json...
                        }
                        
                    } catch let error {
                        print(error.localizedDescription)
                    }
                })
                task.resume()
            }} else {
            
        }
        
    }
    
    func stepCountServer() {
        let steps = AppDelegate.printStepData()
        
        if steps.count > 1 {
            for i in 1...(steps.count-1) {
                let new = steps[i]
                let timestamp = new[0]
                let time = timestamp as! Double
                let startPain = AppDelegate.printPainTimestamps()[0][0] as! Double
                let endPain = AppDelegate.printPainTimestamps()[0][1] as! Double
               
                
                if (startPain...endPain).contains(time) {
                    let steps = new[1]
                    let patient_id = new[2]
                
                
                    //let b = AppDelegate().logsArrays
                    //var somedata = b?.data(using: String.Encoding.utf8)
                    //let parameter = ["data": test]
                    let parameters = ["timestamp": timestamp, "steps": steps, "patient_id": patient_id] as [String : Any]
                
                    //create the url with URL
                    let url = URL(string: "http://10.162.80.9:90/painmanagement/insert_to_database3.php")! //change the url
                
                    //create the session object
                    let session = URLSession.shared
                
                    //now create the URLRequest object using the url object
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST" //set http method as POST
                    //request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
                
                
                    do {
                        request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
                        
                    } catch let error {
                        print(error.localizedDescription)
                    }
                
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.addValue("application/json", forHTTPHeaderField: "Accept")
                
                    //create dataTask using the session object to send data to the server
                    let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                        
                        guard error == nil else {
                            return
                        }
                        
                        guard let data = data else {
                            return
                        }
                        
                        do {
                            //create json object from data
                            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                                print(json)
                                // handle json...
                            }
                            
                        } catch let error {
                            print(error.localizedDescription)
                        }
                    })
                    task.resume()
                    }
                
            }} else{
            
        }
            
        }
        
        func heartRateServer() {
            let hr = AppDelegate.printHRData()
        
            if hr.count > 1 {
                for i in 1...(hr.count-1) {
                    let new = hr[i]
                    let timestamp = new[0]
                    let time = timestamp as! Double
                    let startPain = AppDelegate.printPainTimestamps()[0][0] as! Double
                    let endPain = AppDelegate.printPainTimestamps()[0][1] as! Double
                    
                    //print(AppDelegate.printPainData())
                    
                    if (startPain...endPain).contains(time) {
                        
                    let heart_rate = new[1]
                    let patient_id = new[2]
                    
                    //let b = AppDelegate().logsArrays
                    //var somedata = b?.data(using: String.Encoding.utf8)
                    //let parameter = ["data": test]
                    let parameters = ["timestamp": timestamp, "heart_rate": heart_rate, "patient_id": patient_id] as [String : Any]
                    
                    //create the url with URL
                    let url = URL(string: "http://10.162.80.9:90/painmanagement/insert_to_database.php")! //change the url
                    
                    //create the session object
                    let session = URLSession.shared
                    
                    //now create the URLRequest object using the url object
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST" //set http method as POST
                    //request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
                    
                    
                    do {
                        request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
                        
                    } catch let error {
                        print(error.localizedDescription)
                    }
                    
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.addValue("application/json", forHTTPHeaderField: "Accept")
                    
                    //create dataTask using the session object to send data to the server
                    let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                        
                        guard error == nil else {
                            return
                        }
                        
                        guard let data = data else {
                            return
                        }
                        
                        do {
                            //create json object from data
                            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                                print(json)
                                // handle json...
                            }
                            
                        } catch let error {
                            print(error.localizedDescription)
                        }
                    })
                    
                    task.resume()
                    }
                }} else {
                
            }
        
    }
    
    @IBAction func sendEmail(_ sender: UIButton) {
       
        
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
        
        stepCountServer()
        
        heartRateServer()
        
    
        
        
    }
 
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()

        
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        mailComposerVC.setToRecipients(["rajapainmanagement@gmail.com"])
        mailComposerVC.setSubject("Patient \(sentID)")
        
        
        let a = AppDelegate.printAllData()
        //let b = AppDelegate().logsArrays
        var somedata = a?.data(using: String.Encoding.utf8)
        //mailComposerVC.setMessageBody(a! , isHTML: false)
        mailComposerVC.addAttachmentData(somedata!, mimeType: "csv", fileName: "logs")
        
        return mailComposerVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    

    
    let eventStore = EKEventStore()
    let date = Date()
    let cal = Calendar(identifier: .gregorian)
    
    let components1 = NSDateComponents()
    let components2 = NSDateComponents()
    let components3 = NSDateComponents()
    let components4 = NSDateComponents()
    let components5 = NSDateComponents()

    var wcSession: WCSession!
    var sentID = -1
    
    @IBOutlet var idTextField: UITextField!
    
    var tapGesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        wcSession = WCSession.default()
        session = WCSession.default()
        //session.delegate = self
        //wcSession.delegate = self
        //session.activate()
        wcSession.activate()
        idTextField.delegate = self
      
        if (WCSession.isSupported()) {
            session = WCSession.default()
            //session.delegate = self
            session.activate()
        }
        
    }
    
    @IBAction func setIDButtonClicked(_ sender: Any) {
        
        
        
        mainInstance.patientID = idTextField.text!
        //print(mainInstance.patientID
        
        if let text = idTextField.text {
            if let id = Int(text) {
                sentID = id
                //GlobalVariables.sharedInstance().newPatientID = sentID
                let dict = ["id": id]
                /*
                NotificationCenter.default.addObserver(self, selector: #selector(WatchSettingsController.createPatientFinished), name: NSNotification.Name("createPatientFinished"), object: nil)
 */
                //Requests.sharedInstance.sendRequest(dict as NSDictionary, action: "patients/createPatient")
            }
        }
    
        painLogServer()
        //stepCountServer()
    }
    
    
    
    
    
    
    func addEventToCalendar(title: String, description: String?, startDate: NSDate, endDate: NSDate, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        
        let eventStore = EKEventStore()
        
        
        ///eventStore.requestAccess(to: .event, completion: { (granted, error) in
         ///   if (granted) && (error == nil) {
        if (EKEventStore.authorizationStatus(for: .event) !=
            EKAuthorizationStatus.authorized) {
            eventStore.requestAccess(to: .event, completion: {
                granted, error in
            })
        } else {
            
                let event = EKEvent(eventStore: eventStore)
                event.title = title
                event.startDate = startDate as Date
                event.endDate = endDate as Date
                event.notes = description
                event.calendar = eventStore.defaultCalendarForNewEvents
                let alarm:EKAlarm = EKAlarm(relativeOffset: 0)
                event.alarms = [alarm]
                
                
                do {
                    (try eventStore.save(event, span: .thisEvent, commit: true))
                }  catch _ {print("FAIL")}
        }
    }
//                do {
//                    try eventStore.save(event, span: .thisEvent)
//                } catch let e as NSError {
//                    completion?(false, e)
//                    return
//                }
//                completion?(true, nil)
//            } else {
//                completion?(false, error as NSError?)
//            }
//        })
//    }

    
    @IBAction func createAlarm1(_ sender: UIButton) {
        
        let messageToSend = ["Value":"1"]
        session.sendMessage(messageToSend, replyHandler: { replyMessage in
            //handle and present the message on screen
            let reply = replyMessage["Value"] as? String
        }, errorHandler: {error in
            // catch any errors here
            print(error)
        })
        
        for index in 0...7 {
            
            let startOfDate = cal.startOfDay(for: datePickerOutlet.date)
            
            //First Alarm
            components1.hour = 8
            components1.day = index
            
            let firstAlarm = cal.date(byAdding: components1 as DateComponents, to: startOfDate)
           addEventToCalendar(title: "Remember to Log Pain", description: "Remember to Log Pain", startDate: firstAlarm! as NSDate , endDate: firstAlarm! as NSDate)
            
            //Second Alarm
            components2.hour = 14
            components2.day = index
            
            let secondAlarm = cal.date(byAdding: components2 as DateComponents, to: startOfDate)
            addEventToCalendar(title: "Remember to Log Pain", description: "Remember to Log Pain", startDate: secondAlarm! as NSDate , endDate: secondAlarm! as NSDate)

            //Third Alarm
            components3.hour = 20
            components3.day = index

            let thirdAlarm = cal.date(byAdding: components3 as DateComponents, to: startOfDate)
            addEventToCalendar(title: "Remember to Log Pain", description: "Remember to Log Pain", startDate: thirdAlarm! as NSDate , endDate: thirdAlarm! as NSDate)
        
        }
        let alert = UIAlertController(title: "Finished", message: "The alarms have been set.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func createAlarm2(_ sender: UIButton) {
        
        let messageToSend = ["Value":"2"]
        session.sendMessage(messageToSend, replyHandler: { replyMessage in
            //handle and present the message on screen
            let value = replyMessage["Value"] as? String
        }, errorHandler: {error in
            // catch any errors here
            print(error)
        })
        for x in 1...8 {
            
            let date = Date()
            
            components4.hour = x
            
            let fourthAlarm = cal.date(byAdding: components4 as DateComponents, to: date)
            
            addEventToCalendar(title: "Remember to Log Pain", description: "Remember to Log Pain", startDate: fourthAlarm! as NSDate , endDate: fourthAlarm! as NSDate)
            
        }

        for index in 0...7 {
            
            let date = Date()
            let startOfDate = cal.startOfDay(for: date)
            
            components5.hour = 8
            let fixAlarm = cal.date(byAdding: components4 as DateComponents, to: date)
            
            //First Alarm
            components1.hour = 8
            components1.day = index
            
            let firstAlarm = cal.date(byAdding: components1 as DateComponents, to: startOfDate)
            if fixAlarm! < firstAlarm! {
                addEventToCalendar(title: "Remember to Log Pain", description: "Remember to Log Pain", startDate: firstAlarm! as NSDate , endDate: firstAlarm! as NSDate)
            }
            
            //Second Alarm
            components2.hour = 14
            components2.day = index
            
            let secondAlarm = cal.date(byAdding: components2 as DateComponents, to: startOfDate)
            if fixAlarm! < secondAlarm! {
                addEventToCalendar(title: "Remember to Log Pain", description: "Remember to Log Pain", startDate: secondAlarm! as NSDate , endDate: secondAlarm! as NSDate)
            }
                
            //Third Alarm
            components3.hour = 20
            components3.day = index
            
            let thirdAlarm = cal.date(byAdding: components3 as DateComponents, to: startOfDate)
            if fixAlarm! < thirdAlarm! {
                addEventToCalendar(title: "Remember to Log Pain", description: "Remember to Log Pain", startDate: thirdAlarm! as NSDate , endDate: thirdAlarm! as NSDate)
            }
        }
        
        
        
        let alert = UIAlertController(title: "Finished", message: "The alarms have been set.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
    
    @IBAction func clearEvents(_ sender: UIButton) {
        let startEndDate=NSDate().addingTimeInterval(-60*60*24*365)
        let endEndDate=NSDate().addingTimeInterval(60*60*24*365)
        let predicate = eventStore.predicateForEvents(withStart: startEndDate as Date, end: endEndDate as Date, calendars: nil)

        var eV = eventStore.events(matching: predicate)
        
        if (EKEventStore.authorizationStatus(for: .event) !=
            EKAuthorizationStatus.authorized) {
            eventStore.requestAccess(to: .event, completion: {
                granted, error in
            })
        } else {
    
                for i in eV {
            
                    if i.title == "Remember to Log Pain" {
                        //for j in 0...(eV.count - 1) {
                    
                            do{
                            (try self.eventStore.remove(i, span: .thisEvent, commit: true))
                            }
                            catch let error {print(error)}
                        //}
                    }
                for i in eV {
                        
                    if i.title == "Remember to Log Pain" {
                            //for j in 0...(eV.count - 1) {
                            
                        do{
                            (try self.eventStore.remove(i, span: .thisEvent, commit: true))
                        }
                        catch let error {print(error)}
                            //}
                    }
            }
            
            let alert = UIAlertController(title: "Finished", message: "The alarms have been cleared.", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)

        }
        }
    
        

        
    }


    /*
    func createPatientFinished() {
        if GlobalVariables.sharedInstance().patientCreated {
            if (session?.isPaired)! && (session?.isReachable)! && (session?.isWatchAppInstalled)! {
                session?.sendMessage(["resetWithID": sentID], replyHandler: {replyMessage in
                if (replyMessage["status"] as! String) == "ok" {
                    DispatchQueue.main.sync {
                        GlobalVariables.sharedInstance().patientCreated = false
                        GlobalVariables.sharedInstance().newPatientID = -1
                        let alert = UIAlertController(title: "Success", message: "Successfully set the watch's new ID", preferredStyle: .actionSheet)
                        alert.addAction(UIAlertAction(title: "Okay", style: .default){action in self.navigationController?.popViewController(animated: true)})
                        self.present(alert, animated: true)
                        //self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    let alert = UIAlertController(title: "Failed", message: "The watch failed to set the ID", preferredStyle: .actionSheet)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default))
                    self.present(alert, animated: true)
                }
            }, errorHandler: nil)
        }
        } else {
            let alert = UIAlertController(title: "Failed", message: "ID is not available", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Okay", style: .default))
            self.present(alert, animated: true)
        }
    }
    */
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(WatchSettingsController.hideKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func hideKeyboard() {
        self.idTextField.resignFirstResponder()
        self.tapGesture = nil
    }
    
}
