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

class AangebodenViewController: UITableViewController, ActionSheetDelegate
{
    var sectionsInTable = [String]()
    let rooster = Rooster()
    let helper = Helper()
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        refresh()
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
        cell.accessoryView = helper.createTimeLabel(time)
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
        let actionSheet = ActionSheet(shift: selectedShift, delegate: self)
        
        if selectedShift.owner != PFUser.currentUser()
        {
            actionSheet.includeActions(["Accept"])
        }
        
        let alertController = actionSheet.getAlertController()
        alertController.popoverPresentationController?.sourceView = self.view
        presentViewController(alertController, animated: true, completion: nil)
        
        return indexPath
    }
    
    func refresh()
    {
        rooster.requestShifts("Supplied") { sections -> Void in
            self.sectionsInTable = sections
            self.tableView.reloadData()
        }
    }
    
    // log out
    @IBAction func logOutCurrentUser(sender: UIBarButtonItem)
    {
        helper.logOut(self)
    }
}
