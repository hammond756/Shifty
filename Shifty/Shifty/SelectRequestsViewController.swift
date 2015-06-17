//
//  SelectRequestsViewController.swift
//  Shifty
//
//  Created by Aron Hammond on 16/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import UIKit
import SwiftDate
import Parse

class SelectRequestsViewController: UITableViewController
{
    let amountOfDaysToGenerate = 31
    var sectionsInTable = [String]()
    var possibleDates = [NSDate]()
    var sectionedDates = [[NSDate]]()
    var selectedDates = [NSDate]()
        
    override func viewDidLoad()
    {
        possibleDates = getDates()
        sectionsInTable = getSections(possibleDates)
        sectionedDates = splitDatesIntoSections(possibleDates)

        tableView.reloadData()
        super.viewDidLoad()
    }
    
    @IBAction func finishedSelecting(sender: UIBarButtonItem)
    {
        for date in selectedDates
        {
            let request = PFObject(className: "RequestedShifts")
            request["date"] = date
            request["requestedBy"] = PFUser.currentUser()
            
            request.saveInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                
                if error != nil
                {
                    println(error?.description)
                }
                else if succes
                {
                    self.navigationController?.popViewControllerAnimated(false)
                }
            }
        }
    }
    
    func getDates() -> [NSDate]
    {
        let today = NSDate()
        var comingDays = [NSDate]()
        
        for days in 0..<amountOfDaysToGenerate
        {
            comingDays.append(today + days.day)
        }

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

        return sections
    }
    
    private func splitDatesIntoSections(dates: [NSDate]) -> [[NSDate]]
    {
        var newDateArray = [[NSDate]]()
        
        for i in 0..<sectionsInTable.count
        {
            newDateArray.append(getSectionItems(dates, section: i))
        }

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
        cell.textLabel?.textAlignment = NSTextAlignment.Center
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let selectedDate = sectionedDates[indexPath.section][indexPath.row]
        selectedDates.append(selectedDate)
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath)
    {
        let deselectedDate = sectionedDates[indexPath.section][indexPath.row]
        
        if let index = find(selectedDates, deselectedDate)
        {
            selectedDates.removeAtIndex(index)
        }
    }
    
}
