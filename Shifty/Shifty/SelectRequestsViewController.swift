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
    func getWeekOfYear() -> String
    {
        return "Week " + String((self - 1.day).weekOfYear)
    }
    
    var date: NSDate { get { return self } }
}

class SelectRequestsViewController: UITableViewController
{
    let amountOfDaysToGenerate = 31
    var sectionsInTable = [String]()
    var possibleDates = [NSDate]()
    var sectionedDates = [[NSDate]]()
    var selectedDates = [NSDate]()
    var previousRequests = [NSDate]()
    
    let rooster = Rooster()
    let helper = Helper()
        
    override func viewDidLoad()
    {
        showOptionsForCurrentUser()
        super.viewDidLoad()
    }
    
    @IBAction func finishedSelecting(sender: UIBarButtonItem)
    {
        println(selectedDates)
        for (i,date) in enumerate(selectedDates)
        {
            let request = PFObject(className: "RequestedShifts")
            request["date"] = date
            request["requestedBy"] = PFUser.currentUser()
            
            request.saveInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                
                if error != nil
                {
                    println(error?.description)
                }
                else if succes && i == self.selectedDates.count - 1
                {
                    self.navigationController?.popViewControllerAnimated(false)
                }
            }
        }
    }
    
    func getDates()
    {
        let today = NSDate()
        let alreadySubmitted = previousRequests.map() { String($0.day) + String($0.month) }
        
        for days in 0..<amountOfDaysToGenerate
        {
            let date = today + days.day
            let check = String(date.day) + String(date.month)

            if !contains(alreadySubmitted, check)
            {
                possibleDates.append(date)
            }
        }
    }
    
    func showOptionsForCurrentUser()
    {
        let query = PFQuery(className: "RequestedShifts")
        query.whereKey("requestedBy", equalTo: PFUser.currentUser()!)
        query.findObjectsInBackgroundWithBlock() { (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if let requests = self.helper.returnObjectAfterErrorCheck(objects, error: error) as? [PFObject]
            {
                for request in requests
                {
                    let date = request["date"] as! NSDate
                    self.previousRequests.append(date)
                }
            }
            
            self.getDates()
            self.sectionsInTable = self.helper.getSections(self.possibleDates)
            self.sectionedDates = self.helper.splitIntoSections(self.possibleDates, sections: self.sectionsInTable)
            self.tableView.reloadData()
        }
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
        println("Selected \(selectedDate)")
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath)
    {
        let deselectedDate = sectionedDates[indexPath.section][indexPath.row]
        
        if let index = find(selectedDates, deselectedDate)
        {
            selectedDates.removeAtIndex(index)
            println(deselectedDate)
        }
    }
    
}
