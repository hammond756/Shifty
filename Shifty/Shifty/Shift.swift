//
//  Shift.swift
//  Shifty
//
//  Created by Aron Hammond on 02/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import Foundation

class Shift
{    
    var dateString: String
    var timeString: String
    var dateObject: NSDate
    
    init(day: Int, month: Int, year: Int, time: (Int, Int))
    {
        var dateComponents = NSDateComponents()
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        let dateFormatter = NSDateFormatter()
        let timeFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE MMM dd"
        timeFormatter.dateFormat = "HH:mm"
        
        dateComponents.day = day
        dateComponents.month = month
        dateComponents.year = year
        dateComponents.hour = time.0
        dateComponents.minute = time.1
        
        dateObject = calendar.dateFromComponents(dateComponents)!
        dateString = dateFormatter.stringFromDate(dateObject)
        timeString = timeFormatter.stringFromDate(dateObject)
        
        println(dateString)
    }
    
    func getWeekOfYear() -> String
    {
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let myComponents = myCalendar.components(.CalendarUnitWeekOfYear, fromDate: self.dateObject)
        return "Week " + String(myComponents.weekOfYear)
    }
}