//
//  AangebodenViewController.swift
//  Shifty
//
//  Created by Aron Hammond on 01/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import UIKit
import Parse
import SwiftDate

class AangebodenViewController: UITableViewController {

    var suppliedShifts: [Shift] = []
    var sectionsInTable = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestSuppliedShifts()
    }
    
    func getSections(shifts: [Shift])
    {
        println("getting sections")
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
    
    func requestSuppliedShifts()
    {
        println("Request supplied")
        var query = PFQuery(className: "Shifts")
        query.whereKey("Status", equalTo: "Supplied")
        
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil
            {
                println("no error")
                if let objects = objects as? [PFObject]
                {
                    println("objects as pfobject")
                    println(objects.count)
                    for object in objects
                    {
                        let date = object["Date"] as! NSDate
                        let objectID = object.objectId
                        let status = object["Status"] as! String
                        
                        println("Appending")
                        self.suppliedShifts.append(Shift(date: date, stat: status, objectID: objectID!))
                    }
                    
                    self.suppliedShifts.sort() { $0.dateObject < $1.dateObject }

                    self.getSections(self.suppliedShifts)
                    self.tableView.reloadData()

                }
            }
            else
            {
                println(error?.description)
            }
        }
    }
    
    func getSectionItems(section: Int) -> [Shift]
    {
        println("getting section items")
        var sectionItems = [Shift]()
        
        for shift in suppliedShifts
        {
            if shift.getWeekOfYear() == sectionsInTable[section]
            {
                sectionItems.append(shift)
            }
        }
        
        return sectionItems
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return getSectionItems(section).count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Shift", forIndexPath: indexPath) as! UITableViewCell
        let sectionItems = getSectionItems(indexPath.section)
        
        var timeLabel = UILabel()
        timeLabel.font = UIFont.systemFontOfSize(14)
        timeLabel.textAlignment = NSTextAlignment.Center
        timeLabel.text = sectionItems[indexPath.row].timeString
        timeLabel.sizeToFit()
        
        cell.textLabel?.text = sectionItems[indexPath.row].dateString
        cell.accessoryView = timeLabel
        cell.textLabel?.textAlignment = NSTextAlignment.Center
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return sectionsInTable[section]
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return sectionsInTable.count
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?
    {
        var supplyAction = UITableViewRowAction(style: .Normal, title: "✓") { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            
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
                    shift["Status"] = "Awaitting Approval"
                    shift.saveInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                        
                        succes ? self.tableView.reloadData() : println(error?.description)
                    }
                    
                }
            }
        }
        
        supplyAction.backgroundColor = UIColor.greenColor()
        
        return [supplyAction]
    }

}
