//
//  Constant.swift
//  Shifty
//
//  Created by Aron Hammond on 24/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import Foundation

struct constant
{
    let reuseCell = "cell"
    
    let pickerData = [
        ["Maandag","Dinsdag","Woensdag","Donderdag","Vrijdag","Zaterdag","Zondag"],
        ["15:00", "15:30", "16:30", "17:00", "18:00", "18:30"]
    ]
}

let Constant = constant()

struct segue
{
    let makeSuggestion = "Make Suggestion"
    let seeSuggestions = "See Suggestions"
}

let Segue = segue()

struct status
{
    let awaitting = "Awaitting Approval"
    let awaittingFromSug = "Awaitting Approval, sug"
    let idle = "idle"
    let owned = "Owned"
    let suggested = "Suggested"
    let supplied = "Supplied"
}

let Status = status()

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

struct Labels
{
    let accept = "Accepteren"
    let approve = "Goedkeuren"
    let delete = "Verwijderen"
    let disapprove = "Afkeuren"
    let revoke = "Terugtrekken"
    let supply = "Aanbieden"
}

struct parseClass
{
    let fixed = "FixedShifts"
    let requests = "RequestedShifts"
    let shifts = "Shifts"
}

let ParseClass = parseClass()

struct parseKey
{
    let acceptedBy = "acceptedBy"
    let createdFrom = "createdFrom"
    let day = "Day"
    let date = "date"
    let hour = "Hour"
    let lastEntry = "lastEntry"
    let minute = "Minute"
    let objectID = "objectId"
    let owner = "Owner"
    let replies = "replies"
    let requestedBy = "requestedBy"
    let suggestedTo = "suggestedTo"
}

let ParseKey = parseKey()