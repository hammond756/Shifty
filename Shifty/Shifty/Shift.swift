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

class Shift: ContentInterface
{
    var timeString: String
    var status: String
    var createdFrom: PFObject
    var acceptedBy: PFUser?
    var suggestedTo: PFObject?
    
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