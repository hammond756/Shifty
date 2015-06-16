//
//  SelectRequestsViewController.swift
//  Shifty
//
//  Created by Aron Hammond on 16/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import UIKit
import SwiftDate

class SelectRequestsViewController: UITableViewController
{
    let amountOfDaysAhead = 31
    var sectionsInTable = [String]()
    var possibleDates = [NSDate]()
    var sectionedDates = [[NSDate]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        possibleDates = getDates()
        sectionsInTable = getSections(possibleDates)
        sectionedDates = splitDatesIntoSections(possibleDates)
        
        tableView.reloadData()
        
    }
    
    func getDates() -> [NSDate]
    {
        let today = NSDate()
        var comingDays = [NSDate]()
        
        for days in 0...amountOfDaysAhead
        {
            comingDays.append(today + days.day)
        }
        println("comingdays")
        println(comingDays)
        return comingDays
    }
    
    func getSections(dates: [NSDate]) -> [String]
    {
        var sections = [String]()
        
        for date in dates
        {
            if !contains(sections, getWeekOfYear(date))
            {
                sections.append(getWeekOfYear(date))
            }
        }
        println("sections")
        println(sections)
        
        return sections
    }
    
    private func splitDatesIntoSections(dates: [NSDate]) -> ([[NSDate]])
    {
        var newDateArray = [[NSDate]]()
        
        for i in 0..<sectionsInTable.count
        {
            newDateArray.append(getSectionItems(dates, section: i))
        }
        println("new array")
        println(newDateArray)
        return newDateArray
    }
    
    func getSectionItems(dates: [NSDate], section: Int) -> [NSDate]
    {
        var datesInSection = [NSDate]()
        
        for date in dates
        {
            if getWeekOfYear(date) == sectionsInTable[section]
            {
                datesInSection.append(date)
            }
        }
        println("dates in sect")
        println(datesInSection)
        return datesInSection
    }
    
    func getWeekOfYear(date: NSDate) -> String
    {
        return "Week " + String(((date - 1.day).weekOfYear))
    }
    
    // tableView delegate fuctions
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return sectionedDates[section].count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return sectionsInTable[section]
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionedDates.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Date", forIndexPath: indexPath) as! UITableViewCell
        
        let date = sectionedDates[indexPath.section][indexPath.row]
        
        cell.textLabel?.text = date.toString(format: DateFormat.Custom("EEEE dd MMM"))
        
        return cell
    }
    
}
