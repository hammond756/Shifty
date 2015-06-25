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

class AangebodenViewController: ShiftControllerInterface, ActionSheetDelegate
{
    @IBAction func logOutCurrentUser(sender: UIBarButtonItem)
    {
        helper.logOut(self)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        getData()
        super.viewWillAppear(animated)
    }
    
    func getData()
    {
        switchStateOfActivityView(true)
        rooster.requestShifts(Status.supplied) { sections -> Void in
            self.refresh(sections)
        }
    }
    
    func showAlert(alertView: UIAlertController)
    {
        alertView.popoverPresentationController?.sourceView = self.view
        presentViewController(alertView, animated: true, completion: nil)
    }
}

extension AangebodenViewController: UITableViewDataSource
{
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return rooster.suppliedShifts[section].count
    }
    
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
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
    {
        let selectedShift = rooster.suppliedShifts[indexPath.section][indexPath.row]
        let actionSheet = ActionSheet(shift: selectedShift, delegate: self, request: nil)
        
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
