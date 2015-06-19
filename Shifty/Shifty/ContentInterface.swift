//
//  ContentInterface.swift
//  Shifty
//
//  Created by Aron Hammond on 19/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import Foundation
import Parse
import SwiftDate

class ContentInterface
{
    var date: NSDate
    var owner: PFUser
    var objectID: String
    var dateString: String
    
    init(date: NSDate, owner: PFUser, objectID: String)
    {
        self.date = date
        self.owner = owner
        self.objectID = objectID
        
        dateString = date.toString(format: DateFormat.Custom("EEEE dd MMM"))
    }
    
    convenience init(object: PFObject)
    {
        let date = object["Date"] as! NSDate
        let owner = object["Owner"] as! PFUser
        let objectID = object.objectId!
        
        self.init(date: date, owner: owner, objectID: objectID)
    }
    
    func getWeekOfYear() -> String
    {
        return "Week " + String((date - 1.day).weekOfYear)
    }
}
