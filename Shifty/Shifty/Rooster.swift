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
        helper.checkDoubleEntries(day) { noDoubleEntries -> Void in
            if noDoubleEntries
            {
                let shift = PFObject(className: "FixedShifts")
                
                shift["Day"] = day
                shift["Hour"] = hour
                shift["Minute"] = minute
                shift["Owner"] = PFUser.currentUser()
                shift["lastEntry"] = self.helper.nextOccurenceOfDay(day).set(componentsDict: ["hour": hour, "minute": minute])
                shift.saveInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                    if succes
                    {
                        self.generateInitialShifts(shift)
                    }
                }
            }
        }
    }
       
    // samenvoegen met generate additional shift
    private func generateInitialShifts(fixedShift: PFObject)
    {
        let day = fixedShift["Day"] as! String
        let hour = fixedShift["Hour"] as! Int
        let minute = fixedShift["Minute"] as! Int
        
        var firstOccurrenceDate = helper.nextOccurenceOfDay(day).set(componentsDict: ["hour": hour, "minute": minute])
        
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
    
    func requestShifts(withStatus: String, callback: (sections: [String]) -> Void)
    {
        doRequest(withStatus) { (sections: [String], objects: [Shift]) -> Void in
            self.setShifts(withStatus, shifts: objects, sections: sections)
            callback(sections: sections)
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
    
    func requestRequests(callback: (sections: [String]) -> Void)
    {
        doRequest("Requested") { (sections: [String], objects: [Request]) -> Void in
            self.requestedShifs = self.helper.splitIntoSections(objects, sections: sections)
            callback(sections: sections)
        }
    }
    
    private func doRequest<T: ContentInterface>(withStatus: String, callback: (sections: [String], objects: [T]) -> Void)
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
        let query = helper.getQueryForStatus(withStatus)
        
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if let objects = self.helper.returnObjectAfterErrorCheck(objects, error: error) as? [PFObject]
            {
                callback(objects: objects)
            }
        }
    }
    
    func requestSuggestions(associatedWith: String, callback: (suggestions: [String]) -> Void)
    {
        helper.getQueryForStatus("Suggested").getObjectInBackgroundWithId(associatedWith) { (request: PFObject?, error: NSError?) -> Void in
            
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
            else
            {
                return
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
}