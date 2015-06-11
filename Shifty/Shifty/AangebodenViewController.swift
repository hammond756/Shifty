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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        requestSuppliedShifts()
    }
    
    func getSections(shifts: [Shift])
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
    
    func requestSuppliedShifts()
    {
        let query = PFQuery(className: "Shifts")
            .whereKey("Status", equalTo: "Supplied")
        
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error != nil
            {
                println(error?.description)
            }
            
            if let objects = objects as? [PFObject]
            {
//                let shiftIDs = self.suppliedShifts.map { (let shift) -> String in
//                    return shift.objectID
//                }
//                
//                let setWithIDs = NSSet(array: shiftIDs)
//                
//                for object in objects
//                {
//                    let shift = self.convertParseObjectToShift(object)
//                    
//                    if !setWithIDs.containsObject(shift.objectID)
//                    {
//                        self.suppliedShifts.append(shift)
//                    }
//
                self.suppliedShifts.removeAll(keepCapacity: true)
                
                for object in objects
                {
                    let shift = self.convertParseObjectToShift(object)
                    self.suppliedShifts.append(shift)
                }
                
                self.suppliedShifts.sort() { $0.dateObject < $1.dateObject }
                
                self.getSections(self.suppliedShifts)
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

            let query = PFQuery(className: "Shifts")
            query.getObjectInBackgroundWithId(swipedShift.objectID) { (shift: PFObject?, error: NSError?) -> Void in
                if error != nil
                {
                    println(error?.description)
                }
                else if let shift = shift
                {
                    shift["Status"] = "Awaitting Approval"
                    shift["acceptedBy"] = PFUser.currentUser()
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
