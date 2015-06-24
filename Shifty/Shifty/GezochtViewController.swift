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
    
    override func viewWillAppear(animated: Bool)
    {
        getData()
        super.viewWillAppear(animated)
    }
    
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
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
    {
        let request = rooster.requestedShifs[indexPath.section][indexPath.row]
        selectedRequestID = request.objectID
        
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
    
    func getData()
    {
        activityIndicator.startAnimating()
        rooster.requestRequests() { sections -> Void in
            self.refresh(sections)
        }
    }
    
    @IBAction func logOutCurrentUser(sender: UIBarButtonItem)
    {
        helper.logOut(self)
    }
}
