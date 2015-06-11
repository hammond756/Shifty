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
    var objectID: String
    
    init(date: NSDate, stat: String, objectID: String)
    {
        dateObject = date
        
        dateString = dateObject.toString(format: DateFormat.Custom("EEEE dd MMM"))
        timeString = dateObject.toString(format: DateFormat.Custom("HH:mm"))
        
        self.status = stat
        self.objectID = objectID
    }
    
    func getWeekOfYear() -> String
    {
        return "Week " + String(dateObject.weekOfYear)
    }
}