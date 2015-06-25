//
//  ShiftViewController.swift
//  Shifty
//
//  Created by Aron Hammond on 18/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//
//  Parent class for ViewControllers that show TableViews with shifts. They share common
//  properties and outlets. This saves having duplicate functions/property initialization
//
//  NOTE: subclasses are less thoroughly commented, scince a lot of behavior is similar to parent

import UIKit
import Parse

class ShiftViewController: UIViewController, UITableViewDataSource
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
    
    override func viewWillAppear(animated: Bool)
    {
        getData()
        super.viewWillAppear(animated)
    }
    
    // toggle activity indicator view on (true) off (false)
    func setActivityViewActive(on: Bool)
    {
        on ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        activityView.hidden = !on
    }
    
    // retrieves relevant data from the database and reloads the view.
    // subclasses all have slightly different implementations of getData()
    func getData()
    {
        return
    }
    
    // reload the table view
    func refresh(sections: [String])
    {
        sectionsInTable = sections
        sections.count == 0 ? (self.tableView.hidden = true) : (self.tableView.hidden = false)
        tableView.reloadData()
        setActivityViewActive(false)
    }
    
    // create and present alertView with supplied message and cancel button
    func showAlertMessage(message: String)
    {
        let alertView = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Ohja", style: .Cancel) { action -> Void in
            alertView.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alertView.addAction(cancelAction)
        alertView.popoverPresentationController?.sourceView = self.view
        self.presentViewController(alertView, animated: true, completion: nil)
    }
}

extension ShiftViewController: UITableViewDataSource
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
        cell.selectionStyle = .None
        
        return cell
    }
}