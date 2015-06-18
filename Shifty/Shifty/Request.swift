//
//  Request.swift
//  Shifty
//
//  Created by Aron Hammond on 16/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import Foundation
import Parse
import SwiftDate

class Request: HasDate
{
    var requestedBy: PFUser
    var date: NSDate
    var dateString: String
    
    init(date: NSDate, by: PFUser)
    {
        self.date = date
        self.requestedBy = by
        dateString = date.toString(format: DateFormat.Custom("EEEE dd MMM"))
    }
    
    convenience init(parseObject: PFObject)
    {
        let date = parseObject["date"] as! NSDate
        let requestedBy = parseObject["requestedBy"] as! PFUser
        
        self.init(date: date, by: requestedBy)
    }
    
    func getWeekOfYear() -> String
    {
        return "Week " + String((date - 1.day).weekOfYear)
    }
    
    func setFromParseObject(object: PFObject)
    {
        self.date = object["date"] as! NSDate
        self.requestedBy = object["requestedBy"] as! PFUser
    }
    
}