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
    
    func addRecurringShift(day: String, hour: Int, minute: Int)
    {
        println("entered bla")
        let dayDict = ["Maandag": 2, "Dinsdag": 3, "Woensdag": 4, "Donderdag": 5, "Vrijdag": 6, "Zaterdag:": 7, "Zondag": 1]
        
        var firstOccurrenceDate = nextOccurenceOfDay(dayDict[day]!).set(componentsDict: ["hour": hour, "minute": minute])
        
        for week in 0..<amountOfRecurringWeeks
        {
            let date = firstOccurrenceDate! + (7 * week).day
            println("bla")
            recurringShifts.append(Shift(date: date))
        }
        
    }
    
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
}