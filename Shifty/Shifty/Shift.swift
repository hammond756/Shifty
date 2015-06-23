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
    
    init(date: NSDate, owner: PFUser, objectID: String, status: String, acceptedBy: PFUser?, createdFrom: PFObject)
    {
        timeString = date.toString(format: DateFormat.Custom("HH:mm"))
        
        self.status = status
        self.createdFrom = createdFrom
        self.acceptedBy = acceptedBy
        
        self.createdFrom.fetchIfNeededInBackground()
        self.acceptedBy?.fetchIfNeededInBackground()
        
        super.init(date: date, owner: owner, objectID: objectID)
    }
    
    convenience required init(parseObject: PFObject)
    {
        let date = parseObject["Date"] as! NSDate
        let status = parseObject["Status"] as! String
        let owner = parseObject["Owner"] as! PFUser
        let createdFrom = parseObject["createdFrom"] as! PFObject
        var acceptedBy: PFUser? = nil
        
        if let hasBeenAcceptedBy = parseObject["acceptedBy"] as? PFUser
        {
            acceptedBy = hasBeenAcceptedBy
        }
        
        self.init(date: date, owner: owner, objectID: parseObject.objectId!, status: status, acceptedBy: acceptedBy, createdFrom: createdFrom)
    }
}