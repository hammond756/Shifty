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

protocol ExistsInParse
{
    init(parseObject: PFObject)
}

class Shift: Equatable, HasDate, ExistsInParse
{
    var dateString: String
    var timeString: String
    var date: NSDate
    var status: String
    var objectID: String
    var owner: PFUser
    var acceptedBy: PFUser?
    
    init(date: NSDate, stat: String, objectID: String, owner: PFUser, acceptedBy: PFUser?)
    {
        self.date = date
        dateString = date.toString(format: DateFormat.Custom("EEEE dd MMM"))
        timeString = date.toString(format: DateFormat.Custom("HH:mm"))
        
        self.status = stat
        self.objectID = objectID
        self.owner = owner
        self.acceptedBy = acceptedBy
        
        self.owner.fetchIfNeededInBackground()
        self.acceptedBy?.fetchIfNeededInBackground()
    }
    
    convenience required init(parseObject: PFObject)
    {
        let date = parseObject["Date"] as! NSDate
        let status = parseObject["Status"] as! String
        let owner = parseObject["Owner"] as! PFUser
        var acceptedBy: PFUser? = nil
        
        if let hasBeenAcceptedBy = parseObject["acceptedBy"] as? PFUser
        {
            acceptedBy = hasBeenAcceptedBy
        }
        
        self.init(date: date, stat: status, objectID: parseObject.objectId!, owner: owner, acceptedBy: acceptedBy)
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