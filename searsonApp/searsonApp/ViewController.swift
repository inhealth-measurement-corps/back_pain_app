//
//  ViewController.swift
//  searsonApp
//
//  Created by Matias Eisler on 9/30/16.
//  Copyright © 2016 Matias Eisler. All rights reserved.
//

import HealthKit
import UIKit
import Charts
import CoreLocation

//http://www.thedroidsonroids.com/blog/ios/beautiful-charts-swift/

class ViewController: UIViewController, ChartViewDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate{
    
  
    
    @IBOutlet var barChart: BarChartView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var topButtonsView: UIView!
    @IBOutlet var hourButton: UIButton!
    @IBOutlet var dayButton: UIButton!
    @IBOutlet var weekButton: UIButton!
    @IBOutlet var monthButton: UIButton!
    @IBOutlet var yAxisLabel: UILabel!
    
    var logs: [AnyObject]!
    
    let healthStore = HKHealthStore()
   
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
    //let labelsInDay = 6
    let labelsInDay = 12
    let labelsInWeek = 7
    //let labelsInMonth = 4
    let labelsInMonth = 15
    
    //set to week values by default
    var currentMode = 0 //0=hour, 1=day, 2=week, 3=month
    var timeInterval = 3600.0
    var barCount = 60
    var secondsPerBar = 60
    var labels = 5
    
    var dateFormatter: DateFormatter!
    var timeFormatter: DateFormatter!
    
    func dataTypesToWrite() -> Set<HKSampleType> {
        
        let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        let stepCountType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
        
        let writeDataTypes: Set<HKSampleType> = [heartRateType, stepCountType]
        
        return writeDataTypes
    }
    
    func dataTypesToRead() -> Set<HKObjectType> {
        
        let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        let stepCountType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
        
        let readDataTypes: Set<HKObjectType> = [heartRateType, stepCountType]
        return readDataTypes
    }
    
   @IBOutlet var entriesLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //self.updateChart()
        
        
        
        
        barChart.noDataText = "No data available."
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 5
        tableView.clipsToBounds = true
        
        entriesLabel.layer.cornerRadius = 10
        entriesLabel.clipsToBounds = true
        
        topButtonsView.backgroundColor = UIColor(red: 90.0/255.0, green: 189.0/255.0, blue: 134.0/255.0, alpha: 1)
        
        
        
