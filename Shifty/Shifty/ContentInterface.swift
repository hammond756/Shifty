//
//  ContentInterface.swift
//  Shifty
//
//  Created by Aron Hammond on 19/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//
//  Parent to Request and Shift. Shared properties/function are declared here

import Foundation
import Parse
import SwiftDate

// protocol that is needed for some functions with generic types
protocol HasDate: Equatable
{
    func getWeekOfYear() -> String
    var date: NSDate { get }
}

protocol ExistsInParse
{
    init(parseObject: PFObject)
}

// conform to Equatable
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
    
    // set properties
    init(date: NSDate, owner: PFUser, objectID: String)
    {
        self.date = date
        self.owner = owner
        self.objectID = objectID
        
        self.owner.fetchIfNeededInBackground()
        dateString = date.toString(format: DateFormat.Custom("EEEE dd MMM"))
    }
    
    // get properties from PFObject
    convenience required init(parseObject: PFObject)
    {
        let date = parseObject[ParseKey.date] as! NSDate
        let owner = parseObject[ParseKey.owner] as! PFUser
        let objectID = parseObject.objectId!
        
        self.init(date: date, owner: owner, objectID: objectID)
    }
    
    // return a string with the week of the year, adjust for monday as first day (eg. "Week 34")
    func getWeekOfYear() -> String
    {
        return "Week " + String((date - 1.day).weekOfYear)
    }
    
    func isOnSameDayAs(other: NSDate) -> Bool
    {
        let sameDay = date.day == other.day
        let sameMonth = date.month == other.month
        let sameYear = date.year == other.year
        
        return sameDay && sameMonth && sameYear
    }
}
