//
//  SuggestionOverviewViewController.swift
//  Shifty
//
//  Created by Aron Hammond on 18/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import UIKit
import Parse

class SuggestionOverviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ActionSheetDelegate
{
    let rooster = Rooster(delegate: nil)
    let helper = Helper()
    var suggestions = [Shift]()
    var requestID = ""
    var request: Request? = nil
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad()
    {
        refresh()
        let parseObject = PFQuery(className: "RequestedShifts").getObjectWithId(requestID)
        request = Request(parseObject: parseObject!)
        super.viewDidLoad()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return suggestions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Suggestion") as! UITableViewCell
        cell.backgroundColor = UIColor.clearColor()
        
        let shiftForCell = suggestions[indexPath.row]
        cell.textLabel?.text = shiftForCell.dateString
        cell.accessoryView = helper.createTimeLabel(shiftForCell.timeString)
        
        if shiftForCell.status == "Awaitting Approval, sug"
        {
            cell.backgroundColor = UIColor(red: 255.0/255.0, green: 208.0/255.0, blue: 50.0/255.0, alpha: 1.0)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
    {
        let selectedShift = suggestions[indexPath.row]
        let actionSheet = ActionSheet(shift: selectedShift, delegate: self, request: requestID)
        
        // TODO: create refuseAction
        if selectedShift.status == "Awaitting Approval, sug"
        {
            actionSheet.includeActions(["Approve Suggestion"])
        }
        else
        {
            actionSheet.includeActions(["Accept Suggestion"])
        }
        
        
        let alertController = actionSheet.getAlertController()
        alertController.presentingViewController?.view = self.view
        presentViewController(alertController, animated: true, completion: nil)
        
        return indexPath
    }
    
    // required from delegate, but not not needed
    func switchStateOfActivityView(on: Bool)
    {
        if !on
        {
            activityIndicator.stopAnimating()
            activityView.hidden = true
        }
        if on
        {
            activityIndicator.startAnimating()
            activityView.hidden = false
        }
    }
    
    // BUG: doesn't remove objectID of accepted suggest from replies
    func refresh()
    {
        activityIndicator.startAnimating()
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
