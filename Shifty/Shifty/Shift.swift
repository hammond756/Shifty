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

func == (lhs: Shift, rhs: Shift) -> Bool
{
    return lhs.objectID == rhs.objectID
}

class Shift: Equatable
{
    var dateString: String
    var timeString: String
    var dateObject: NSDate
    var status: String
    var objectID: String
    var owner: PFUser
    
    init(date: NSDate, stat: String, objectID: String, owner: PFUser)
    {
        dateObject = date
        dateString = dateObject.toString(format: DateFormat.Custom("EEEE dd MMM"))
        timeString = dateObject.toString(format: DateFormat.Custom("HH:mm"))
        
        self.status = stat
        self.objectID = objectID
        self.owner = owner
    }
    
    func getWeekOfYear() -> String
    {
        return "Week " + String((dateObject - 1.day).weekOfYear)
    }
}