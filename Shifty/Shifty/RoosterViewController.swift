//
//  RoosterViewController.swift
//  Shifty
//
//  Created by Aron Hammond on 03/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//
//  Shows the user's personal schedule. This view shows all shifts owned
//  by the current user and shifts he/she accepted but still await approval. Also
//  all actions corresponding to these shifts can be performed from here by selecting 
//  the corresponding cell

import UIKit
import Parse

class RoosterViewController: ContentViewController
{
    // UIButton outlet for programmatic styling
    @IBOutlet weak var submitButton: UIButton!
    
    @IBAction func logOutCurrentRooster(sender: UIBarButtonItem)
    {
        helper.logOut(self)
    }

    override func viewDidLoad()
    {
        // display the current user's username in the navigation bar
        title = PFUser.currentUser()?.username
        
        // generate new shifts if needed
        rooster.updateSchedule()
        
        // set style of the submit button in de hidden view
        submitButton.layer.cornerRadius = 10
        submitButton.clipsToBounds = true
        
        super.viewDidLoad()
    }
    
    // actions on ActionSheet call getData() when the corresponding changes are saved, so the view can reload properly
    override func getData()
    {
        setActivityViewActive(true)
        rooster.requestShifts(Status.owned) { sections -> Void in
            self.refresh(sections)
        }
    }
}

extension RoosterViewController: ActionSheetDelegate
{
    // show UIAlerView that is created by a ActionSheet instance
    func showAlert(alertView: UIAlertController)
    {
        alertView.popoverPresentationController?.sourceView = self.view
        presentViewController(alertView, animated: true, completion: nil)
    }
}

extension RoosterViewController: UITableViewDataSource
{
    // set labels and highlighting for cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as UITableViewCell
        let shiftForCell = rooster.ownedShifts[indexPath.section][indexPath.row]
        
        cell.accessoryView = helper.createTimeLabel(shiftForCell.timeString)
        cell.textLabel!.text = shiftForCell.dateString
        
        switch shiftForCell.status
        {
            case Status.awaitting:          cell.backgroundColor = Highlight.awaitting
            case Status.awaittingFromSug:   cell.backgroundColor = Highlight.awaitting
            case Status.supplied:           cell.backgroundColor = Highlight.supplied
            case Status.suggested:          cell.backgroundColor = Highlight.supplied
            default: break
        }
        
        return cell
    }
}

extension RoosterViewController: UITableViewDelegate
{
    // an action sheet gets called depending on the status of the selected shift
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
    {
        let selectedShift = rooster.ownedShifts[indexPath.section][indexPath.row]
        let actionSheet = ActionSheet(shift: selectedShift, delegate: self, request: nil)
        
        // display day and time of selected shift in message label (eg. Mon 05 aug 18:00)
        var message = selectedShift.dateString + " " + selectedShift.timeString
        
        if selectedShift.status == Status.idle
        {
            actionSheet.includeActions([Action.supply, Action.delete])
        }
        if selectedShift.status == Status.awaitting && selectedShift.owner == PFUser.currentUser()
        {
            // alternative message
            message = selectedShift.acceptedBy!.username! + " wil jouw dienst overnemen."
            actionSheet.includeActions([Action.approve, Action.disapprove])
        }
        else if selectedShift.status == Status.awaitting && selectedShift.owner != PFUser.currentUser()
        {
            // alternative message
            message = "Je wil " + selectedShift.owner.username! + " zijn/haar dienst overnemen."
            actionSheet.includeActions([Action.approve, Action.disapprove])
        }
        if selectedShift.status == Status.supplied
        {
            actionSheet.includeActions([Action.revoke])
        }
        if selectedShift.status == Status.suggested
        {
            // alternative message
            message = "Je hebt deze dienst voorgesteld aan een collega"
        }
        if selectedShift.status == Status.awaittingFromSug
        {
            actionSheet.includeActions([Action.approveSug, Action.disapproveSug])
        }
        
        let alertController = actionSheet.getAlertController()
        
        alertController.message = message
        alertController.popoverPresentationController?.sourceView = self.view
        self.presentViewController(alertController, animated: true, completion: nil)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        return indexPath
    }
}