        /*roundUpperCorners(view: dayButton)
        roundUpperCorners(view: weekButton)
        roundUpperCorners(view: monthButton)*/
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.quintupleTap))
        recognizer.numberOfTapsRequired = 5
        monthButton.addGestureRecognizer(recognizer)
        
        yAxisLabel.transform =  CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        
        dateFormatter = DateFormatter()
        timeFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        
        //self.view.backgroundColor = UIColor.blue
        hourButtonClicked(self)
        updateChart()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.displayJoinHopkinsNetwork), name: NSNotification.Name(rawValue: "showHopkinsNetworkAlert"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.reloadTable), name: NSNotification.Name(rawValue: "updateTable"), object: nil)
        
        let writeDataTypes: Set<HKSampleType> = self.dataTypesToWrite()
        let readDataTypes: Set<HKObjectType> = self.dataTypesToRead()
        
        self.healthStore.requestAuthorization(toShare: writeDataTypes, read: readDataTypes) { (success, error) -> Void in
            if success == false {
                NSLog(" Display not allowed")
            }
        }
    }
    
    
        
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        updateChart()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func roundUpperCorners(view: UIView) {
        let maskPath = UIBezierPath(roundedRect: view.bounds,
                                    byRoundingCorners: [.topLeft, .topRight],
                                    cornerRadii: CGSize(width: 10.0, height: 10.0))
        let mask = CAShapeLayer()
        mask.path = maskPath.cgPath
        view.layer.mask = mask
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
        
        switch currentMode {
        case 1:
            logs = DatabaseManager.getFromDatabase(entityName: "Log", predicateString: "timestamp > \(Tools.dateFromNSDate(Date(timeIntervalSince1970: currentTime), hour: false).timeIntervalSince1970)", sortDescriptors: ["timestamp": false])
            break
        case 3:
            logs = DatabaseManager.getFromDatabase(entityName: "Log", predicateString: "timestamp > \(Tools.monthStartFromDate(Date(timeIntervalSince1970: currentTime)).timeIntervalSince1970)", sortDescriptors: ["timestamp": false])
            break
        default:
            logs = DatabaseManager.getFromDatabase(entityName: "Log", predicateString: "timestamp > \(currentTime - timeInterval)", sortDescriptors: ["timestamp": false])
            break
        }
        
        
        /*for log in (logs as! [Log]) {
         print("ts:\(log.timestamp)         pain: \(log.pain)")
         }*/
        
        let formatter = LineChartFormatter()
        var allEntries = [BarChartDataEntry]()
        var colors = [UIColor]()
        
        
        //set x-axis label titles
        switch currentMode {
        case 0:
            for i in 0...(barCount - 1) {
             allEntries.append(BarChartDataEntry(x: Double(i), y: 0.0))
             formatter.labels.append(dateFormatter.string(from: NSDate(timeIntervalSince1970: currentTime + Double(secondsPerBar * (i + 1)) - timeInterval) as Date))
             colors.append(UIColor.white)
             }
            break
        case 1:
            for i in 0...(barCount - 1) {
                allEntries.append(BarChartDataEntry(x: Double(i), y: 0.0))
                /*var string = "\(i):00"
                if i < 10 {
                    string = "0".appending(string)
                }
                formatter.labels.append(string)*/
                formatter.labels.append("\(i + 1)")
                colors.append(UIColor.white)
            }
            break
        case 2:
            for i in 0...(barCount - 1) {
                allEntries.append(BarChartDataEntry(x: Double(i), y: 0.0))
                formatter.labels.append(dateFormatter.string(from: NSDate(timeIntervalSince1970: currentTime + Double(secondsPerBar * (i + 1)) - timeInterval) as Date))
                colors.append(UIColor.white)
            }
            break
        case 3:
            for i in 0...(barCount - 1) {
                allEntries.append(BarChartDataEntry(x: Double(i), y: 0.0))
                formatter.labels.append("\(i + 1)")
                colors.append(UIColor.white)
            }
            break
        default:
            break
        }
        
        //set dummy bars
        /*for i in 0...(barCount - 1) {
            allEntries.append(BarChartDataEntry(x: Double(i), y: 0.0))
            formatter.labels.append(dateFormatter.string(from: NSDate(timeIntervalSince1970: currentTime - Double(secondsPerBar * i)) as Date))
            colors.append(UIColor.white)
        }*/
        
        if logs.count > 0 {
            var lastIndex = 0
            var count = 0.0
            for i in 0...(logs.count - 1) {
                let log = logs[i] as! Log
                
                var index = -1
                switch currentMode {
                case 0:
                    index = (60 - 1) - Int(currentTime - log.timestamp) / secondsPerBar
                    break
                case 1:
                    print(log.timestamp)
                    index = Tools.getHourOfDay(date: Date(timeIntervalSince1970: log.timestamp)) - 1
                    break
                case 2:
                    let currentDay = Tools.getDayOfYear(date: Date())
                    let logDay = Tools.getDayOfYear(date: Date(timeIntervalSince1970: log.timestamp))
                    index = (7 - 1) - (currentDay - logDay) % 7
                    break
                case 3:
                    index = Tools.getDayOfMonth(date: Date(timeIntervalSince1970: log.timestamp)) - 1
                    
                    break
                default:
                    break
                }
                
                if index != -1 {
                    if (index < allEntries.count) {
                        if allEntries[index].y == 0.0 || currentMode != 0 {
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
                }
                

                /*let log = logs[i] as! Log
                let index = Int(currentTime - log.timestamp) / secondsPerBar
                if (allEntries[index]).y == 0.0 || secondsPerBar > 60 { //only consider newest value, so ignore if bar already set
                    if currentMode != 0 {
                        if index != lastIndex {
                            lastIndex = index
                            count = 0
                        }
                        let yVal = (Double(log.pain) + (allEntries[index].y * count))/(count + 1)
                        allEntries[index].y = yVal
                        colors[index] = UIColor(hue: 0.35 - 0.035 * CGFloat(yVal), saturation: 1.0, brightness: 1.0, alpha: 0.9)
                        count += 1.0
                    } else {
                        allEntries[index].y = Double(log.pain)
                        colors[index] = UIColor(hue: 0.35 - 0.035 * CGFloat(Int(log.pain)), saturation: 1.0, brightness: 1.0, alpha: 0.9)
                    }
                }*/
                
            }
        }

        var chartData: BarChartData? = nil
        if logs.count > 0 {
            let chartDataSet =  BarChartDataSet(values: allEntries, label: "Pain Levels")
            chartDataSet.drawValuesEnabled = false
            chartDataSet.colors = colors
            chartData = BarChartData(dataSet: chartDataSet)
        }
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
        
        tableView.reloadData()
    }
    
    @IBAction func hourButtonClicked(_ sender: Any) {
        currentMode = 0
        updateChart()
        setButtonColor()
        roundUpperCorners(view: hourButton)
    }
    
    @IBAction func dayButtonClicked(_ sender: Any) {
        currentMode = 1
        updateChart()
        setButtonColor()
        roundUpperCorners(view: dayButton)
    }
    
    @IBAction func weekButtonClicked(_ sender: Any) {
        currentMode = 2
        updateChart()
        setButtonColor()
        roundUpperCorners(view: weekButton)
    }
    
    @IBAction func monthButtonClicked(_ sender: Any) {
        currentMode = 3
        updateChart()
        setButtonColor()
        roundUpperCorners(view: monthButton)
    }
    
    func setButtonColor() {
        hourButton.backgroundColor = UIColor(red: 90.0/255.0, green: 189.0/255.0, blue: 134.0/255.0, alpha: 1)
        dayButton.backgroundColor = UIColor(red: 90.0/255.0, green: 189.0/255.0, blue: 134.0/255.0, alpha: 1)
        weekButton.backgroundColor = UIColor(red: 90.0/255.0, green: 189.0/255.0, blue: 134.0/255.0, alpha: 1)
        monthButton.backgroundColor = UIColor(red: 90.0/255.0, green: 189.0/255.0, blue: 134.0/255.0, alpha: 1)
        
        
        switch currentMode {
        case 0:
            hourButton.backgroundColor = UIColor(red: 120.0/255.0, green: 223.0/255.0, blue: 152.0/255.0, alpha: 1)
            break
        case 1:
            dayButton.backgroundColor = UIColor(red: 120.0/255.0, green: 223.0/255.0, blue: 152.0/255.0, alpha: 1)
            break
        case 2:
            weekButton.backgroundColor = UIColor(red: 120.0/255.0, green: 223.0/255.0, blue: 152.0/255.0, alpha: 1)
            break
        case 3:
            monthButton.backgroundColor = UIColor(red: 120.0/255.0, green: 223.0/255.0, blue: 152.0/255.0, alpha: 1)
            break
        default:
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.height / 17
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "logCell")!
        let log = logs[indexPath.row] as! Log
        
        let date = Date(timeIntervalSince1970: log.timestamp)
        
        let dateString = dateFormatter.string(from: date)
        let timeString = timeFormatter.string(from: date)
        (cell.viewWithTag(1) as! UILabel).text = dateString
        (cell.viewWithTag(2) as! UILabel).text = timeString
        (cell.viewWithTag(3) as! UILabel).text = "Level \(log.pain)"
        cell.viewWithTag(4)!.backgroundColor = UIColor(hue: 0.35 - 0.035 * CGFloat(Int(log.pain)), saturation: 0.8, brightness: 0.8, alpha: 0.3)
        cell.viewWithTag(4)?.layer.cornerRadius = 5
        cell.viewWithTag(4)?.clipsToBounds = true
        cell.selectionStyle = .none
        return cell
    }
    
    func quintupleTap() {
        self.performSegue(withIdentifier: "goToWatchSettingsSegue", sender: self)
    }
    
    func displayJoinHopkinsNetwork() {
        let alert = UIAlertController(title: "Invalid Network", message: "Please joing the 'Hopkins' network in order to communicate with the server.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Okay", style: .default))
        self.present(alert, animated: true)
    }
    
}

