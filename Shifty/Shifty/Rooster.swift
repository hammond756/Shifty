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

    var ownedShifts = [[Shift]]()
    var suppliedShifts = [[Shift]]()
    var suppliedSectionHeaders = [String]()
    var ownedSectionHeaders = [String]()
    
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
        
    func requestOwnedShifts(callback: (sections: [String]) -> Void)
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
                var tempShifts = [Shift]()
                
                for object in objects
                {
                    let shift = self.convertParseObjectToShift(object)
                    tempShifts.append(shift)
                }
                
                tempShifts.sort { $0.dateObject < $1.dateObject }
                let sections = self.getSections(tempShifts)
                self.ownedShifts = self.splitShiftsIntoSections(tempShifts, sections: sections)
                
                callback(sections: sections)
            }
            
        }
    }
    
    func requestSuppliedShifts(callback: (sections: [String]) -> Void)
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
                var tempShifts = [Shift]()
                
                for object in objects
                {
                    let shift = self.convertParseObjectToShift(object)
                    tempShifts.append(shift)
                }
                
                tempShifts.sort() { $0.dateObject < $1.dateObject }
                
                let sections = self.getSections(tempShifts)
                self.suppliedShifts = self.splitShiftsIntoSections(tempShifts, sections: sections)
                
                callback(sections: sections)
            }
            
            
        }
    }
    
    private func convertParseObjectToShift(object: PFObject) -> Shift
    {
        let date = object["Date"] as? NSDate
        let status = object["Status"] as? String
        let owner = object["Owner"] as? PFUser
        
        return Shift(date: date!, stat: status!, objectID: object.objectId!, owner: owner!)
    }
    
    // TODO: seperate getSections and splitShiftsIntoSections entirely. This return value is messy.
    private func splitShiftsIntoSections(shifts: [Shift], sections: [String]) -> [[Shift]]
    {
        var newShiftArray = [[Shift]]()
        
        for section in sections
        {
            newShiftArray.append(shifts.filter() { $0.getWeekOfYear() == section })
        }
        
        return newShiftArray
    }
    
    func getSections(shifts: [Shift]) -> [String]
    {
        var sections = [String]()
        
        for shift in shifts
        {
            let weekOfYear = shift.getWeekOfYear()
            
            if !contains(sections, weekOfYear)
            {
                sections.append(weekOfYear)
            }
        }
        
        return sections
    }
}