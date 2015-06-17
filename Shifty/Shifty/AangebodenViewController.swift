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
    var sectionsInTable = [String]()
    let rooster = Rooster()
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        rooster.requestShifts("Supplied") { (sections) -> Void in
            self.sectionsInTable = sections
            self.tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return rooster.suppliedShifts[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Shift", forIndexPath: indexPath) as! UITableViewCell
        
        cell.backgroundColor = UIColor.clearColor()
        
        let shiftForCell = rooster.suppliedShifts[indexPath.section][indexPath.row]
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
        let selectedShift = rooster.suppliedShifts[indexPath.section][indexPath.row]
        callActionSheet(selectedShift, atIndexPath: indexPath)
        
        return indexPath
    }
    
    private func callActionSheet(selectedShift: Shift, atIndexPath: NSIndexPath)
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
                            self.rooster.suppliedShifts[atIndexPath.section].removeAtIndex(atIndexPath.row)
                            self.rooster.requestShifts("Supplied") { (sections) -> Void in
                                
                                self.sectionsInTable = sections
                                self.tableView.reloadData()
                            }
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
    
    // set properties for the accessoryView of the tableViewCell
    private func createTimeLabel(time: String) -> UILabel
    {
        var label = UILabel()
        label.font = UIFont.systemFontOfSize(14)
        label.textAlignment = NSTextAlignment.Center
        label.text = time
        label.sizeToFit()
        
        return label
    }
    
    // log out
    @IBAction func logOutCurrentUser(sender: UIBarButtonItem)
    {
        PFUser.logOut()
        
        let loginViewController = self.storyboard!.instantiateViewControllerWithIdentifier("Login") as! LogInViewController
        UIApplication.sharedApplication().keyWindow?.rootViewController = loginViewController
    }
}
