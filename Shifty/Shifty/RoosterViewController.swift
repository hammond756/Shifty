//
//  RoosterViewController.swift
//  Shifty
//
//  Created by Aron Hammond on 03/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import UIKit
import Parse

class RoosterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    
    var refreshControl: UIRefreshControl!
    let rooster = Rooster()
    var shifts: [Shift] = []
    var sectionsInTable = [String]()
    
    @IBAction func goToSubmitView()
    {
        performSegueWithIdentifier("Submit Rooster", sender: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        submitButton.layer.cornerRadius = 10
        submitButton.clipsToBounds = true
        
        requestPersonalSchedule()
    }
    
    func refresh(sender:AnyObject)
    {
        requestPersonalSchedule()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func requestPersonalSchedule()
    {
        let userID = PFUser.currentUser()?.objectId
        
        let query = PFQuery(className: "Shifts")
            .whereKey("Owner", equalTo: userID!)
        
        var shifts = [Shift]()
        
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error != nil
            {
                println(error?.description)
            }
            
            if let objects = objects as? [PFObject]
            {
                objects.count == 0 ? (self.tableView.hidden = true) : (self.tableView.hidden = false)
                
                let shiftIDs = self.shifts.map { (let shift) -> String in
                    return shift.objectID
                }
                
                let setIDs = NSSet(array: shiftIDs)
                
                for object in objects
                {
                    let shift = self.convertParseObjectToShift(object)
                    
                    if !setIDs.containsObject(shift.objectID)
                    {
                        self.shifts.append(shift)
                    }
                }
                
                self.shifts.sort { $0.dateObject < $1.dateObject }
                self.getSections(self.shifts)
                self.tableView.reloadData()
            }
            
        }
    }
    
    private func convertParseObjectToShift(object: PFObject) -> Shift
    {
        let date = object["Date"] as? NSDate
        let status = object["Status"] as? String
        
        return Shift(date: date!, stat: status!, objectID: object.objectId!)
    }
    
    // everything to do with the table view
    
    // generete the section headers of the table view (week numbers)
    private func getSections(shifts: [Shift])
    {
        for shift in shifts
        {
            let weekOfYear = shift.getWeekOfYear()
            let sections = NSSet(array: sectionsInTable)
            
            if !sections.containsObject(weekOfYear)
            {
                sectionsInTable.append(weekOfYear)
            }
        }
    }
    
    // split the shifts up into their corresponding sections
    private func getSectionItems(section: Int) -> [Shift]
    {
        var sectionItems = [Shift]()
        
        for shift in shifts
        {
            if shift.getWeekOfYear() == sectionsInTable[section]
            {
                sectionItems.append(shift)
            }
        }
        
        return sectionItems
    }
    
    // get number of rows for a section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return getSectionItems(section).count
    }
    
    // generate (reuse) cell.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        shifts.count == 0 ? (tableView.hidden = true) : (tableView.hidden = false)
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Shift", forIndexPath: indexPath) as! UITableViewCell
        
        cell.backgroundColor = UIColor.clearColor()
        
        let sectionItems = getSectionItems(indexPath.section)
        let shift = sectionItems[indexPath.row]
        let date = shift.dateString
        let time = shift.timeString
        
        cell.textLabel?.text = date
        cell.accessoryView = createTimeLabel(time)
        cell.textLabel?.textAlignment = NSTextAlignment.Center
        
        switch sectionItems[indexPath.row].status
        {
            case "Supplied": cell.backgroundColor = UIColor.redColor()
            case "Awaitting Approval": cell.backgroundColor = UIColor.orangeColor()
            case "Approved": cell.backgroundColor = UIColor.greenColor()
        default: break
        }
        
        return cell
    }
    
    private func createTimeLabel(time: String) -> UILabel
    {
        var label = UILabel()
        label.font = UIFont.systemFontOfSize(14)
        label.textAlignment = NSTextAlignment.Center
        label.text = time
        label.sizeToFit()
        
        return label
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return sectionsInTable[section]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return sectionsInTable.count
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        // Empty, but is required
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?
    {
        var supplyAction = UITableViewRowAction(style: .Normal, title: "->") { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            
            var swipedShift = self.getSectionItems(indexPath.section)[indexPath.row]
            swipedShift.status = "Supplied"
            
            let query = PFQuery(className: "Shifts")
            query.getObjectInBackgroundWithId(swipedShift.objectID) { (shift: PFObject?, error: NSError?) -> Void in
                if error != nil
                {
                    println(error?.description)
                }
                else if let shift = shift
                {
                    shift["Status"] = "Supplied"
                    shift.saveInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                        if error != nil
                        {
                            println(error?.description)
                        }
                    }
                }
            }
        }
        
        supplyAction.backgroundColor = UIColor.orangeColor()
        
        return [supplyAction]
    }
    
}
