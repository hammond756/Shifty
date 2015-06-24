//
//  RoosterViewController.swift
//  Shifty
//
//  Created by Aron Hammond on 03/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import UIKit
import Parse

class RoosterViewController: ShiftControllerInterface, ActionSheetDelegate
{
    @IBOutlet weak var submitButton: UIButton!
    
    @IBAction func goToSubmitView()
    {
        performSegueWithIdentifier("Submit Rooster", sender: nil)
    }
    
    override func viewDidLoad()
    {
        // display the current user's username in the navigation bar
        title = PFUser.currentUser()?.username
        
        // set style of the submit button in de hidden view
        submitButton.layer.cornerRadius = 10
        submitButton.clipsToBounds = true
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        rooster.updateSchedule()
        super.viewWillAppear(animated)
    }
    
    // everything to do with the table view
    // an action sheet gets called depending on the status of the selected shift
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
    {
        let selectedShift = rooster.ownedShifts[indexPath.section][indexPath.row]
        let actionSheet = ActionSheet(shift: selectedShift, delegate: self, request: nil)
        var message = "Wat ga je hiermee doen?"
        
        if selectedShift.status == "idle"
        {
            actionSheet.includeActions(["Supply", "Delete"])
        }
        if selectedShift.status == "Awaitting Approval" && selectedShift.owner == PFUser.currentUser()
        {
            message = selectedShift.acceptedBy!.username! + " wil jouw dienst overnemen."
            actionSheet.includeActions(["Approve", "Disapprove"])
        }
        else if selectedShift.status == "Awaitting Approval" && selectedShift.owner != PFUser.currentUser()
        {
            message = "Je wil " + selectedShift.owner.username! + " zijn/haar dienst overnemen."
            actionSheet.includeActions(["Approve", "Disapprove"])
        }
        if selectedShift.status == "Supplied"
        {
            actionSheet.includeActions(["Revoke"])
        }
        if selectedShift.status == "Suggested"
        {
            message = "Je hebt deze dienst voorgesteld aan een collega"
        }
        if selectedShift.status == "Awaitting Approval, sug"
        {
            actionSheet.includeActions(["Approve Suggestion"])
        }
        
        let alertController = actionSheet.getAlertController()
        alertController.message = message
        alertController.popoverPresentationController?.sourceView = self.view
        self.presentViewController(alertController, animated: true, completion: nil)
        
        return indexPath
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as UITableViewCell
        let shiftForCell = rooster.ownedShifts[indexPath.section][indexPath.row]
        
        cell.accessoryView = helper.createTimeLabel(shiftForCell.timeString)
        cell.textLabel!.text = shiftForCell.dateString
        
        switch shiftForCell.status
        {
        case "Supplied": cell.backgroundColor = UIColor(red: 255.0/255.0, green: 119.0/255.0, blue: 80.0/255.0, alpha: 1.0)
        case "Awaitting Approval": cell.backgroundColor = UIColor(red: 255.0/255.0, green: 208.0/255.0, blue: 50.0/255.0, alpha: 1.0)
        case "Awaitting Approval, sug": cell.backgroundColor = UIColor(red: 255.0/255.0, green: 208.0/255.0, blue: 50.0/255.0, alpha: 1.0)
        case "Suggested": cell.backgroundColor = UIColor(red: 255.0/255.0, green: 119.0/255.0, blue: 80.0/255.0, alpha: 1.0)
        default: break
        }
        
        return cell
        
    }
    
    func showAlert(alertView: UIAlertController)
    {
        alertView.popoverPresentationController?.sourceView = self.view
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    // actions on action sheet call refresh when they are done, so the view can reload properly
    func getData()
    {
        switchStateOfActivityView(true)
        rooster.requestShifts("Owned") { sections -> Void in
            self.refresh(sections)
        }
    }
    
    @IBAction func logOutCurrentRooster(sender: UIBarButtonItem)
    {
        helper.logOut(self)
    }
}
