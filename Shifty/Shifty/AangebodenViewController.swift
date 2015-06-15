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

class AangebodenViewController: UITableViewController
{
    var suppliedShifts = [Shift]()
    var sectionsInTable = [String]()
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        requestSuppliedShifts()
    }
    
    func getSections(shifts: [Shift])
    {
        sectionsInTable = []
        
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
        let owner = object["Owner"] as? PFUser
        
        return Shift(date: date!, stat: status!, objectID: object.objectId!, owner: owner!)
    }
    
    private func getSectionItems(section: Int) -> [Shift]
    {
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
        
        cell.backgroundColor = UIColor.clearColor()
        
        let shiftForCell = getSectionItems(indexPath.section)[indexPath.row]
        let date = shiftForCell.dateString
        let time = shiftForCell.timeString
                
        cell.textLabel?.text = date
        cell.accessoryView = createTimeLabel(time)
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
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
    {
        let selectedShift = getSectionItems(indexPath.section)[indexPath.row]
        callActionSheet(selectedShift)
        
        return indexPath
    }
    
    private func callActionSheet(selectedShift: Shift)
    {
        let actionSheetController = UIAlertController()
        
        let acceptAction = UIAlertAction(title: "Accepteren", style: .Default) { action -> Void in
            
            let query = PFQuery(className: "Shifts")
            
            query.getObjectInBackgroundWithId(selectedShift.objectID) { (shift: PFObject?, error: NSError? ) -> Void in
                
                if error != nil
                {
                    println(error?.description)
                }
                else if let shift = shift
                {
                    shift["Status"] = "Awaitting Approval"
                    shift["acceptedBy"] = PFUser.currentUser()
                    shift.saveInBackgroundWithBlock() { (succes, error) -> Void in
                        
                        if error != nil
                        {
                            println(error?.description)
                        }
                        else
                        {
                            let index = find(self.suppliedShifts, selectedShift)
                            self.suppliedShifts.removeAtIndex(index!)
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Annuleren", style: .Cancel) { action -> Void in
            
            actionSheetController.dismissViewControllerAnimated(true, completion: nil)
        }
        
        if selectedShift.owner != PFUser.currentUser()
        {
            actionSheetController.addAction(acceptAction)
        }
        
        actionSheetController.addAction(cancelAction)
        actionSheetController.popoverPresentationController?.sourceView = self.view
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
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

    @IBAction func logOutCurrentUser(sender: UIBarButtonItem)
    {
        PFUser.logOut()
        
        let loginViewController = self.storyboard!.instantiateViewControllerWithIdentifier("Login") as! LogInViewController
        UIApplication.sharedApplication().keyWindow?.rootViewController = loginViewController
    }
}
