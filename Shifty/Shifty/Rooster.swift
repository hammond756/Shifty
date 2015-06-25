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
                let firstEntry = self.helper.nextOccurenceOfDay(day).set(componentsDict: ["hour": hour, "minute": minute])
                shift[ParseKey.lastEntry] = firstEntry
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
    
    func generateInitialShifts(fixedShift: PFObject, callback: () -> Void)
    {
        for week in 0..<amountOfRecurringWeeks
        {
            generateAdditionalShift(fixedShift, weeksAhead: week) { callback() }
        }
    }
    
    private func generateAdditionalShift(fixedShift: PFObject, weeksAhead: Int, callback: () -> Void)
    {
        let date = fixedShift[ParseKey.lastEntry] as! NSDate + weeksAhead.week
        
        let shift = PFObject(className: ParseClass.shifts)
        shift[ParseKey.date] = date
        shift[ParseKey.status] = Status.idle
        shift[ParseKey.owner] = PFUser.currentUser()
        shift[ParseKey.createdFrom] = fixedShift
        fixedShift[ParseKey.lastEntry] = date
        fixedShift.saveInBackground()
        
        // check if shift is the last of the initial shifts
        shift.saveInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
            if weeksAhead == self.amountOfRecurringWeeks - 1
            {
                callback()
            }
        }
    }
    
    func updateSchedule()
    {
        let query = PFQuery(className: ParseClass.fixed)
        query.whereKey(ParseKey.owner, equalTo: PFUser.currentUser()!)
        
        query.findObjectsInBackgroundWithBlock() { (objects: [AnyObject]?, error: NSError?) -> Void in
            if let fixedShifts = self.helper.returnObjectAfterErrorCheck(objects, error: error) as? [PFObject]
            {
                for fixed in fixedShifts
                {
                    if fixed[ParseKey.lastEntry] as! NSDate - self.amountOfRecurringWeeks.weeks < NSDate()
                    {
                        self.generateAdditionalShift(fixed, weeksAhead: 1) { }
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
            case Status.owned:      ownedShifts = helper.splitIntoSections(shifts, sections: sections)
            case Status.supplied:   suppliedShifts = helper.splitIntoSections(shifts, sections: sections)
            default: break
        }
    }
    
    func requestRequests(callback: (sections: [String]) -> Void)
    {
        doRequest(Status.requested) { (sections: [String], objects: [Request]) -> Void in
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
        helper.getQueryForStatus(Status.suggested).getObjectInBackgroundWithId(associatedWith) { (request: PFObject?, error: NSError?) -> Void in
            
            if let request = self.helper.returnObjectAfterErrorCheck(request, error: error) as? PFObject
            {
                if let suggestions = request[ParseKey.replies] as? [String]
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
        
        let query = PFQuery(className: ParseClass.shifts).whereKey(ParseKey.objectID, containedIn: iDs)
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