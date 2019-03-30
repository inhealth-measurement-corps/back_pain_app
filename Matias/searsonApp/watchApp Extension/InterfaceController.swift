//
//  InterfaceController.swift
//  watchApp Extension
//
//  Created by Matias Eisler on 9/30/16.
//  Copyright © 2016 Matias Eisler. All rights reserved.
//

import WatchKit
import Foundation

@available(watchOSApplicationExtension 3.0, *)
class InterfaceController: WKInterfaceController, WKCrownDelegate {

    @IBOutlet var group: WKInterfaceGroup!
    @IBOutlet var leftSwipeRecognizer: WKSwipeGestureRecognizer!
    @IBOutlet var rightSwipeRecognizer: WKSwipeGestureRecognizer!
    
    @IBOutlet var labelGroup: WKInterfaceGroup!
    
    @IBOutlet var group1: WKInterfaceGroup!
    @IBOutlet var group2: WKInterfaceGroup!
    @IBOutlet var group3: WKInterfaceGroup!
    @IBOutlet var group4: WKInterfaceGroup!
    @IBOutlet var group5: WKInterfaceGroup!
    @IBOutlet var group6: WKInterfaceGroup!
    @IBOutlet var group7: WKInterfaceGroup!
    @IBOutlet var group8: WKInterfaceGroup!
    @IBOutlet var group9: WKInterfaceGroup!
    @IBOutlet var group10: WKInterfaceGroup!
    
    @IBOutlet var label: WKInterfaceLabel!
    @IBOutlet var largePainLabel: WKInterfaceLabel!
    
    var allGroups: [WKInterfaceGroup] = []
    var pain = 1
    var crownCounter = 0
    var isConfirming = false
    //var moving = false
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        crownSequencer.delegate = self
        crownSequencer.focus()
        self.setTitle("Pain Log")
        
        group.setBackgroundImage(UIImage(named: "Pain\(pain)White"))
        
        allGroups = [group1, group2, group3, group4, group5, group6, group7, group8, group9, group10]
        resetColors()
        resetView()
        
