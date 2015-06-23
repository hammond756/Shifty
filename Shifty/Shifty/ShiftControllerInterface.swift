//
//  ShiftControllerInterface.swift
//  Shifty
//
//  Created by Aron Hammond on 18/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import UIKit
import Parse

class ShiftControllerInterface: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView! = nil
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    let rooster = Rooster(delegate: nil)
    let helper = Helper()
    var sectionsInTable = [String]()
    
    override func viewWillAppear(animated: Bool)
    {
        refresh()
        super.viewWillAppear(animated)
    }
    
    // get number of rows for a section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return rooster.ownedShifts[section].count
    }
    
    // generate (reuse) cell.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
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
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return sectionsInTable[section]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return sectionsInTable.count
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
    {
        return indexPath
    }
    
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
    
    // actions on action sheet call refresh when they are done, so the view can reload properly
    func refresh()
    {
        activityIndicator.startAnimating()
        rooster.requestShifts("Owned") { sections -> Void in
            self.sectionsInTable = sections
            sections.count == 0 ? (self.tableView.hidden = true) : (self.tableView.hidden = false)
            self.tableView.reloadData()
            self.switchStateOfActivityView(false)
        }
    }
}