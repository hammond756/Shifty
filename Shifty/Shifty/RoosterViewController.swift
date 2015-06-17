//
//  RoosterViewController.swift
//  Shifty
//
//  Created by Aron Hammond on 03/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import UIKit
import Parse

class RoosterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ActionSheetDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    var refreshControl: UIRefreshControl!
    
    let rooster = Rooster()
    let helper = Helper()
    
    var sectionsInTable = [String]()
    
    @IBAction func goToSubmitView()
    {
        performSegueWithIdentifier("Submit Rooster", sender: nil)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        refresh()
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad()
    {
        // display the current user's username in the navigation bar
        title = PFUser.currentUser()?.username
        
        // set style of the submit button in de hidden view
        submitButton.layer.cornerRadius = 10
        submitButton.clipsToBounds = true
        
        super.viewDidLoad()
    }
    
    // everything to do with the table view
    
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
        
        // give appropriate highlight, depending on status
        switch shiftForCell.status
        {
            case "Supplied": cell.backgroundColor = UIColor(red: 255.0/255.0, green: 119.0/255.0, blue: 80.0/255.0, alpha: 1.0)
            case "Awaitting Approval": cell.backgroundColor = UIColor(red: 255.0/255.0, green: 208.0/255.0, blue: 50.0/255.0, alpha: 1.0)
            default: break
        }
        
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
    
    // an action sheet gets called depending on the status of the selected shift
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
    {
        let selectedShift = rooster.ownedShifts[indexPath.section][indexPath.row]
        let actionSheet = ActionSheet(shift: selectedShift, delegate: self)
        
        if selectedShift.status == "idle"
        {
            actionSheet.includeActions(["Supply"])
        }
        if selectedShift.status == "Awaitting Approval" && selectedShift.owner == PFUser.currentUser()
        {
            actionSheet.includeActions(["Approve"])
        }
        else if selectedShift.owner != PFUser.currentUser()
        {
            actionSheet.includeActions(["Approve"])
        }
        if selectedShift.status == "Supplied"
        {
            actionSheet.includeActions(["Revoke"])
        }
        
        let alertController = actionSheet.getAlertController()
        
        alertController.popoverPresentationController?.sourceView = self.view
        self.presentViewController(alertController, animated: true, completion: nil)
        
        return indexPath
    }
    
    // actions on action sheet call refresh when they are done, so the view can reload properly
    func refresh()
    {
        rooster.requestShifts("Owned") { sections -> Void in
            self.sectionsInTable = sections
            self.tableView.reloadData()
        }
    }
    
    @IBAction func logOutCurrentRooster(sender: UIBarButtonItem)
    {
        helper.logOut(self)
    }
}