        self.addMenuItem(with: .maybe, title: "Send all to phone", action: #selector(InterfaceController.flushToPhone))
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func decrement() {
        if pain > 1 {
            pain -= 1
            group.setBackgroundImage(UIImage(named: "Pain\(pain)White"))
            //group.setBackgroundColor(UIColor(hue: 0.35 - 0.035 * CGFloat(pain), saturation: 1, brightness: 1, alpha: 0.9))
            //self.setTitle("Pain: \(pain)")
            label.setText("\(pain)")
            resetColors()
        }
    }
    
    @IBAction func increment() {
        if pain < 10 {
            pain += 1
            group.setBackgroundImage(UIImage(named: "Pain\(pain)White"))
            label.setText("\(pain)")
            resetColors()
        }
    }
    
    @IBAction func acceptSelected() {
        isConfirming = true
        self.clearAllMenuItems()
        let timestamp = Date().timeIntervalSince1970
        ExtensionDelegate.setValueForKey(value: pain, key: String(timestamp))
        print(timestamp)
        let messageData = ["timestamp": timestamp, "pain": pain] as [String : Any]
        self.group.setBackgroundImage(nil)
        self.group.setBackgroundColor(UIColor.black)
        crownSequencer.resignFocus()
        self.label.setText("")
        self.largePainLabel.setText("\(pain)")
        self.largePainLabel.setTextColor(UIColor(hue: 0.35 - 0.035 * CGFloat(pain), saturation: 1, brightness: 1, alpha: 0.9))
        if ExtensionDelegate.session!.isReachable {
        ExtensionDelegate.session?.sendMessage(messageData as [String : AnyObject], replyHandler: { replyMessage in
            let replyDict = replyMessage as NSDictionary
            if replyDict["status"] as? String == "received" {
                self.labelGroup.setBackgroundImage(UIImage(named: "tick_wide"))
                self.addMenuItem(with: .maybe, title: "New Log", action: #selector(InterfaceController.resetView))
                self.addMenuItem(with: .decline, title: "Cancel", action: #selector(InterfaceController.doNothing))
            } else {
                self.labelGroup.setBackgroundImage(UIImage(named: "red cross"))
                print("ERROR")
            }
            }, errorHandler: {error in
                //some code
                print(error.localizedDescription)
        })
        } else {
            self.labelGroup.setBackgroundImage(UIImage(named: "red cross"))
            print("ERROR COMMUNICATING WITH PHONE")
        }
    }
    
    
    func resetColors() {
        if pain > 0 {
            for i in 0...(pain - 1) {
                allGroups[i].setBackgroundColor(UIColor(hue: 0.35 - 0.035 * CGFloat(pain), saturation: 1, brightness: 1, alpha: 0.9))
            }
            label.setTextColor(UIColor(hue: 0.35 - 0.035 * CGFloat(pain), saturation: 1, brightness: 1, alpha: 0.9))
        }
        if pain < 10 {
            for i in pain...(allGroups.count - 1) {
                allGroups[i].setBackgroundColor(UIColor.black)
            }
        }
    }
    
    var moving = false
    
    @available(watchOSApplicationExtension 3.0, *)
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        if !isConfirming {
        if crownCounter == 5 {
            if crownSequencer!.rotationsPerSecond < 0 {
                decrement()
            } else if crownSequencer!.rotationsPerSecond > 0 {
                increment()
            }
            crownCounter = 0
        }
        crownCounter += 1
        }
    }
    
    @available(watchOSApplicationExtension 3.0, *)
    func crownDidBecomeIdle(_ crownSequencer: WKCrownSequencer?) {
        moving = false
    }

    
    @IBAction func swipe(_ sender: AnyObject) {
        if !isConfirming {
            let direction = (sender as! WKSwipeGestureRecognizer).direction
            if direction == .down {
                decrement()
            } else if direction == .up {
                increment()
            }
        }
    }
    
    func removeItemForKey(key: String) {
        let prefs = UserDefaults.standard
        prefs.removeObject(forKey: key)
    }
    
    func resetView() {
        isConfirming = false
        clearAllMenuItems()
        self.addMenuItem(with: .accept, title: "Accept", action: #selector(InterfaceController.acceptSelected))
        self.addMenuItem(with: .decline, title: "Cancel", action: #selector(InterfaceController.doNothing))
        labelGroup.setBackgroundImage(nil)
        largePainLabel.setText("")
        pain = 1
        resetColors()
        group.setBackgroundImage(UIImage(named: "Pain\(pain)White"))
        label.setText("\(pain)")
    }
    
    func doNothing(){}
    
    func flushToPhone() {
        isConfirming = true
        self.clearAllMenuItems()
        let timestamp = Date().timeIntervalSince1970
        ExtensionDelegate.setValueForKey(value: pain, key: String(timestamp))
        print(timestamp)
        let messageData = NSDictionary(dictionary: ExtensionDelegate.getDictionary()) as! [String: Any]
        self.group.setBackgroundImage(nil)
        self.group.setBackgroundColor(UIColor.black)
        crownSequencer.resignFocus()
        self.label.setText("")
        self.largePainLabel.setText("\(pain)")
        self.largePainLabel.setTextColor(UIColor(hue: 0.35 - 0.035 * CGFloat(pain), saturation: 1, brightness: 1, alpha: 0.9))
        if ExtensionDelegate.session!.isReachable {
            ExtensionDelegate.session?.sendMessage(messageData as [String : AnyObject], replyHandler: { replyMessage in
                let replyDict = replyMessage as NSDictionary
                if replyDict["status"] as? String == "received" {
                    self.labelGroup.setBackgroundImage(UIImage(named: "tick_wide"))
                    self.addMenuItem(with: .maybe, title: "New Log", action: #selector(InterfaceController.resetView))
                    self.addMenuItem(with: .decline, title: "Cancel", action: #selector(InterfaceController.doNothing))
                } else {
                    self.labelGroup.setBackgroundImage(UIImage(named: "red cross"))
                    print("ERROR")
                }
            }, errorHandler: {error in
                //some code
                print(error.localizedDescription)
            })
        } else {
            self.labelGroup.setBackgroundImage(UIImage(named: "red cross"))
            print("ERROR COMMUNICATING WITH PHONE")
        }
    }
}
