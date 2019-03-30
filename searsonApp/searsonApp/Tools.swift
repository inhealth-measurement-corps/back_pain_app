//
//  Tools.swift
//  searsonApp
//
//  Created by Matias Eisler on 11/11/16.
//  Copyright © 2016 Matias Eisler. All rights reserved.
//

import Foundation

class Tools {
    
    class func getMinuteOfHour(date: Date) -> Int {
        let cal = Calendar.current
        let minute = cal.ordinality(of: .minute, in: .hour, for: date)
        if let _ = minute {
            return minute!
        }
        return -1
    }
    
    class func getHourOfDay(date: Date) -> Int {
        let cal = Calendar.current
        let hour = cal.ordinality(of: .hour, in: .day, for: date)
        if let _ = hour {
            return hour!
        }
        return -1
    }
    
    /*class func getDayOfWeek(date: Date) -> Int {
        let cal = Calendar.current
        let day = cal.ordinality(of: .day, in: .weekday, for: date)
        if let _ = day {
            return day!
        }
        return -1
    }*/
    
    class func getDayOfMonth(date: Date) -> Int {
        let cal = Calendar.current
        let day = cal.ordinality(of: .day, in: .month, for: date)
        if let _ = day {
            return day!
        }
        return -1
    }
    
    class func getDayOfYear(date: Date) -> Int {
        let cal = Calendar.current
        let day = cal.ordinality(of: .day, in: .year, for: date)
        if let _ = day {
            return day!
        }
        return -1
    }
    
    class func monthStartFromDate(_ dateParam: Date) -> Date {
        var units: NSCalendar.Unit = [.year, .month]
        var components = (Calendar.current as NSCalendar).components(units, from: dateParam)
        
        var month = "\(components.month!)"
        if components.month! < 10 {
            month = "0\(month)"
        }
        let date = "\(components.year!)-\(month)-01"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: "\(date) 00:00:00")!
    }
    
    class func dateFromNSDate(_ dateParam: Date, hour: Bool) -> Date {
        var units: NSCalendar.Unit = [.year, .month, .day]
        var components = (Calendar.current as NSCalendar).components(units, from: dateParam)
        
        var month = "\(components.month!)"
        if components.month! < 10 {
            month = "0\(month)"
        }
        var day = "\(components.day!)"
        if components.day! < 10 {
            day = "0\(day)"
        }
        let date = "\(components.year!)-\(month)-\(day)"
        
        units = [.hour, .minute, .second]
        var timeString = "00:00:00"
        
        if hour {
            components = (Calendar.current as NSCalendar).components(units, from: dateParam)
            timeString = "\(components.hour!):00:00"
            if components.hour! < 10 {
                timeString = "0".appending(timeString)
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: "\(date) \(timeString)")!
    }
    
    class func dateTimeFromNSDate(_ dateParam: Date, timeParam: Date? = nil) -> String {
        var units: NSCalendar.Unit = [.year, .month, .day]
        var components = (Calendar.current as NSCalendar).components(units, from: dateParam)
        
        var month = "\(components.month)"
        if components.month! < 10 {
            month = "0\(month)"
        }
        var day = "\(components.day)"
        if components.day! < 10 {
            day = "0\(day)"
        }
        let date = "\(components.year)-\(month)-\(day)"
        
        var time = dateParam
        if let _ = timeParam {
            time = timeParam!
        }
        
        units = [.hour]
        components = (Calendar.current as NSCalendar).components(units, from: time)
        
        var hour = "\(components.hour!)"
        if components.hour! < 10 {
            hour = "0\(hour)"
        }
        
        let timeString = "\(hour):00:00"
        
        return "\(date) \(timeString)"
    }
    
    class func dateTimeFromCurrentDate() -> String {
        let currentDate = Date()
        let currentTime = currentDate
        
        var units: NSCalendar.Unit = [.year, .month, .day]
        var components = (Calendar.current as NSCalendar).components(units, from: currentDate)
        
        var month = "\(components.month)"
        if components.month! < 10 {
            month = "0\(month)"
        }
        var day = "\(components.day)"
        if components.day! < 10 {
            day = "0\(day)"
        }
        let date = "\(components.year)-\(month)-\(day)"
        
        units = [.hour, .minute, .second]
        components = (Calendar.current as NSCalendar).components(units, from: currentTime)
        
        var hour = "\(components.hour)"
        if components.hour! < 10 {
            hour = "0\(hour)"
        }
        
        var minute = "\(components.minute)"
        if components.minute! < 10 {
            minute = "0\(minute)"
        }
        
        let second = "\(components.second)"
        if components.second! < 10 {
            hour = "0\(second)"
        }
        
        let time = "\(hour):\(minute):\(second)"
        
        return "\(date) \(time)"
    }
    
    class func dateArrayFromDateTime(_ datetime: String) -> [String] {
        let dateTimeArray = datetime.characters.split{$0 == " "}.map(String.init)
        let dateArray = dateTimeArray[0].characters.split{$0 == "-"}.map(String.init)
        let timeArray = dateTimeArray[1].characters.split{$0 == ":"}.map(String.init)
        var returnArray = [String]()
        for item in dateArray {
            returnArray.append(item)
        }
        for item in timeArray {
            returnArray.append(item)
        }
        return returnArray
    }
}
