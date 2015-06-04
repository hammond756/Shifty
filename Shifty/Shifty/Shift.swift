//
//  Shift.swift
//  Shifty
//
//  Created by Aron Hammond on 02/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import Foundation
import SwiftDate

class Shift
{
    var dateString: String
    var timeString: String
    var dateObject: NSDate
    
    init(day: Int, month: Int, year: Int, time: (Int, Int))
    {
        dateObject = NSDate.date(refDate: nil, year: year, month: month, day: day, hour: time.0, minute: time.1, second: 0, tz: nil)
        
        dateString = dateObject.toString(format: DateFormat.Custom("EEE dd MMM"))
        timeString = dateObject.toString(format: DateFormat.Custom("HH:mm"))
    }
    
    func getWeekOfYear() -> String
    {
        return "Week " + String(dateObject.weekOfYear)
    }
}