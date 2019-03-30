//
//  DetailInterfaceController.swift
//  Watch App 4
//
//  Created by Dante Navarro on 10/20/16.
//  Copyright © 2016 Johns Hopkins University. All rights reserved.
//

import WatchKit
import Foundation


class DetailInterfaceController: WKInterfaceController {
    
    @IBOutlet var box: WKInterfaceImage!
    @IBOutlet var painLevelNumber: WKInterfaceLabel!
    @IBOutlet var painImage: WKInterfaceImage!
    
    var pain = 1
   
    let boxes = ["1":"Green Box",
                    "2":"Green Box 1",
                    "3":"Green Box 2",
                    "4":"Green Box 3",
                    "5":"Yellow Box",
                    "6":"Yellow Box 1",
                    "7":"Orange Box",
                    "8":"Orange Box 1",
                    "9":"Red Box",
                    "10":"Red Box 1"]
    
    let images = ["1":"(1-2)",
                 "2":"(1-2)",
                 "3":"(3-4)",
                 "4":"(3-4)",
                 "5":"(5-6)",
                 "6":"(5-6)",
                 "7":"(7-8)",
                 "8":"(7-8)",
                 "9":"(9-10)",
                 "10":"(9-10)"]
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let name = "\(context as! Int)"
        painLevelNumber.setText(name)
        painImage.setImage(UIImage(named:images[name]!))
        box.setImage(UIImage(named: boxes[name]!))
        // Configure interface objects here.
        
        pain = context as! Int
        
        let dict = getValueForKey(key: "pain")
        var s = ""
        if dict.allKeys.count > 0 {
            for key in dict.allKeys {
                print("stored pain: \(dict[key]!) for key \(key)")
                s.append("key: \(key), pain: \(dict[key]!)\n")
            }
        } else {
            s = "noData"
        }
        //largePainLabel.setText(s)
    }


    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func button() {
        let timestamp = Date().timeIntervalSince1970
        setValueForKey(value: pain, key: String(timestamp))
        print(timestamp)
    
    }
    
    
        func setValueForKey(value: Int, key: String) {
            let prefs = UserDefaults.standard
            let dict = getValueForKey(key: "pain")
            dict.setValue(value, forKey: key)
            prefs.setValue(dict, forKey: "pain")
            print("just saved pain value \(value) for timestamp \(key)")
        }
        
        func getValueForKey(key: String) -> NSMutableDictionary {
            let prefs = UserDefaults.standard
            if let value = prefs.value(forKey: "pain") {
                return NSMutableDictionary(dictionary: value as! NSDictionary)
            } else {
                return NSMutableDictionary()
            }
        }
        
        func removeItemForKey(key: String) {
            let prefs = UserDefaults.standard
            prefs.removeObject(forKey: key)
        }
        
}



