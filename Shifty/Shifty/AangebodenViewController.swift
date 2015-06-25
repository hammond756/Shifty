//
//  AangebodenViewController.swift
//  Shifty
//
//  Created by Aron Hammond on 01/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//
//  The 'marketplace'. Shift that are supplied by users appear here. Others
//  can accept these if they want to work that shift.

import UIKit
import Parse
import SwiftDate

class AangebodenViewController: ShiftControllerInterface
{
    @IBAction func logOutCurrentUser(sender: UIBarButtonItem)
    {
        helper.logOut(self)
    }
    
    // update data when view appears to stay up to date with database
    override func viewWillAppear(animated: Bool)
    {
        getData()
        super.viewWillAppear(animated)
    }
    
    // actions on ActionSheet call getData() when the corresponding changes are saved, so the view can reload properly
    func getData()
    {
        switchStateOfActivityView(true)
        rooster.requestShifts(Status.supplied) { sections -> Void in
            self.refresh(sections)
        }
    }
}

extension AangebodenViewController: ActionSheetDelegate
{
    // show UIAlertView that is created by a ActionSheet instance
    func showAlert(alertView: UIAlertController)
    {
        alertView.popoverPresentationController?.sourceView = self.view
        presentViewController(alertView, animated: true, completion: nil)
    }
}

extension AangebodenViewController: UITableViewDataSource
{
    // information needs to come from another property than other ShiftControllerInterfaces
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return rooster.suppliedShifts[section].count
    }
    
    // set labels and highlighting for cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as UITableViewCell
        let shiftForCell = rooster.suppliedShifts[indexPath.section][indexPath.row]
        
        cell.textLabel?.text = shiftForCell.dateString
        cell.accessoryView = helper.createTimeLabel(shiftForCell.timeString)
        
        if shiftForCell.owner == PFUser.currentUser()
        {
            cell.backgroundColor = Highlight.supplied
        }
        
        return cell
    }
}

extension AangebodenViewController: UITableViewDelegate
{
    // calls an ActionSheet that handles actions for the shift at the indexPath
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
    {
        let selectedShift = rooster.suppliedShifts[indexPath.section][indexPath.row]
        let actionSheet = ActionSheet(shift: selectedShift, delegate: self, request: nil)
        
        // action depends on current user
        if selectedShift.owner != PFUser.currentUser()
        {
            actionSheet.includeActions([Action.accept])
        }
        else
        {
            actionSheet.includeActions([Action.revoke])
        }
        
        let alertController = actionSheet.getAlertController()
        alertController.popoverPresentationController?.sourceView = self.view
        presentViewController(alertController, animated: true, completion: nil)
        
        return indexPath
    }
}
