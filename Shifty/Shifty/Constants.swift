//
//  Constant.swift
//  Shifty
//
//  Created by Aron Hammond on 24/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//
//  Collection of structs to represent string constants throughout the code

import Foundation
import UIKit

// assortment of reused string constants
struct constant
{
    let reuseCell = "cell"
    let amountOfWeeksToGenerate = 8
    let amountOfDaysToGenerate = 31
    let pickerData = [
        [
            Weekday.monday,
            Weekday.tuesday,
            Weekday.wednesday,
            Weekday.thursday,
            Weekday.friday,
            Weekday.saturday,
            Weekday.sunday
        ],
        ["15:00", "15:30", "16:30", "17:00", "18:00", "18:30"]
    ]
}
let Constant = constant()

// days of the week in dutch
struct weekday
{
    let monday = "Maandag"
    let tuesday = "Dinsdag"
    let wednesday = "Woensdag"
    let thursday = "Donderdag"
    let friday = "Vrijdag"
    let saturday = "Zaterdag"
    let sunday = "Zondag"
}
let Weekday = weekday()

// segue identifiers
struct segue
{
    let makeSuggestion = "Make Suggestion"
    let seeSuggestions = "See Suggestions"
    let logIn = "Logged In"
}
let Segue = segue()

// all possible statusses
struct status
{
    let awaiting = "Awaiting Approval"
    let awaittingFromSug = "Awaiting Approval, sug"
    let idle = "idle"
    let owned = "Owned"
    let requested = "Requested"
    let suggested = "Suggested"
    let supplied = "Supplied"
}
let Status = status()

// all possible actions
struct action
{
    let accept = "Accept"
    let acceptSug = "Accept Suggestion"
    let approve = "Approve"
    let approveSug = "Approve Suggestion"
    let delete = "Delete"
    let disapprove = "Disapprove"
    let disapproveSug = "Disapprove Suggestion"
    let revoke = "Revoke"
    let supply = "Supply"
}
let Action = action()

// all AlertController labels
struct label
{
    let accept = "Accepteren"
    let approve = "Goedkeuren"
    let cancel = "Annuleren"
    let delete = "Verwijderen"
    let disapprove = "Afkeuren"
    let revoke = "Terugtrekken"
    let supply = "Aanbieden"
}
let Label = label()

// cell highlighting colors
struct highlight
{
    let supplied = UIColor(red: 255.0/255.0, green: 119.0/255.0, blue: 80.0/255.0, alpha: 1.0)
    let awaiting = UIColor(red: 255.0/255.0, green: 208.0/255.0, blue: 50.0/255.0, alpha: 1.0)
    let owner = UIColor(red: 255.0/255.0, green: 119.0/255.0, blue: 80.0/255.0, alpha: 1.0)
}
let Highlight = highlight()

// all Parse classes
struct parseClass
{
    let fixed = "FixedShifts"
    let requests = "RequestedShifts"
    let shifts = "Shifts"
}
let ParseClass = parseClass()

// all Parse keys
struct parseKey
{
    let acceptedBy = "acceptedBy"
    let createdFrom = "createdFrom"
    let day = "Day"
    let date = "Date"
    let hour = "Hour"
    let lastEntry = "lastEntry"
    let minute = "Minute"
    let objectID = "objectId"
    let owner = "Owner"
    let replies = "replies"
    let requestedBy = "requestedBy"
    let status = "Status"
    let suggestedTo = "suggestedTo"
}
let ParseKey = parseKey()