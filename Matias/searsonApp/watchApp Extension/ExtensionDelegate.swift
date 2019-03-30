//
//  ExtensionDelegate.swift
//  watchApp Extension
//
//  Created by Matias Eisler on 9/30/16.
//  Copyright © 2016 Matias Eisler. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    
    static var session: WCSession?
    var active = false
    
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
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        active = true
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
        active = false
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        //process message and reply
        //let timestamp = message["timestamp"]!
        //let pain = message["pain"]!
        print("serverMessage: \(message["serverMessage"] as! String)")
        print("message:")
        print(message)
        //print (applicationState)
        print("reached this point")
        print("active: \(active)")
        //replyHandler(["message": "Please take care of yourself"])
    }
    
    func didReceive(_ notification: UILocalNotification) {
        print("received Notification")
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("reachable: \(session.isReachable)")
    }
    
    static func setValueForKey(value: Int, key: String) {
        let prefs = UserDefaults.standard
        let dict = getValueForKey(key: "pain")
        dict.setValue(value, forKey: key)
        prefs.setValue(dict, forKey: "pain")
        print("just saved pain value \(value) for timestamp \(key)")
    }
    
    static func getValueForKey(key: String) -> NSMutableDictionary {
        let prefs = UserDefaults.standard
        if let value = prefs.value(forKey: "pain") {
            return NSMutableDictionary(dictionary: value as! NSDictionary)
        } else {
            return NSMutableDictionary()
        }
    }
    
    static func getDictionary() -> NSMutableDictionary {
        let prefs = UserDefaults.standard
        if let value = prefs.value(forKey: "pain") {
            return NSMutableDictionary(dictionary: value as! NSDictionary)
        } else {
            return NSMutableDictionary()
        }
    }
}
