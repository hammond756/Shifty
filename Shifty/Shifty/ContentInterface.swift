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

protocol HasDate
{
    func getWeekOfYear() -> String
    var date: NSDate { get }
}

protocol ExistsInParse
{
    init(parseObject: PFObject)
}

func == (lhs: ContentInterface, rhs: ContentInterface) -> Bool
{
    return lhs.objectID == rhs.objectID
}

class ContentInterface: HasDate, ExistsInParse, Equatable
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
        
        self.owner.fetchIfNeededInBackground()
        dateString = date.toString(format: DateFormat.Custom("EEEE dd MMM"))
    }
    
    convenience required init(parseObject: PFObject)
    {
        let date = parseObject[ParseKey.date] as! NSDate
        let owner = parseObject[ParseKey.owner] as! PFUser
        let objectID = parseObject.objectId!
        
        self.init(date: date, owner: owner, objectID: objectID)
    }
    
    func getWeekOfYear() -> String
    {
        return "Week " + String((date - 1.day).weekOfYear)
    }
}
