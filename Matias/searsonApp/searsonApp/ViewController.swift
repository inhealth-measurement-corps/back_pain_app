//
//  ViewController.swift
//  searsonApp
//
//  Created by Matias Eisler on 9/30/16.
//  Copyright © 2016 Matias Eisler. All rights reserved.
//

import UIKit
import Charts

//http://www.thedroidsonroids.com/blog/ios/beautiful-charts-swift/

class ViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet var barChart: BarChartView!
    
    var logs: [AnyObject]!
    
    @IBOutlet var hourButton: UIButton!
    @IBOutlet var dayButton: UIButton!
    @IBOutlet var weekButton: UIButton!
    @IBOutlet var monthButton: UIButton!
    
    let secondsInHour = 3600.0
    let secondsInDay = 86400.0
    let secondsInWeek = 604800.0
    let secondsInMonth = 2592000.0 //30 day month
    
    let barsPerHour = 60
    let barsPerDay = 24
    let barsPerWeek = 7
    let barsPerMonth = 30
    
    let secondsInHourBar = 60
    let secondsInDayBar = 3600
    let secondsInWeekBar = 86400
    let secondsInMonthBar = 86400
    
    let labelsInHour = 5
    let labelsInDay = 6
    let labelsInWeek = 7
    let labelsInMonth = 4
    
    //set to week values by default
    var currentMode = 0 //0=hour, 1=day, 2=week, 3=month
    var timeInterval = 3600.0
    var barCount = 60
    var secondsPerBar = 60
    var labels = 5
    
    @IBOutlet var entriesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        barChart.noDataText = "No data available."
        
        entriesLabel.layer.cornerRadius = 10
        entriesLabel.clipsToBounds = true
        
        updateChart()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.reloadTable), name: NSNotification.Name(rawValue: "updateTable"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //updates chart synchronously
    func reloadTable() {
        DispatchQueue.main.sync {
            //update graph
            updateChart()
        }
    }
    
    func updateChart() {
        
        let dateFormatter = DateFormatter()
        
        switch currentMode {
        case 0:
            secondsPerBar = secondsInHourBar
            barCount = barsPerHour
            timeInterval = secondsInHour
            labels = labelsInHour
            dateFormatter.dateFormat = "HH:mm"
            barChart.chartDescription!.text = "Time"
            break
        case 1:
            secondsPerBar = secondsInDayBar
            barCount = barsPerDay
            timeInterval = secondsInDay
            labels = labelsInDay
            dateFormatter.dateFormat = "HH:mm"
            barChart.chartDescription!.text = "Time"
            break
        case 2:
            secondsPerBar = secondsInWeekBar
            barCount = barsPerWeek
            timeInterval = secondsInWeek
            labels = labelsInWeek
            dateFormatter.dateFormat = "MM/dd"
            barChart.chartDescription!.text = "Day"
            break
        case 3:
            secondsPerBar = secondsInMonthBar
            barCount = barsPerMonth
            timeInterval = secondsInMonth
            labels = labelsInMonth
            dateFormatter.dateFormat = "MM/dd"
            barChart.chartDescription!.text = "Day"
            break
        default:
            break
        }
        
        
        let currentTime = NSDate().timeIntervalSince1970
        logs = DatabaseManager.getFromDatabase(entityName: "Log", predicateString: "timestamp > \(currentTime - timeInterval)", sortDescriptors: ["timestamp": false])
        
        /*for log in (logs as! [Log]) {
            print("ts:\(log.timestamp)         pain: \(log.pain)")
        }*/
        
        if logs.count > 0 {
            let formatter = LineChartFormatter()
            var allEntries = [BarChartDataEntry]()
            var colors = [UIColor]()
            //set dummy bars
            for i in 0...(barCount - 1) {
                allEntries.append(BarChartDataEntry(x: Double(i), y: 0.0))
                formatter.labels.append(dateFormatter.string(from: NSDate(timeIntervalSince1970: currentTime - Double(secondsPerBar * i)) as Date))
                colors.append(UIColor.white)
            }

            var lastIndex = 0
            var count = 0.0
            for i in 0...(logs.count - 1) {
                let log = logs[i] as! Log
                let index = Int(currentTime - log.timestamp) / secondsPerBar
                if (allEntries[index]).y == 0.0 || secondsPerBar > 60 { //only consider newest value, so ignore if bar already set
                    if currentMode != 0 {
                        if index != lastIndex {
                            lastIndex = index
                            count = 0
                        }
                        let yVal = (Double(log.pain) + (allEntries[index].y * count))/(count + 1)
                        allEntries[index].y = yVal
                        colors[index] = UIColor(hue: 0.35 - 0.035 * CGFloat(yVal), saturation: 0.8, brightness: 0.8, alpha: 0.9)
                        count += 1.0
                    } else {
                        allEntries[index].y = Double(log.pain)
                        colors[index] = UIColor(hue: 0.35 - 0.035 * CGFloat(Int(log.pain)), saturation: 0.8, brightness: 0.8, alpha: 0.9)
                    }
                }
                
            }
            
            let chartDataSet =  BarChartDataSet(values: allEntries, label: "Pain Levels")
            chartDataSet.drawValuesEnabled = false
            chartDataSet.colors = colors
            let chartData = BarChartData(dataSet: chartDataSet)
            barChart.xAxis.valueFormatter = formatter
            barChart.data = chartData
            
            barChart.xAxis.labelCount = labels
            barChart.leftAxis.axisMinimum = 0.0
            barChart.leftAxis.axisMaximum = 10.5
            barChart.legend.enabled = false
            
            
            
            barChart.scaleYEnabled = false
            barChart.scaleXEnabled = false
            barChart.pinchZoomEnabled = false
            barChart.doubleTapToZoomEnabled = false

            barChart.scaleYEnabled = false
            barChart.scaleXEnabled = false
            barChart.pinchZoomEnabled = false
            barChart.doubleTapToZoomEnabled = false
            
            barChart.highlighter = nil
            
            barChart.rightAxis.enabled = false
            barChart.xAxis.drawGridLinesEnabled = false
            barChart.leftAxis.drawGridLinesEnabled = false
            
            barChart.xAxis.labelPosition = .bottom
            
            barChart.animate(yAxisDuration: 1.0, easingOption: .easeInQuart)
        }
    }
    
    @IBAction func hourButtonClicked(_ sender: Any) {
        currentMode = 0
        updateChart()
        setButtonColor()
    }
    
    @IBAction func dayButtonClicked(_ sender: Any) {
        currentMode = 1
        updateChart()
        setButtonColor()
    }
    
    @IBAction func weekButtonClicked(_ sender: Any) {
        currentMode = 2
        updateChart()
        setButtonColor()
    }
    
    @IBAction func monthButtonClicked(_ sender: Any) {
        currentMode = 3
        updateChart()
        setButtonColor()
    }
    
    func setButtonColor() {
        hourButton.backgroundColor = UIColor(red: 90.0/255.0, green: 189.0/255.0, blue: 134.0/255.0, alpha: 1)
        dayButton.backgroundColor = UIColor(red: 90.0/255.0, green: 189.0/255.0, blue: 134.0/255.0, alpha: 1)
        weekButton.backgroundColor = UIColor(red: 90.0/255.0, green: 189.0/255.0, blue: 134.0/255.0, alpha: 1)
        monthButton.backgroundColor = UIColor(red: 90.0/255.0, green: 189.0/255.0, blue: 134.0/255.0, alpha: 1)
        
        
        switch currentMode {
        case 0:
            hourButton.backgroundColor = UIColor(red: 140.0/255.0, green: 243.0/255.0, blue: 172.0/255.0, alpha: 1)
            break
        case 1:
            dayButton.backgroundColor = UIColor(red: 140.0/255.0, green: 243.0/255.0, blue: 172.0/255.0, alpha: 1)
            break
        case 2:
            weekButton.backgroundColor = UIColor(red: 140.0/255.0, green: 243.0/255.0, blue: 172.0/255.0, alpha: 1)
            break
        case 3:
            monthButton.backgroundColor = UIColor(red: 140.0/255.0, green: 243.0/255.0, blue: 172.0/255.0, alpha: 1)
            break
        default:
            break
        }
    }
    
}

