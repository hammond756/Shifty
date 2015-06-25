//
//  SuggestionOverviewViewController.swift
//  Shifty
//
//  Created by Aron Hammond on 18/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import UIKit
import Parse

class SuggestionOverviewViewController: ShiftControllerInterface
{
    var suggestions = [Shift]()
    var requestID = ""
    var request: Request? = nil

    override func viewDidLoad()
    {
        getData()
        super.viewDidLoad()
    }
    
    // BUG: doesn't remove objectID of accepted suggest from replies
    func getData()
    {
        switchStateOfActivityView(true)
        rooster.requestSuggestions(requestID) { suggestions -> Void in
            self.suggestions = suggestions
            suggestions.count == 0 ? (self.tableView.hidden = true) : (self.tableView.hidden = false)
            self.tableView.reloadData()
            self.switchStateOfActivityView(false)
        }
    }

}

extension SuggestionOverviewViewController: ActionSheetDelegate
{
    func popViewController()
    {
        navigationController?.popViewControllerAnimated(false)
    }
}

extension SuggestionOverviewViewController: UITableViewDataSource
{
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return suggestions.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return nil
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as UITableViewCell
        let shiftForCell = suggestions[indexPath.row]
        
        cell.textLabel?.text = shiftForCell.dateString
        cell.accessoryView = helper.createTimeLabel(shiftForCell.timeString)
        
        if shiftForCell.status == Status.awaittingFromSug
        {
            cell.backgroundColor = Highlight.awaitting
        }
        
        return cell
    }
}

extension SuggestionOverviewViewController: UITableViewDelegate
{
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
    {
        let selectedShift = suggestions[indexPath.row]
        let actionSheet = ActionSheet(shift: selectedShift, delegate: self, request: requestID)
        
        if selectedShift.status == Status.awaittingFromSug
        {
            actionSheet.includeActions([Action.approveSug, /*Action.disapproveSug*/])
        }
        if selectedShift.status == Status.suggested
        {
            actionSheet.includeActions([Action.acceptSug])
        }
        
        let alertController = actionSheet.getAlertController()
        alertController.presentingViewController?.view = self.view
        presentViewController(alertController, animated: true, completion: nil)
        
        return indexPath
    }
}
