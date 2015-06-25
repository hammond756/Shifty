//
//  GezochtViewController.swift
//  Shifty
//
//  Created by Aron Hammond on 01/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//
//  Shows an overview of Requests. It shows all requests known. Those owned by the
//  current user are highlighted. Users can send suggestions or view an overview
//  of suggestions depening if they are owner of that request.

import UIKit
import Parse
import SwiftDate

class GezochtViewController: ShiftViewController
{
    // outlet for programmatic styling
    @IBOutlet weak var makeRequestButton: UIButton!
    
    @IBAction func logOutCurrentUser(sender: UIBarButtonItem)
    {
        helper.logOut(self)
    }
    
    var selectedRequestID = ""
    
    override func viewDidLoad()
    {
        // round edges of UIButton
        makeRequestButton.layer.cornerRadius = 10
        makeRequestButton.clipsToBounds = true
        super.viewDidLoad()
    }
    
    // actions on ActionSheet call getData() when the corresponding changes are saved, so the view can reload properly
    override func getData()
    {
        setActivityViewActive(true)
        rooster.requestRequests() { sections -> Void in
            self.refresh(sections)
        }
    }
    
    // assign the destinationViewController's requestID property to the selected Request's ID
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == Segue.makeSuggestion
        {
            let svc = segue.destinationViewController as! SuggestionViewController
            svc.requestID = selectedRequestID
        }
        if segue.identifier == Segue.seeSuggestions
        {
            let sovc = segue.destinationViewController as! SuggestionOverviewViewController
            sovc.requestID = selectedRequestID
        }
    }
}

extension GezochtViewController: UITableViewDataSource
{
    // information needs to come from another property than other ShiftViewControllers
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return rooster.requestedShifs[section].count
    }
    
    // set labels and highlighting for cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as UITableViewCell
        let requestForCell = rooster.requestedShifs[indexPath.section][indexPath.row]
        
        cell.textLabel?.text = requestForCell.dateString
        
        if requestForCell.owner == PFUser.currentUser()
        {
            cell.backgroundColor = Highlight.owner
        }
        
        return cell
    }
}

extension GezochtViewController: UITableViewDelegate
{
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
    {
        // set selectedRequestID to selected request's id (get's passed on the next view controller)
        let request = rooster.requestedShifs[indexPath.section][indexPath.row]
        selectedRequestID = request.objectID
        
        // trigger segue depending on ownership
        if request.owner == PFUser.currentUser()
        {
            self.performSegueWithIdentifier(Segue.seeSuggestions, sender: nil)
        }
        else
        {
            self.performSegueWithIdentifier(Segue.makeSuggestion, sender: nil)
        }
        
        return indexPath
    }
}
