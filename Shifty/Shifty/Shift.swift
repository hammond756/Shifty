//
//  Shift.swift
//  Shifty
//
//  Created by Aron Hammond on 02/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import Foundation
import SwiftDate
import Parse

class Shift
{
    var dateString: String
    var timeString: String
    var dateObject: NSDate
    var status: String
    
    init(day: Int, month: Int, year: Int, hour: Int, minute: Int)
    {
        dateObject = NSDate.date(refDate: nil, year: year, month: month, day: day, hour: hour, minute: minute, second: 0, tz: nil)
        
        dateString = dateObject.toString(format: DateFormat.Custom("EEEE dd MMM"))
        timeString = dateObject.toString(format: DateFormat.Custom("HH:mm"))
        
        status = "None"
    }
    
    init(date: NSDate)
    {
        dateObject = date
        
        dateString = dateObject.toString(format: DateFormat.Custom("EEEE dd MMM"))
        timeString = dateObject.toString(format: DateFormat.Custom("HH:mm"))
        
        status = "None"
    }
    
    func getWeekOfYear() -> String
    {
        return "Week " + String(dateObject.weekOfYear)
    }
}