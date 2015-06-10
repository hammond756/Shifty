//
//  RoosterViewController.swift
//  Shifty
//
//  Created by Aron Hammond on 03/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import UIKit
import Parse
import SWTableViewCell

class RoosterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    
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
        requestFixedRooster()
        submitButton.layer.cornerRadius = 10
        submitButton.clipsToBounds = true
        
    }
    
    func requestFixedRooster()
    {
        var currentUser = PFUser.currentUser()
        let userID = currentUser?.objectId
        let query = PFQuery(className: "Shifts")
        query.whereKey("Owner", equalTo: userID!)
        
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            
            
            if error == nil
            {
                if let objects = objects as? [PFObject]
                {
                    if objects.count == 0
                    {
                        self.tableView.hidden = true
                    }
                    else
                    {
                        self.tableView.hidden = false
                    }
                    
                    for object in objects
                    {
                        let date = object["Date"] as? NSDate
                        let status = object["Status"] as? String
                        let objectID = object.objectId
                        let shift = Shift(date: date!, stat: status!, objectID: objectID!)
                        
                        self.shifts.append(shift)

                    }
                    
                    self.shifts.sort() { $0.dateObject < $1.dateObject }
                    println(self.shifts.count)
                    self.getSections(self.shifts)
                    self.tableView.reloadData()
                }
            }
            
        }
        
    }
    
    // everything to do with the table view
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return getSectionItems(section).count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if shifts.count == 0
        {
            self.tableView.hidden = true
        }
        else
        {
            self.tableView.hidden = false
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Shift", forIndexPath: indexPath) as! UITableViewCell
        cell.backgroundColor = UIColor.clearColor()
        let sectionItems = getSectionItems(indexPath.section)
        
        var timeLabel = UILabel()
        timeLabel.font = UIFont.systemFontOfSize(14)
        timeLabel.textAlignment = NSTextAlignment.Center
        timeLabel.text = sectionItems[indexPath.row].timeString
        timeLabel.sizeToFit()
        
        cell.textLabel?.text = sectionItems[indexPath.row].dateString
        cell.accessoryView = timeLabel
        cell.textLabel?.textAlignment = NSTextAlignment.Center
        
        if sectionItems[indexPath.row].status == "Supplied"
        {
            cell.backgroundColor = UIColor.orangeColor()
        }
        
        return cell
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
        
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?
    {
        var supplyAction = UITableViewRowAction(style: .Normal, title: "->") { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            
            let swipedShift = self.getSectionItems(indexPath.section)[indexPath.row]
            println(swipedShift.dateString)
            
            let query = PFQuery(className: "Shifts")
            query.getObjectInBackgroundWithId(swipedShift.objectID) { (shift: PFObject?, error: NSError?) -> Void in
                if error != nil
                {
                    println(error)
                }
                else if let shift = shift
                {
                    shift["Status"] = "Supplied"
                    shift.saveInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                        if succes
                        {
                            self.tableView.reloadData()
                        }
                        else
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
