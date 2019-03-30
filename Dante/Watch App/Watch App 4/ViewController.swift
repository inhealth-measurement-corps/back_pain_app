//
//  ViewController.swift
//  searsonApp
//
//  Created by Matias Eisler on 9/30/16.
//  Copyright © 2016 Matias Eisler. All rights reserved.
//

import UIKit
import Charts

class ViewController: UIViewController/*, UITableViewDelegate, UITableViewDataSource*/ {
    @IBOutlet weak var lineChartView: LineChartView!
    
    func setChart(timestamp:[Double], pain: [Int]) {
        lineChartView.noDataText = "No available data"
    }
    
    // @IBOutlet var tableView: UITableView!
    var logs: [AnyObject]!
    
    
    override func viewDidLoad() {
       super.viewDidLoad()
        
        logs = DatabaseManager.getFromDatabase(entityName: "Log", sortDescriptors: ["timestamp": true])
        
        var pains = [Int]()
        var timestamps = [Double]()
        for log in (logs as! [Log]) {
            pains.append(Int(log.pain))
            timestamps.append(log.timestamp)
        }
        
        setChart(timestamp: timestamps, pain: pains)
        
        
        
        var dataEntries = [ChartDataEntry]()
        for i in 0..<timestamps.count {
            let dataEntry = ChartDataEntry(x: timestamps[i], y: Double(pains[i]))
            dataEntries.append(dataEntry)
        }
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "Pain Level")
        //let chartDataSet = LineChartDataSet(values:  pains, label: "Pain Level")
        let chartData = LineChartData(dataSet: chartDataSet)
        lineChartView.data = chartData
        // Do any additional setup after loading the view, typically from a nib.
        
        /*tableView.delegate = self
        tableView.dataSource = self
        */
        
        
       // NotificationCenter.default.addObserver(self, selector: #selector(ViewController.reloadTable), name: NSNotification.Name(rawValue: "updateTable"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    }
    /*
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "logCell")!
        let log = logs[indexPath.row] as! Log
        (cell.viewWithTag(1) as! UILabel).text = "Pain: \(log.pain)"
        (cell.viewWithTag(2) as! UILabel).text = "Timestamp: \(log.timestamp)"
        return cell
    }
    
    }
    
   /* func reloadTable() {
        DispatchQueue.main.sync {
            logs = DatabaseManager.getFromDatabase(entityName: "Log")
            logs = DatabaseManager.getFromDatabase(entityName: "Log", sortDescriptors: ["timestamp": true])
            self.tableView.reloadData()
        }
    }
*/
    }}*/

