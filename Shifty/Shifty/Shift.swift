//
//  Shift.swift
//  Shifty
//
//  Created by Aron Hammond on 02/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//
//  Represents a shift. A user's schedule is made of of shifts which he/she owns.
//  These owned shifts can be supplied to the marketplace (AangebodenViewController)
//  and suggested to Requests.

import Foundation
import SwiftDate
import Parse

class Shift: ContentInterface
{
    // additional properties for Shift
    var timeString: String
    var status: String
    var createdFrom: PFObject
    var acceptedBy: PFUser?
    var suggestedTo: PFObject?
    
    // set properties
    init(date: NSDate, owner: PFUser, objectID: String, status: String, acceptedBy: PFUser?, createdFrom: PFObject, suggestedTo: PFObject?)
    {
        timeString = date.toString(format: DateFormat.Custom("HH:mm"))
        
        self.status = status
        self.createdFrom = createdFrom
        self.acceptedBy = acceptedBy
        self.suggestedTo = suggestedTo
        
        self.createdFrom.fetchIfNeededInBackground()
        self.acceptedBy?.fetchIfNeededInBackground()
                
        super.init(date: date, owner: owner, objectID: objectID)
    }
    
    // initialize instance from PFObject
    convenience required init(parseObject: PFObject)
    {
        let date = parseObject[ParseKey.date] as! NSDate
        let status = parseObject[ParseKey.status] as! String
        let owner = parseObject[ParseKey.owner] as! PFUser
        let createdFrom = parseObject[ParseKey.createdFrom] as! PFObject
        let suggestedTo = parseObject[ParseKey.suggestedTo] as? PFObject
        var acceptedBy = parseObject[ParseKey.acceptedBy] as? PFUser
        
        self.init(date: date, owner: owner, objectID: parseObject.objectId!, status: status, acceptedBy: acceptedBy, createdFrom: createdFrom, suggestedTo: suggestedTo)
    }
}