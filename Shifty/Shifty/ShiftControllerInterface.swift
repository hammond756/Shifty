//
//  ShiftControllerInterface.swift
//  Shifty
//
//  Created by Aron Hammond on 18/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//
//  Parent class for ViewControllers that show TableViews with shifts. They share common
//  properties and outlets. This saves having duplicate functions/property initialization

import UIKit
import Parse

class ShiftControllerInterface: UIViewController, UITableViewDataSource
{
    // outlets
    @IBOutlet weak var tableView: UITableView! = nil
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // classes: see comments in respective files for more information
    let rooster = Rooster()
    let helper = Helper()
    
    // stores the section header titles (eg. Week 34)
    var sectionsInTable = [String]()
    
    // toggle activity indicator view on (true) off (false)
    func switchStateOfActivityView(on: Bool)
    {
        on ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        activityView.hidden = !on
    }
    
    // reload the table view
    func refresh(sections: [String])
    {
        sectionsInTable = sections
        sections.count == 0 ? (self.tableView.hidden = true) : (self.tableView.hidden = false)
        tableView.reloadData()
        switchStateOfActivityView(false)
    }
}

extension ShiftControllerInterface: UITableViewDataSource
{
    // get number of rows for a section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return rooster.ownedShifts[section].count
    }
    
    // return number of sections
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return sectionsInTable.count
    }
    
    // get titles from sectionsInTable and put them in the section headers
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return sectionsInTable[section]
    }
    
    // generate cell with commonly shared properties
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.reuseCell, forIndexPath: indexPath) as! UITableViewCell
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.textAlignment = NSTextAlignment.Center
        
        return cell
    }
}