//
//  TableInterfaceControlle.swift
//  searsonApp
//
//  Created by Matias Eisler on 11/9/16.
//  Copyright © 2016 Matias Eisler. All rights reserved.
//

import WatchKit

@available(watchOSApplicationExtension 3.0, *)
class TableInterfaceController: WKInterfaceController {
    
    @IBOutlet var table: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.pushController(withName: "MainInterface", context: nil)
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
    
    func loadTable() {
        var rowTypes = [String]()
        for i in 0...9 {
            rowTypes.append("painRow")
        }
        rowTypes.append("backRow")
        table.setRowTypes(rowTypes)
        for i in 0...9 {
            let row = table.rowController(at: i) as! PainRowController
            row.image.setImage(UIImage(named: "Pain\(i+1)White")!)
            row.label.setText(" Pain \(i+1)")
            row.group.setBackgroundColor(UIColor(hue: 0.35 - 0.035 * CGFloat(i+1), saturation: 0.8, brightness: 0.8, alpha: 0.9))
            //row.label.setTextColor(UIColor(hue: 0.35 - 0.035 * CGFloat(i+1), saturation: 1, brightness: 1, alpha: 0.9))
        }
        let row = table.rowController(at: 10) as! BackRowController
        row.group.setBackgroundColor(UIColor(hue: 0.35 - 0.035 * CGFloat(1), saturation: 0.8, brightness: 0.8, alpha: 0.9))
        
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        if rowIndex == 10 {
            self.pushController(withName: "MainInterface", context: nil)
        } else {
            if ExtensionDelegate.session!.isReachable {
                let timestamp = Date().timeIntervalSince1970
                ExtensionDelegate.setValueForKey(value: rowIndex + 1, key: String(timestamp))
                print(timestamp)
                let messageData = ["timestamp": timestamp, "pain": rowIndex + 1] as [String : Any]
                ExtensionDelegate.session?.sendMessage(messageData as [String : AnyObject], replyHandler: { replyMessage in
                    let replyDict = replyMessage as NSDictionary
                    if replyDict["status"] as? String == "received" {
                    } else {
                        print("ERROR")
                    }
                }, errorHandler: {error in
                    //some code
                    print(error.localizedDescription)
                })
            } else {
                print("ERROR COMMUNICATING WITH PHONE")
            }
            self.pushController(withName: "MainInterface", context: nil)
        }
    }
    
}
