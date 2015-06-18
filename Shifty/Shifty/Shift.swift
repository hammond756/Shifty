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

protocol HasDate
{
    func getWeekOfYear() -> String
    var date: NSDate { get set }
}

class Shift: Equatable, HasDate
{
    var dateString: String
    var timeString: String
    var date: NSDate
    var status: String
    var objectID: String
    var owner: PFUser
    
    init(date: NSDate, stat: String, objectID: String, owner: PFUser)
    {
        self.date = date
        dateString = date.toString(format: DateFormat.Custom("EEEE dd MMM"))
        timeString = date.toString(format: DateFormat.Custom("HH:mm"))
        
        self.status = stat
        self.objectID = objectID
        self.owner = owner
    }
    
    convenience init(parseObject: PFObject)
    {
        let date = parseObject["Date"] as! NSDate
        let status = parseObject["Status"] as! String
        let owner = parseObject["Owner"] as! PFUser
        
        self.init(date: date, stat: status, objectID: parseObject.objectId!, owner: owner)
    }
    
    func getWeekOfYear() -> String
    {
        return "Week " + String((date - 1.day).weekOfYear)
    }
    
    func setFromParseObject(object: PFObject)
    {
        self.date = object["Date"] as! NSDate
        self.status = object["Status"] as! String
        self.owner = object["Owner"] as! PFUser
    }
    
    
}