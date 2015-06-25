//
//  SelectRequestsViewController.swift
//  Shifty
//
//  Created by Aron Hammond on 16/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//
//  To make requests on the GezochtView, user's have to select one or more dates
//  from a UITableView. The table view only shows dates that are not yet requested
//  by the current user and on which he/she does not yet work.

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

class SelectRequestsViewController: ShiftControllerInterface
{
    let amountOfDaysToGenerate = 31

    var sectionedDates = [[NSDate]]()
    var selectedDates = [NSDate]()
    var previousRequests = [NSDate]()
        
    override func viewDidLoad()
    {
        switchStateOfActivityView(true)
        showOptionsForCurrentUser()
        super.viewDidLoad()
    }
    
    // create Requests objects in parse (from selected dates)
    @IBAction func finishedSelecting(sender: UIBarButtonItem)
    {
        for (i,date) in enumerate(selectedDates)
        {
            let request = PFObject(className: ParseClass.requests)
            request[ParseKey.date] = date
            request[ParseKey.requestedBy] = PFUser.currentUser()
            
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
    
    // get requests made by current user
    func getUserRequests(callback: [NSDate] -> Void)
    {
        var previousRequests = [NSDate]()
        let query = PFQuery(className: ParseClass.requests)
        query.whereKey(ParseKey.requestedBy, equalTo: PFUser.currentUser()!)
        query.findObjectsInBackgroundWithBlock() { (objects: [AnyObject]?, error: NSError?) -> Void in
            if let requests = self.helper.returnObjectAfterErrorCheck(objects, error: error) as? [PFObject]
            {
                for request in requests
                {
                    let date = request[ParseKey.date] as! NSDate
                    previousRequests.append(date)
                }
                callback(previousRequests)
            }
        }
    }
    
    // call getUserRuests, feed result into getPossibleDates, section dates and dispaly
    func showOptionsForCurrentUser()
    {
        getUserRequests() { dates -> Void in
            self.getPossibleDates(dates) { possibleDates -> Void in
                self.sectionsInTable = self.helper.getSections(possibleDates)
                self.sectionedDates = self.helper.splitIntoSections(possibleDates, sections: self.sectionsInTable)
                self.tableView.reloadData()
                self.switchStateOfActivityView(false)
            }
        }
    }
    
    // check for amountOfDaysToGenerate days if it is relevant for the user to request
    func getPossibleDates(previousRequests: [NSDate], callback: (possibleDates: [NSDate]) -> Void)
    {
        let today = NSDate()
        var possibleDates = [NSDate]()
        let alreadySubmitted = previousRequests.map() { String($0.day) + String($0.month) }
        
        for days in 0..<amountOfDaysToGenerate
        {
            let date = today + days.day
            helper.checkIfDateIsTaken(date) { taken -> Void in
                let check = String(date.day) + String(date.month)
                
                if !taken && !contains(alreadySubmitted, check)
                {
                    possibleDates.append(date)
                }
                if days == self.amountOfDaysToGenerate - 1
                {
                    callback(possibleDates: possibleDates)
                }
            }
        }
    }
}

extension SelectRequestsViewController: UITableViewDataSource
{
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return sectionedDates[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as UITableViewCell
        let dateForCell = sectionedDates[indexPath.section][indexPath.row]
        
        cell.textLabel?.text = dateForCell.toString(format: DateFormat.Custom("EEEE dd MMM"))
        
        return cell
    }
}

extension SelectRequestsViewController: UITableViewDelegate
{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let selectedDate = sectionedDates[indexPath.section][indexPath.row]
        selectedDates.append(selectedDate)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath)
    {
        let deselectedDate = sectionedDates[indexPath.section][indexPath.row]
        
        if let index = find(selectedDates, deselectedDate)
        {
            selectedDates.removeAtIndex(index)
        }
    }
}