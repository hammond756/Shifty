//
//  Helper.swift
//  Shifty
//
//  Created by Aron Hammond on 17/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//
//  Collection of functions that are shared in different classes
//  concern transforming data, errorchecking, query making and other things

import Foundation
import Parse
import UIKit
import SwiftDate

class Helper
{
    // log out current user and show the LoginViewController
    func logOut(viewController: UIViewController)
    {
        PFUser.logOut()
        
        let loginViewController = viewController.storyboard!.instantiateViewControllerWithIdentifier("Login") as! LogInViewController
        UIApplication.sharedApplication().keyWindow?.rootViewController = loginViewController
    }
    
    // set properties for the accessoryView of a tableViewCell
    func createTimeLabel(time: String) -> UILabel
    {
        var label = UILabel()
        label.font = UIFont.systemFontOfSize(14)
        label.textAlignment = NSTextAlignment.Center
        label.text = time
        label.sizeToFit()
        
        return label
    }
    
    // fucntion for de-cluttering error checking in Parse requests
    func returnObjectAfterErrorCheck(object: AnyObject?, error: NSError?) -> AnyObject?
    {
        if error != nil
        {
            println(error?.description)
            return nil
        }
        
        return object
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
    
    // check the FixedShifts if there is an enty owned by the current user on a certain day
    func checkDoubleEntries(day: String, callback: (noDoubleEntries: Bool) -> Void)
    {
        // get fixed shifts owned by the user
        let query = PFQuery(className: ParseClass.fixed)
        query.whereKey(ParseKey.owner, equalTo: PFUser.currentUser()!)
        query.findObjectsInBackgroundWithBlock() { (objects: [AnyObject]?, error: NSError?) -> Void in
            if let ownedShifts = self.returnObjectAfterErrorCheck(objects, error: error) as? [PFObject]
            {
                for shift in ownedShifts
                {
                    // when found, pass 'false' and return from function
                    if shift[ParseKey.day] as! String == day
                    {
                        callback(noDoubleEntries: false)
                        return
                    }
                }
                callback(noDoubleEntries: true)
            }
        }
    }
    
    // function to get correct query for a given status
    func getQueryForStatus(status: String) -> PFQuery
    {
        var query = PFQuery()
        
        if status == Status.owned
        {
            // ask for shifts either owned or accepted by the user
            let isOwner = PFQuery(className: ParseClass.shifts).whereKey(ParseKey.owner, equalTo: PFUser.currentUser()!)
            let hasAccepted = PFQuery(className: ParseClass.shifts).whereKey(ParseKey.acceptedBy, equalTo: PFUser.currentUser()!)
            
            query = PFQuery.orQueryWithSubqueries([isOwner, hasAccepted])
        }
        else if status == Status.supplied
        {
            // ask for all supplied shifts
            query = PFQuery(className: ParseClass.shifts).whereKey(ParseKey.status, equalTo: Status.supplied)
        }
        else if status == Status.requested
        {
            // ask for requests
            query = PFQuery(className: ParseClass.requests)
        }
        
        return query
    }
    
    // passes 'true' to callback if the user owns a shift on the given date
    func checkIfDateIsTaken(dateToCheck: NSDate, callback: (taken: Bool) -> Void)
    {
        // ask for all shifts owned by current user
        let query = PFQuery(className: ParseClass.shifts)
        query.whereKey(ParseKey.owner, equalTo: PFUser.currentUser()!)
        query.findObjectsInBackgroundWithBlock() { (shifts: [AnyObject]?, error: NSError?) -> Void in
            if let shifts = self.returnObjectAfterErrorCheck(shifts, error: error) as? [PFObject]
            {
                for shift in shifts
                {
                    let date = shift[ParseKey.date] as! NSDate
                    if date.day == dateToCheck.day && date.month == dateToCheck.date.month
                    {
                        callback(taken: true)
                        return
                    }
                    else
                    {
                        continue
                    }
                }
                callback(taken: false)
            }
        }
    }
    
    func updateShiftStatuses(shiftIDs: [String], newStatus: String, suggestedTo: PFObject?, callback: () -> Void)
    {
        // ask for all shifts objects corresponding with IDs in shiftIDs
        let query = PFQuery(className: ParseClass.shifts)
        query.whereKey(ParseKey.objectID, containedIn: shiftIDs)
        query.findObjectsInBackgroundWithBlock() { (shifts: [AnyObject]?, error: NSError?) -> Void in
            if let shifts = self.returnObjectAfterErrorCheck(shifts, error: error) as? [PFObject]
            {
                for shift in shifts
                {
                    shift[ParseKey.status] = newStatus
                    switch newStatus
                    {
                    case Status.suggested:  shift[ParseKey.suggestedTo] = suggestedTo!
                    case Status.idle:       shift.removeObjectForKey(ParseKey.suggestedTo)
                    case Status.supplied:   shift.removeObjectForKey(ParseKey.acceptedBy)
                    default: break
                    }
                    shift.saveInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                        callback()
                    }
                }
            }
        }
    }
    
    // function that calculates on which date the next occurence is of a given weekday
    func nextOccurenceOfDay(day: String) -> NSDate
    {
        let dayDict = [
            Weekday.monday:    2,
            Weekday.tuesday:   3,
            Weekday.wednesday: 4,
            Weekday.thursday:  5,
            Weekday.friday:    6,
            Weekday.saturday:  7,
            Weekday.sunday:    1
        ]
        
        let today = NSDate()
        var daysAhead = dayDict[day]! - today.weekday
        
        if daysAhead < 0
        {
            daysAhead = daysAhead + 7
        }
        
        return today + daysAhead.day
    }
}
