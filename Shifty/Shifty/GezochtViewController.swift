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

class GezochtViewController: UITableViewController
{
    let rooster = Rooster()
    let helper = Helper()
    var sectionsInTable = [String]()
    var selectedRequestID = ""
    
    // naar refresh()
    override func viewWillAppear(animated: Bool)
    {
        rooster.requestRequests() { sections -> Void in
            self.sectionsInTable = sections
            self.tableView.reloadData()
        }
        
        super.viewWillAppear(animated)
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
            sovc.associatedRequest = selectedRequestID
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
    {
        let request = rooster.requestedShifs[indexPath.section][indexPath.row]
        selectedRequestID = request.objectID
        
        let query = PFQuery(className: "RequestedShifts")
        query.getObjectInBackgroundWithId(selectedRequestID) { (request: PFObject?, error: NSError?) -> Void in
            
            if let request = self.helper.returnObjectAfterErrorCheck(request, error: error) as? PFObject
            {
                if request["requestedBy"] as? PFUser == PFUser.currentUser()
                {
                    self.performSegueWithIdentifier("See Suggestions", sender: nil)
                }
                else
                {
                    self.performSegueWithIdentifier("Make Suggestion", sender: nil)
                }
                
            }
        }
        
        return indexPath
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return rooster.requestedShifs[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Shift", forIndexPath: indexPath) as! UITableViewCell
        let date = rooster.requestedShifs[indexPath.section][indexPath.row]
        
        cell.textLabel?.text = date.date.toString(format: DateFormat.Custom("EEEE dd MMM"))
        cell.textLabel?.textAlignment = NSTextAlignment.Center
        
        if date.requestedBy == PFUser.currentUser()
        {
            cell.backgroundColor = UIColor(red: 255.0/255.0, green: 119.0/255.0, blue: 80.0/255.0, alpha: 1.0)
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
    
    @IBAction func logOutCurrentUser(sender: UIBarButtonItem)
    {
        helper.logOut(self)
    }
}
