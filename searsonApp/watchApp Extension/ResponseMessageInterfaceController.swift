//
//  ResponseMessageInterfaceController.swift
//  searsonApp
//
//  Created by Matias Eisler on 9/30/16.
//  Copyright © 2016 Matias Eisler. All rights reserved.
//

import WatchKit

class ResponseMessageInterfaceController: WKInterfaceController {
    
    @IBOutlet var label: WKInterfaceLabel!
    
    var pain = -1
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        //pain = context!["pain"] as! Int
        self.setTitle("Pain: \(pain)")
        
        //label.setText((context!["message"] as! NSDictionary)["message"] as! String)
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func willDisappear() {
        super.willDisappear()
    }
    
}
