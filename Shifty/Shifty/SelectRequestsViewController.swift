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

class SelectRequestsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    let amountOfDaysToGenerate = 31
    var sectionsInTable = [String]()
    var sectionedDates = [[NSDate]]()
    var selectedDates = [NSDate]()
    var previousRequests = [NSDate]()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var tableView: UITableView!
    let rooster = Rooster()
    let helper = Helper()
        
    override func viewDidLoad()
    {
        activityIndicator.startAnimating()
        showOptionsForCurrentUser()
        super.viewDidLoad()
    }
    
    @IBAction func finishedSelecting(sender: UIBarButtonItem)
    {
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
    
    func getDates(callback: (possibleDates: [NSDate]) -> Void)
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
            
            self.getDates() { possibleDates -> Void in
                self.sectionsInTable = self.helper.getSections(possibleDates)
                self.sectionedDates = self.helper.splitIntoSections(possibleDates, sections: self.sectionsInTable)
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.activityView.hidden = true
            }
            
        }
    }
    // tableView delegate fuctions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return sectionedDates[section].count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return sectionsInTable[section]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionedDates.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Date", forIndexPath: indexPath) as! UITableViewCell
        
        let date = sectionedDates[indexPath.section][indexPath.row]
        
        cell.textLabel?.text = date.toString(format: DateFormat.Custom("EEEE dd MMM"))
        cell.textLabel?.textAlignment = NSTextAlignment.Center
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let selectedDate = sectionedDates[indexPath.section][indexPath.row]
        selectedDates.append(selectedDate)
        println("Selected \(selectedDate)")
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath)
    {
        let deselectedDate = sectionedDates[indexPath.section][indexPath.row]
        
        if let index = find(selectedDates, deselectedDate)
        {
            selectedDates.removeAtIndex(index)
            println(deselectedDate)
        }
    }
    
}
