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
    
    let helper = Helper()
    
    func registerFixedShift(day: String, hour: Int, minute: Int)
    {
        checkDoubleEntries(day) { noDoubleEntries -> Void in
            if noDoubleEntries
            {
                let shift = PFObject(className: "FixedShifts")
                
                shift["Day"] = day
                shift["Hour"] = hour
                shift["Minute"] = minute
                shift["Owner"] = PFUser.currentUser()
                shift["lastEntry"] = self.nextOccurenceOfDay(day).set(componentsDict: ["hour": hour, "minute": minute])
                shift.saveInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                    if succes
                    {
                        self.generateInitialShifts(shift)
                    }
                }
            }
        }
    }
    
    private func checkDoubleEntries(day: String, callback: (noDoubleEntries: Bool) -> Void)
    {
        let query = PFQuery(className: "FixedShifts")
        query.whereKey("Owner", equalTo: PFUser.currentUser()!)
        query.findObjectsInBackgroundWithBlock() { (objects: [AnyObject]?, error: NSError?) -> Void in
            if let ownedShifts = self.helper.returnObjectAfterErrorCheck(objects, error: error) as? [PFObject]
            {
                for shift in ownedShifts
                {
                    if shift["Day"] as! String == day
                    {
                        callback(noDoubleEntries: false)
                        return
                    }
                }
                callback(noDoubleEntries: true)
            }
        }
    }
    
    // samenvoegen met generate additional shift
    private func generateInitialShifts(fixedShift: PFObject)
    {
        let day = fixedShift["Day"] as! String
        let hour = fixedShift["Hour"] as! Int
        let minute = fixedShift["Minute"] as! Int
        
        var firstOccurrenceDate = nextOccurenceOfDay(day).set(componentsDict: ["hour": hour, "minute": minute])
        
        for week in 0..<amountOfRecurringWeeks
        {
            let shift = PFObject(className: "Shifts")
            
            shift["Date"] = firstOccurrenceDate! + (7 * week).day
            shift["Status"] = "idle"
            shift["Owner"] = PFUser.currentUser()
            shift["createdFrom"] = fixedShift
            fixedShift["lastEntry"] = firstOccurrenceDate! + (7 * week).day
            shift.saveInBackground()
            fixedShift.saveInBackground()
        }
    }
    
    private func generateAdditionalShift(fixedShift: PFObject)
    {
        let day = fixedShift["Day"] as! String
        let hour = fixedShift["Hour"] as! Int
        let minute = fixedShift["Minute"] as! Int
        let date = fixedShift["lastEntry"] as! NSDate + 1.week
        
        let dayDict = ["Maandag": 2, "Dinsdag": 3, "Woensdag": 4, "Donderdag": 5, "Vrijdag": 6, "Zaterdag": 7, "Zondag": 1]

        let shift = PFObject(className: "Shifts")
        shift["Date"] = date
        shift["Status"] = "idle"
        shift["Owner"] = PFUser.currentUser()
        shift["createdFrom"] = fixedShift
        fixedShift["lastEntry"] = date
        shift.saveInBackground()
        fixedShift.saveInBackground()
    }
    
    func updateSchedule()
    {
        let query = PFQuery(className: "FixedShifts")
            .whereKey("Owner", equalTo: PFUser.currentUser()!)
        
        query.findObjectsInBackgroundWithBlock() { (objects: [AnyObject]?, error: NSError?) -> Void in
            if let fixedShifts = self.helper.returnObjectAfterErrorCheck(objects, error: error) as? [PFObject]
            {
                for fixed in fixedShifts
                {
                    if fixed["lastEntry"] as! NSDate - self.amountOfRecurringWeeks.weeks < NSDate()
                    {
                        self.generateAdditionalShift(fixed)
                    }
                }
            }
        }
    }
    
    // function that calculates on which date the next occurence is of a given weekday
    private func nextOccurenceOfDay(day: String) -> NSDate
    {
        let dayDict = ["Maandag": 2, "Dinsdag": 3, "Woensdag": 4, "Donderdag": 5, "Vrijdag": 6, "Zaterdag": 7, "Zondag": 1]

        let today = NSDate()
        var daysAhead = dayDict[day]! - today.weekday
        
        if daysAhead < 0
        {
            daysAhead = daysAhead + 7
        }
        
        return today + daysAhead.day
    }
    
    func requestShifts(withStatus: String, callback: (sections: [String]) -> Void)
    {
        doRequest(withStatus) { (sections: [String], objects: [Shift]) -> Void in
            self.setShifts(withStatus, shifts: objects, sections: sections)
            callback(sections: sections)
        }
    }
    
    func requestRequests(callback: (sections: [String]) -> Void)
    {
        doRequest("Requested") { (sections: [String], objects: [Request]) -> Void in
            self.requestedShifs = self.helper.splitIntoSections(objects, sections: sections)
            callback(sections: sections)
        }
    }
    
    private func doRequest<T: ExistsInParse where T: HasDate>(withStatus: String, callback: (sections: [String], objects: [T]) -> Void)
    {
        requestParseObjects(withStatus) { objects -> Void in
            var tempObjects = [T]()
            for object in objects
            {
                let element = T(parseObject: object)
                tempObjects.append(element)
            }
            let sections = self.helper.getSections(tempObjects)
            callback(sections: sections, objects: tempObjects)
        }
    }
    
    private func requestParseObjects(withStatus: String, callback: (objects: [PFObject]) -> Void)
    {
        let query = getQueryForStatus(withStatus)
        
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if let objects = self.helper.returnObjectAfterErrorCheck(objects, error: error) as? [PFObject]
            {
                callback(objects: objects)
            }
        }
    }
    
    
    func requestSuggestions(associatedWith: String, callback: (suggestions: [String]) -> Void)
    {
        getQueryForStatus("Suggested").getObjectInBackgroundWithId(associatedWith) { (request: PFObject?, error: NSError?) -> Void in
            
            if let request = self.helper.returnObjectAfterErrorCheck(request, error: error) as? PFObject
            {
                if let suggestions = request["replies"] as? [String]
                {
                    callback(suggestions: suggestions)
                }
                else
                {
                    callback(suggestions: [])
                }
            }
        }
    }
    
    func requestShiftsFromIDs(iDs: [String], callback: (shifts: [Shift]) -> Void)
    {
        var shifts = [Shift]()
        
        let query = PFQuery(className: "Shifts").whereKey("objectId", containedIn: iDs)
        query.findObjectsInBackgroundWithBlock() { (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if let objects = self.helper.returnObjectAfterErrorCheck(objects, error: error) as? [PFObject]
            {
                for object in objects
                {
                    shifts.append(Shift(parseObject: object))
                }
                callback(shifts: shifts)
            }
        }
    }
    
    private func setShifts(withStatus: String, shifts: [Shift], sections: [String])
    {
        switch withStatus
        {
            case "Owned": ownedShifts = helper.splitIntoSections(shifts, sections: sections)
            case "Supplied": suppliedShifts = helper.splitIntoSections(shifts, sections: sections)
            default: break
        }
    }
    
    // function to get correct query for a given status
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
        else if status == "Suggested"
        {
            query = PFQuery(className: "RequestedShifts")
        }
        
        return query
    }
}