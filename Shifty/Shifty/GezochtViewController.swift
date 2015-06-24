//
//  GezochtViewController.swift
//  Shifty
//
//  Created by Aron Hammond on 01/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import UIKit
import Parse
import SwiftDate

class GezochtViewController: ShiftControllerInterface
{
    @IBOutlet weak var makeRequestButton: UIButton!
    
    var selectedRequestID = ""
    
    override func viewDidLoad()
    {
        makeRequestButton.layer.cornerRadius = 10
        makeRequestButton.clipsToBounds = true
        super.viewDidLoad()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "Make Suggestion"
        {
            let svc = segue.destinationViewController as! SuggestionViewController
            svc.requestID = selectedRequestID
        }
        if segue.identifier == "See Suggestions"
        {
            let sovc = segue.destinationViewController as! SuggestionOverviewViewController
            sovc.requestID = selectedRequestID
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
    {
        let request = rooster.requestedShifs[indexPath.section][indexPath.row]
        selectedRequestID = request.objectID
        
        if request.owner == PFUser.currentUser()
        {
            self.performSegueWithIdentifier("See Suggestions", sender: nil)
        }
        else
        {
            self.performSegueWithIdentifier("Make Suggestion", sender: nil)
        }
        
        return indexPath
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return rooster.requestedShifs[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as UITableViewCell
        let requestForCell = rooster.requestedShifs[indexPath.section][indexPath.row]
        
        cell.textLabel?.text = requestForCell.dateString
        
        if requestForCell.owner == PFUser.currentUser()
        {
            cell.backgroundColor = UIColor(red: 255.0/255.0, green: 119.0/255.0, blue: 80.0/255.0, alpha: 1.0)
        }
        
        return cell
    }
    
    override func refresh()
    {
        activityIndicator.startAnimating()
        rooster.requestRequests() { sections -> Void in
            self.sectionsInTable = sections
            sections.count == 0 ? (self.tableView.hidden = true) : (self.tableView.hidden = false)
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            self.activityView.hidden = true
        }
    }
    
    @IBAction func logOutCurrentUser(sender: UIBarButtonItem)
    {
        helper.logOut(self)
    }
}
