//
//  InterfaceController.swift
//  Watch App 4 WatchKit Extension
//
//  Created by Dante Navarro on 10/20/16.
//  Copyright © 2016 Johns Hopkins University. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    var pain = [1, 2, 3, 4, 5 ,6, 7, 8, 9, 10]
    
    var imageNames = ["(1-2)","(1-2)","(3-4)","(3-4)","(5-6)","(5-6)","(7-8)","(7-8)","(9-10)","(9-10)"]
   
    var level = ["Pain Level","Pain Level","Pain Level","Pain Level","Pain Level","Pain Level","Pain Level","Pain Level","Pain Level","Pain Level"]
    
    @IBOutlet var tableView: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        setupTable()
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    func setupTable() {
        tableView.setNumberOfRows(pain.count, withRowType: "PainRow")
    
        for i in 0 ..< pain.count {
            if let row = tableView.rowController(at: i) as? PainRow {

            row.painLevelNumber.setText("\(pain[i])")
            row.painImage.setImage(UIImage(named: imageNames[i]))
            row.painLevel.setText(level[i])
        }
        }
}
    override func table(_: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        self.pushController(withName: "showDetails", context: pain[rowIndex])
    }
}
