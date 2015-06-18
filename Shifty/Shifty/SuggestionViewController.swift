//
//  SuggestionViewController.swift
//  Shifty
//
//  Created by Aron Hammond on 17/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import UIKit
import Parse

class SuggestionViewController: UITableViewController
{
    let rooster = Rooster()
    let helper = Helper()
    
    var sectionsInTable = [String]()
    
    // objectID's of shifts
    var selectedShifts = [String]()
    var requestID = ""
    
    @IBAction func finishedSuggesting(sender: UIBarButtonItem)
    {
        let query = PFQuery(className: "RequestedShifts")
        query.getObjectInBackgroundWithId(requestID) { (request: PFObject?, error: NSError?) -> Void in
            
            if error != nil
            {
                println(error?.description)
            }
            else if let request = request
            {
                request.addObjectsFromArray(self.selectedShifts, forKey: "replies")
                request.saveInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                    
                    if succes
                    {
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool)
    {
        refresh()
    }
    
    func refresh()
    {
        // IDEA: "toSuggest"? -> Don't show pending shifts
        
        rooster.requestShifts("Owned") { sections -> Void in
            self.sectionsInTable = sections
            self.tableView.reloadData()
        }
    }
    
    // everything to do with the table view
    
    // generate (reuse) cell.
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Shift", forIndexPath: indexPath) as! UITableViewCell
        
        // reset background color (cell color also gets reused)
        cell.backgroundColor = UIColor.clearColor()
        
        // get info from shift at indexPath
        let shiftForCell = rooster.ownedShifts[indexPath.section][indexPath.row]
        let date = shiftForCell.dateString
        let time = shiftForCell.timeString
        
        // set cell properties
        cell.textLabel?.text = date
        cell.accessoryView = helper.createTimeLabel(time)
        cell.textLabel?.textAlignment = NSTextAlignment.Center
        
        // give appropriate highlight, depending on status
        switch shiftForCell.status
        {
        case "Supplied": cell.backgroundColor = UIColor(red: 255.0/255.0, green: 119.0/255.0, blue: 80.0/255.0, alpha: 1.0)
        case "Awaitting Approval": cell.backgroundColor = UIColor(red: 255.0/255.0, green: 208.0/255.0, blue: 50.0/255.0, alpha: 1.0)
        default: break
        }
        
        return cell
    }
    
    // get number of rows for a section
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return rooster.ownedShifts[section].count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return sectionsInTable[section]
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return sectionsInTable.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let selectedShift = rooster.ownedShifts[indexPath.section][indexPath.row]
        selectedShifts.append(selectedShift.objectID)
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath)
    {
        let deselectedShift = rooster.ownedShifts[indexPath.section][indexPath.row]
        
        if let index = find(selectedShifts, deselectedShift.objectID)
        {
            selectedShifts.removeAtIndex(index)
        }
    }
}
