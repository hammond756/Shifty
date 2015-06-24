//
//  SuggestionOverviewViewController.swift
//  Shifty
//
//  Created by Aron Hammond on 18/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import UIKit
import Parse

class SuggestionOverviewViewController: ShiftControllerInterface, ActionSheetDelegate
{
    var suggestions = [Shift]()
    var requestID = ""
    var request: Request? = nil

    override func viewDidLoad()
    {
        refresh()
        let parseObject = PFQuery(className: "RequestedShifts").getObjectWithId(requestID)
        request = Request(parseObject: parseObject!)
        super.viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return suggestions.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as UITableViewCell
        let shiftForCell = suggestions[indexPath.row]
        
        cell.textLabel?.text = shiftForCell.dateString
        cell.accessoryView = helper.createTimeLabel(shiftForCell.timeString)
        
        if shiftForCell.status == "Awaitting Approval, sug"
        {
            cell.backgroundColor = UIColor(red: 255.0/255.0, green: 208.0/255.0, blue: 50.0/255.0, alpha: 1.0)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
    {
        let selectedShift = suggestions[indexPath.row]
        let actionSheet = ActionSheet(shift: selectedShift, delegate: self, request: requestID)
        
        if selectedShift.status == "Awaitting Approval, sug"
        {
            actionSheet.includeActions(["Approve Suggestion", "Disapprove Suggestion"])
        }
        else if selectedShift.status == "Suggested"
        {
            actionSheet.includeActions(["Accept Suggestion"])
        }
        
        let alertController = actionSheet.getAlertController()
        alertController.presentingViewController?.view = self.view
        presentViewController(alertController, animated: true, completion: nil)
        
        return indexPath
    }
    
    // BUG: doesn't remove objectID of accepted suggest from replies
    func getData()
    {
        switchStateOfActivityView(true)
        rooster.requestSuggestions(requestID) { suggestions -> Void in
            self.rooster.requestShiftsFromIDs(suggestions) { shifts -> Void in
                self.suggestions = shifts
                shifts.count == 0 ? (self.tableView.hidden = true) : (self.tableView.hidden = false)
                self.tableView.reloadData()
                self.switchStateOfActivityView(false)
            }
        }
    }
    
    func popViewController()
    {
        navigationController?.popViewControllerAnimated(false)
    }
}
