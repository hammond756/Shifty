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
    var requestedShifs = [[Request]]()
    
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
        
    func requestShifts(withStatus: String, callback: (sections: [String]) -> Void)
    {
        let query = getQueryForStatus(withStatus)
        
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
                self.setShifts(withStatus, shifts: tempShifts, sections: sections)
                
                callback(sections: sections)
            }
            
        }
    }
    
    private func setShifts(withStatus: String, shifts: [Shift], sections: [String])
    {
        switch withStatus
        {
            case "Owned": ownedShifts = splitShiftsIntoSections(shifts, sections: sections)
            case "Supplied": suppliedShifts = splitShiftsIntoSections(shifts, sections: sections)
            default: break
        }
    }
    
    // helper function to get correct query for a given status
    private func getQueryForStatus(status: String) -> PFQuery
    {
        var query = PFQuery()
        
        if status == "Owned"
        {
            let isOwner = PFQuery(className: "Shifts").whereKey("Owner", equalTo: PFUser.currentUser()!)
            let hasAccepted = PFQuery(className: "Shifts").whereKey("acceptedBy", equalTo: PFUser.currentUser()!)
            
            query = PFQuery.orQueryWithSubqueries([isOwner, hasAccepted])
        }
        else if status == "Supplied"
        {
            query = PFQuery(className: "Shifts").whereKey("Status", equalTo: "Supplied")
        }
        else if status == "Requested"
        {
            query = PFQuery(className: "RequestedShifts")
        }
        
        return query
    }
    
    func requestRequestedShifts(callback: (sections: [String]) -> Void)
    {
        let query = getQueryForStatus("Requested")
        
        query.findObjectsInBackgroundWithBlock() { (objects: [AnyObject]?, error: NSError?) -> Void in
         
            if error != nil
            {
                println(error?.description)
            }
            else if let objects = objects as? [PFObject]
            {
                var tempRequests = [Request]()
                
                for object in objects
                {
                    let request = self.convertParseOjbectToRequest(object)
                    tempRequests.append(request)
                }
                
                tempRequests.sort() { $0.date < $1.date }
                let sections = self.getSections(tempRequests)
                self.requestedShifs = self.splitRequestsIntoSections(tempRequests, sections: sections)
                
                callback(sections: sections)
            }
        }
    }
    
    // TODO: find a way to handle shifts/requests by the same function
    //
    //
    // DOUBLE FUNCTIONS
    
    private func convertParseObjectToShift(object: PFObject) -> Shift
    {
        let date = object["Date"] as? NSDate
        let status = object["Status"] as? String
        let owner = object["Owner"] as? PFUser
        
        return Shift(date: date!, stat: status!, objectID: object.objectId!, owner: owner!)
    }
    
    private func convertParseOjbectToRequest(object: PFObject) -> Request
    {
        let date = object["date"] as! NSDate
        let requestedBy = object["requestedBy"] as! PFUser
        
        return Request(date: date, by: requestedBy)
    }
    
    private func splitShiftsIntoSections(shifts: [Shift], sections: [String]) -> [[Shift]]
    {
        var newShiftArray = [[Shift]]()
        
        for section in sections
        {
            newShiftArray.append(shifts.filter() { $0.getWeekOfYear() == section })
        }
        
        return newShiftArray
    }
    
    private func splitRequestsIntoSections(requests: [Request], sections: [String]) -> [[Request]]
    {
        var newShiftArray = [[Request]]()
        
        for section in sections
        {
            newShiftArray.append(requests.filter() { $0.getWeekOfYear() == section })
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
    
    func getSections(requests: [Request]) -> [String]
    {
        var sections = [String]()
        
        for shift in requests
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