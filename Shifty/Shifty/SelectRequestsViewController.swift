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

extension NSDate: HasDate
{
    func getWeekOfYear() -> String {
        return "Week: " + String(self.weekOfYear)
    }
    
    var date: NSDate { get { return self } set { self.date = newValue } }
}

class SelectRequestsViewController: UITableViewController
{
    let amountOfDaysToGenerate = 31
    var sectionsInTable = [String]()
    var possibleDates = [NSDate]()
    var sectionedDates = [[NSDate]]()
    var selectedDates = [NSDate]()
    
    let rooster = Rooster()
        
    override func viewDidLoad()
    {
        possibleDates = getDates()
        sectionsInTable = rooster.getSections(possibleDates)
        sectionedDates = rooster.splitIntoSections(possibleDates, sections: sectionsInTable)

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
