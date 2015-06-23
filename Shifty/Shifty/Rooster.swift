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
    
    func addRecurringShift(day: String, hour: Int, minute: Int)
    {
        checkDoubleEntries(day) { noDoubleEntries -> Void in
            if noDoubleEntries
            {
                let shift = PFObject(className: "FixedShifts")
                
                shift["Day"] = day
                shift["Hour"] = hour
                shift["Minute"] = minute
                shift["Owner"] = PFUser.currentUser()
                shift.saveInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                    if succes
                    {
                        self.generateRecurringShifts(shift)
                    }
                }
            }
        }
    }
    
    func checkDoubleEntries(day: String, callback: (noDoubleEntries: Bool) -> Void)
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
    
    func generateRecurringShifts(fixedShift: PFObject)
    {
        let day = fixedShift["Day"] as! String
        let hour = fixedShift["Hour"] as! Int
        let minute = fixedShift["Minute"] as! Int
        
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
    
    func requestShifts(withStatus: String, callback: (sections: [String]) -> Void)
    {
        requestParseObjects(withStatus) { objects -> Void in
            var tempShifts = [Shift]()
            for object in objects
            {
                let shift = Shift(parseObject: object)
                tempShifts.append(shift)
            }
            let sections = self.getSections(tempShifts)
            self.setShifts(withStatus, shifts: tempShifts, sections: sections)
            callback(sections: sections)
        }
    }
    
    func requestRequests(callback: (sections: [String]) -> Void)
    {
        requestParseObjects("Requested") { objects -> Void in
            
            var tempRequests = [Request]()
            
            for object in objects
            {
                let request = Request(parseObject: object)
                tempRequests.append(request)
            }
            
            let sections = self.getSections(tempRequests)
            self.requestedShifs = self.splitIntoSections(tempRequests, sections: sections)
            
            callback(sections: sections)
        }
    }
    
    func doRequest<T: ExistsInParse where T: HasDate>(withStatus: String, callback: (sections: [String], objects: [T]) -> Void)
    {
        requestParseObjects(withStatus) { objects -> Void in
            var tempObjects = [T]()
            for object in objects
            {
                let element = T(parseObject: object)
                tempObjects.append(element)
            }
            let sections = self.getSections(tempObjects)
            callback(sections: sections, objects: tempObjects)
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
            case "Owned": ownedShifts = splitIntoSections(shifts, sections: sections)
            case "Supplied": suppliedShifts = splitIntoSections(shifts, sections: sections)
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
    
    // split an array of generic type T into a two-dimensional array
    func splitIntoSections<T: HasDate>(var array: [T], sections: [String]) -> [[T]]
    {
        var sectionedArray = [[T]]()
        array.sort() { $0.date < $1.date }
        
        // get all elemenents where the week number equals that of the current section
        for section in sections
        {
            sectionedArray.append(array.filter() { $0.getWeekOfYear() == section })
        }
        
        return sectionedArray
    }
    
    // generate array of section titles from an array of generic type T
    func getSections<T: HasDate>(var array: [T]) -> [String]
    {
        var sections = [String]()
        array.sort() { $0.date < $1.date }
        
        for element in array
        {
            let weekOfYear = element.getWeekOfYear()
            
            if !contains(sections, weekOfYear)
            {
                sections.append(weekOfYear)
            }
        }
        
        return sections
    }
}