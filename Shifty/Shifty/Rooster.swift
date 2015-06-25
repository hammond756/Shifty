//
//  Rooster.swift
//  Shifty
//
//  Created by Aron Hammond on 04/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//
//  Handles everything to do with getting (creating) objects from (in) the database and saving them for use
//  inside the application.

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
    
    // write values to FixedShifts object in Parse
    func registerFixedShift(day: String, hour: Int, minute: Int, callback: (object: PFObject?) -> Void)
    {
        helper.checkDoubleEntries(day) { noDoubleEntries -> Void in
            if noDoubleEntries
            {
                let shift = PFObject(className: ParseClass.fixed)
                
                shift[ParseKey.day] = day
                shift[ParseKey.hour] = hour
                shift[ParseKey.minute] = minute
                shift[ParseKey.owner] = PFUser.currentUser()
                // the date of the next 'day' where 'day' is a weekday (eg. the  date of next monday)
                let firstEntry = self.helper.nextOccurenceOfDay(day).set(componentsDict: ["hour": hour, "minute": minute])
                shift[ParseKey.lastEntry] = firstEntry! - 1.week
                shift.saveInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                    if succes
                    {
                        callback(object: shift)
                    }
                }
            }
            else
            {
                callback(object: nil)
            }
        }
    }
    
    // generate amountOfRecurringWeeks weeks in the database
    func generateInitialShifts(fixedShift: PFObject, callback: () -> Void)
    {
        for week in 0..<amountOfRecurringWeeks
        {
            generateAdditionalShift(fixedShift) { callback() }
        }
    }
    
    // generate an extra shift weeksAhead weeks ahead
    func generateAdditionalShift(fixedShift: PFObject, callback: () -> Void)
    {
        let date = fixedShift[ParseKey.lastEntry] as! NSDate + 1.week
        println(date)
        
        let shift = PFObject(className: ParseClass.shifts)
        shift[ParseKey.date] = date
        shift[ParseKey.status] = Status.idle
        shift[ParseKey.owner] = PFUser.currentUser()
        shift[ParseKey.createdFrom] = fixedShift
        fixedShift[ParseKey.lastEntry] = date
        fixedShift.saveInBackground()
        
        // check if shift is the last of the initial shifts
        shift.saveInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
            if date - self.amountOfRecurringWeeks.week > NSDate()
            {
                callback()
            }
        }
    }
    
    // used to alsways keep the database stocked with shifts amountOfRecurringWeeks weeks ahead
    func updateSchedule()
    {
        // ask for fixed shifts owned by the current user
        let query = PFQuery(className: ParseClass.fixed)
        query.whereKey(ParseKey.owner, equalTo: PFUser.currentUser()!)
        query.findObjectsInBackgroundWithBlock() { (objects: [AnyObject]?, error: NSError?) -> Void in
            if let fixedShifts = self.helper.returnObjectAfterErrorCheck(objects, error: error) as? [PFObject]
            {
                for fixed in fixedShifts
                {
                    // is the last generated shift is less than amountOfRecurringWeeks weeks ahead:
                    if fixed[ParseKey.lastEntry] as! NSDate - self.amountOfRecurringWeeks.weeks < NSDate()
                    {
                        self.generateAdditionalShift(fixed) { }
                    }
                }
            }
        }
    }
    
    // withStatus: Status.supplied or Status.owned (gets and stores supplied and owned shifts respectively)
    func requestShifts(withStatus: String, callback: (sections: [String]) -> Void)
    {
        doRequest(withStatus) { (sections: [String], objects: [Shift]) -> Void in
            self.setShifts(withStatus, shifts: objects, sections: sections)
            callback(sections: sections)
        }
    }
    
    // set array corresponding with withStatus
    func setShifts(withStatus: String, shifts: [Shift], sections: [String])
    {
        switch withStatus
        {
            case Status.owned:      ownedShifts = helper.splitIntoSections(shifts, sections: sections)
            case Status.supplied:   suppliedShifts = helper.splitIntoSections(shifts, sections: sections)
            default: break
        }
    }
    
    // requests and stores requests
    func requestRequests(callback: (sections: [String]) -> Void)
    {
        doRequest(Status.requested) { (sections: [String], objects: [Request]) -> Void in
            self.requestedShifs = self.helper.splitIntoSections(objects, sections: sections)
            callback(sections: sections)
        }
    }
    
    // genarilized function to get data from Parse database (works with ContentInterface subclasses)
    func doRequest<T: ContentInterface>(withStatus: String, callback: (sections: [String], objects: [T]) -> Void)
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
    
    // function to get PFObjects associated with withStatus
    func requestParseObjects(withStatus: String, callback: (objects: [PFObject]) -> Void)
    {
        let query = helper.getQueryForStatus(withStatus)
        
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if let objects = self.helper.returnObjectAfterErrorCheck(objects, error: error) as? [PFObject]
            {
                callback(objects: objects)
            }
        }
    }
    
    // get request associated with specific ID and pass it to requestShiftsFromRequest
    func requestSuggestions(associatedWith: String, callback: (suggestions: [Shift]) -> Void)
    {
        // ask for RequestedShifts object with specific objectID
        PFQuery(className: ParseClass.requests).getObjectInBackgroundWithId(associatedWith) { (request: PFObject?, error: NSError?) -> Void in
            if let request = self.helper.returnObjectAfterErrorCheck(request, error: error) as? PFObject
            {
                self.requestShiftsFromRequest(request) { shifts -> Void in
                    callback(suggestions: shifts)
                }
            }
            else
            {
                return
            }
        }
    }
    
    // get alls shifts that point to a specific request in the database and pass them to the callback
    func requestShiftsFromRequest(request: PFObject, callback: (shifts: [Shift]) -> Void)
    {
        var shifts = [Shift]()
        
        // ask for all Shift objects that are suggestedTo the request
        let query = PFQuery(className: ParseClass.shifts).whereKey(ParseKey.suggestedTo, equalTo: request)
        query.findObjectsInBackgroundWithBlock() { (objects: [AnyObject]?, error: NSError?) -> Void in
            if let objects = self.helper.returnObjectAfterErrorCheck(objects, error: error) as? [PFObject]
            {
                for object in objects
                {
                    // create Shift instances and append them to the array
                    shifts.append(Shift(parseObject: object))
                }
                callback(shifts: shifts)
            }
        }
    }
}