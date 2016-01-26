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

// extension to have NSDate conform to HasDate (duh..)
extension NSDate: HasDate
{
    func getWeekOfYear() -> String
    {
        return "Week " + String(self.weekOfYear)
    }
    
    var date: NSDate { get { return self } }
}

class SelectRequestsViewController: ContentViewController
{
    var sectionedDates = [[NSDate]]()
    var selectedDates = [NSDate]()
    
    override func viewDidLoad()
    {
        setActivityViewActive(true)
        showOptionsForCurrentUser()
        super.viewDidLoad()
    }
    
    // create Requests objects in parse (from selected dates) and pop viewcontroller
    @IBAction func finishedSelecting(sender: UIBarButtonItem)
    {
        for (i,date) in selectedDates.enumerate()
        {
            let request = PFObject(className: ParseClass.requests)
            request[ParseKey.date] = date
            request[ParseKey.requestedBy] = PFUser.currentUser()
            
            request.saveInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                if error != nil
                {
                    print(error?.description)
                }
                else if succes && i == self.selectedDates.count - 1
                {
                    self.navigationController?.popViewControllerAnimated(true)
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
    
    // check for Constant.amountOfDaysToGenerate days if it is relevant for the user to request
    func getPossibleDates(previousRequests: [NSDate], callback: (possibleDates: [NSDate]) -> Void)
    {
        let today = NSDate()
        var possibleDates = [NSDate]()
        let alreadySubmitted = previousRequests.map() { String($0.day) + String($0.month) }
        
        for days in 0..<Constant.amountOfDaysToGenerate
        {
            let date = today + days.day
            helper.checkIfDateIsTaken(date) { taken -> Void in
                let check = String(date.day) + String(date.month)
                
                if !taken && !alreadySubmitted.contains(check)
                {
                    possibleDates.append(date)
                }
                if days == Constant.amountOfDaysToGenerate - 1
                {
                    callback(possibleDates: possibleDates)
                }
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
                self.setActivityViewActive(false)
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
        cell.selectionStyle = .Default
        
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
        
        if let index = selectedDates.indexOf(deselectedDate)
        {
            selectedDates.removeAtIndex(index)
        }
    }
}