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
    var recurringShifts = [Shift]()
    
    func addRecurringShift(day: String, time: String)
    {
        let timeObject = time.toDate(format: DateFormat.Custom("HH:mm"))
        let dayDict = ["Maandag": 2, "Dinsdag": 3, "Woensdag": 4, "Donderdag": 5, "Vrijdag": 6, "Zaterdag:": 7, "Zondag": 1]
        
        let firstOccurenceDate = nextOccurenceOfDay(dayDict[day]!)
        firstOccurenceDate.set("hour", value: timeObject?.hour)
        firstOccurenceDate.set("mintue", value: timeObject?.minute)
        
        for weeks in 1...amountOfRecurringWeeks
        {
            let date = firstOccurenceDate + (7 * weeks).day
            recurringShifts.append(Shift(date: date))
        }
    }
    
    func nextOccurenceOfDay(day: Int) -> NSDate
    {
        let today = NSDate.today()
        var daysAhead = day - today.weekday
        
        if daysAhead < 0
        {
            daysAhead = daysAhead + 7
        }
        
        return today + daysAhead.day
    }
}