//
//  SuggestionViewController.swift
//  Shifty
//
//  Created by Aron Hammond on 17/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import UIKit

class SuggestionViewController: UITableViewController
{
    let rooster = Rooster()
    let helper = Helper()
    
    var sectionsInTable = [String]()
    
    // everything to do with the table view
    
    // get number of rows for a section
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return rooster.ownedShifts[section].count
    }
    
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
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return sectionsInTable[section]
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return sectionsInTable.count
    }
}
