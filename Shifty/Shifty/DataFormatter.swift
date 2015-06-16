//
//  DataFormatter.swift
//  Shifty
//
//  Created by Aron Hammond on 16/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

//import Foundation
//import SwiftDate
//
//class DataFormatter
//{
//    func getSections(dates: [NSDate]) -> [String]
//    {
//        var sections = [String]()
//        
//        for date in dates
//        {
//            if !contains(sections, getWeekOfYear(date))
//            {
//                sections.append(getWeekOfYear(date))
//            }
//        }
//        
//        return sections
//    }
//    
//    func getSectionItems(dates: [NSDate], section: Int) -> [NSDate]
//    {
//        var datesInSection = [NSDate]()
//        
//        for date in dates
//        {
//            if getWeekOfYear(date) == sectionsInTable[section]
//            {
//                datesInSection.append(date)
//            }
//        }
//        
//        return datesInSection
//    }
//    
//    
//    func getWeekOfYear(date: NSDate) -> String
//    {
//        return "Week " + String(((date - 1.day).weekOfYear))
//    }
//}
