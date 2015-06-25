//
//  SuggestionViewController.swift
//  Shifty
//
//  Created by Aron Hammond on 17/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//
//  Loads the current user's schedule. Multiple shifts can be selected and sent
//  as a suggestion to a request.

import UIKit
import Parse

class SuggestionViewController: ShiftViewController
{
    @IBOutlet weak var submitButton: UIButton!
    
    // set the selected shifts to suggested and pop viewcontroller
    @IBAction func finishedSuggesting(sender: UIBarButtonItem)
    {
        helper.updateShiftStatuses(selectedShifts, newStatus: Status.suggested, suggestedTo: parseObject) { }
        navigationController?.popViewControllerAnimated(true)
    }
    
    // objectID's of shifts
    var selectedShifts = [String]()
    
    // objectID of associated request
    var requestID = ""
    var request: Request? = nil
    var parseObject: PFObject? = nil
    
    override func viewDidLoad()
    {
        submitButton.layer.cornerRadius = 10
        submitButton.clipsToBounds = true
        
        parseObject = PFQuery(className: ParseClass.requests).getObjectWithId(requestID)
        request = Request(parseObject: parseObject!)
        
        super.viewDidLoad()
    }
    
    override func getData()
    {
        setActivityViewActive(true)
        rooster.requestShifts(Status.owned) { sections -> Void in
            self.refresh(sections)
        }
    }
}

extension SuggestionViewController: UITableViewDataSource
{
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as UITableViewCell
        let shiftForCell = rooster.ownedShifts[indexPath.section][indexPath.row]
        
        cell.textLabel?.text = shiftForCell.dateString
        cell.accessoryView = helper.createTimeLabel(shiftForCell.timeString)
        cell.selectionStyle = .Default
        
        // dim shifts that are irrelevant
        if !shiftForCell.isOnSameDayAs(request!.date) || shiftForCell.status != Status.idle
        {
            cell.textLabel?.textColor = UIColor.lightGrayColor()
        }
        
        return cell
    }
}

extension SuggestionViewController: UITableViewDelegate
{
    // everything to do with the table view
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let selectedShift = rooster.ownedShifts[indexPath.section][indexPath.row]
        
        if selectedShift.status == Status.idle && selectedShift.isOnSameDayAs(request!.date)
        {
            selectedShifts.append(selectedShift.objectID)
        }
        // disable selection
        else
        {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
    }
    
    // remove shift from selectedShifts when deselected
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath)
    {
        let deselectedShift = rooster.ownedShifts[indexPath.section][indexPath.row]
        
        if let index = find(selectedShifts, deselectedShift.objectID)
        {
            selectedShifts.removeAtIndex(index)
        }
    }
}
