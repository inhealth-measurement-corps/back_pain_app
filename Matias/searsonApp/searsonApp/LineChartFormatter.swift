//
//  LineChartFormatter.swift
//  searsonApp
//
//  Created by Matias Eisler on 11/9/16.
//  Copyright © 2016 Matias Eisler. All rights reserved.
//

import UIKit
import Charts

class LineChartFormatter: NSObject, IAxisValueFormatter {
    
    var labels = [String]()
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return labels[Int(value)]
    }
}
