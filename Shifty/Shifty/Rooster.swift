//
//  Rooster.swift
//  Shifty
//
//  Created by Aron Hammond on 04/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import Parse
import SwiftDate
import Foundation

class Rooster
{
    // constant for duration of fixed schedule
    let amountOfRecurringWeeks = 8

    var ownedShifts = [Shift]()
    var suppliedShifts = [Shift]()
    
    func addRecurringShift(day: String, hour: Int, minute: Int)
    {
        let dayDict = ["Maandag": 2, "Dinsdag": 3, "Woensdag": 4, "Donderdag": 5, "Vrijdag": 6, "Zaterdag": 7, "Zondag": 1]
        
        var firstOccurrenceDate = nextOccurenceOfDay(dayDict[day]!).set(componentsDict: ["hour": hour, "minute": minute])
        
        for week in 0..<amountOfRecurringWeeks
        {
            let shift = PFObject(className: "Shifts")
            
            shift["Date"] = firstOccurrenceDate! + (7 * week).day
            shift["Status"] = "idle"
            shift["Owner"] = PFUser.currentUser()
            shift.saveInBackground()
        }
        
    }
    
    // missing: getSections, reload Table, hide/show table
    
    func requestOwnedShifts(callback: () -> Void)
    {
        let isOwner = PFQuery(className: "Shifts")
            .whereKey("Owner", equalTo: PFUser.currentUser()!)
        let hasAccepted = PFQuery(className: "Shifts")
            .whereKey("acceptedBy", equalTo: PFUser.currentUser()!)
        
        let query = PFQuery.orQueryWithSubqueries([isOwner, hasAccepted])
        
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error != nil
            {
                println(error?.description)
            }
            else if let objects = objects as? [PFObject]
            {
                self.ownedShifts = []
                
                for object in objects
                {
                    let shift = self.convertParseObjectToShift(object)
                    self.ownedShifts.append(shift)
                }
                
                self.ownedShifts.sort { $0.dateObject < $1.dateObject }
            }
            
            callback()
            
        }
    }
    
    func requestSuppliedShifts(callback: () -> Void)
    {
        let query = PFQuery(className: "Shifts")
            .whereKey("Status", equalTo: "Supplied")
        
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error != nil
            {
                println(error?.description)
            }
            else if let objects = objects as? [PFObject]
            {
                self.suppliedShifts.removeAll(keepCapacity: true)
                
                for object in objects
                {
                    let shift = self.convertParseObjectToShift(object)
                    self.suppliedShifts.append(shift)
                }
                
                self.suppliedShifts.sort() { $0.dateObject < $1.dateObject }
            }
            
            callback()
        }
    }
    
    private func convertParseObjectToShift(object: PFObject) -> Shift
    {
        let date = object["Date"] as? NSDate
        let status = object["Status"] as? String
        let owner = object["Owner"] as? PFUser
        
        return Shift(date: date!, stat: status!, objectID: object.objectId!, owner: owner!)
    }
    
    
    // function that calculates on which date the next occurence is of a given weekday
    private func nextOccurenceOfDay(day: Int) -> NSDate
    {
        let today = NSDate()
        var daysAhead = day - today.weekday
        
        if daysAhead < 0
        {
            daysAhead = daysAhead + 7
        }
        
        return today + daysAhead.day
    }
}