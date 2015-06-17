//
//  RoosterViewController.swift
//  Shifty
//
//  Created by Aron Hammond on 03/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import UIKit
import Parse

class RoosterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    var refreshControl: UIRefreshControl!
    
    let rooster = Rooster()
    
    var sectionsInTable = [String]()
    
    @IBAction func goToSubmitView()
    {
        performSegueWithIdentifier("Submit Rooster", sender: nil)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        rooster.requestShifts("Owned") { (sections) -> Void in
            self.sectionsInTable = sections
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
                
        // add refresh control to table view
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        // display the current user's username in the navigation bar
        title = PFUser.currentUser()?.username
        
        // set style of the submit button in de hidden view
        submitButton.layer.cornerRadius = 10
        submitButton.clipsToBounds = true
    }
    
    // refresh function gets called by refresh control
    func refresh(sender:AnyObject)
    {
        rooster.requestShifts("Owned") { (sections) -> Void in
            self.sectionsInTable = sections
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
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
        
        cell.backgroundColor = UIColor.clearColor()
        
        let shiftForCell = rooster.ownedShifts[indexPath.section][indexPath.row]
        let date = shiftForCell.dateString
        let time = shiftForCell.timeString
        
        cell.textLabel?.text = date
        cell.accessoryView = createTimeLabel(time)
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
    
    private func createTimeLabel(time: String) -> UILabel
    {
        var label = UILabel()
        label.font = UIFont.systemFontOfSize(14)
        label.textAlignment = NSTextAlignment.Center
        label.text = time
        label.sizeToFit()
        
        return label
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
        let selectedShift = rooster.ownedShifts[indexPath.section][indexPath.row]
        let actionSheet = ActionSheet(shift: selectedShift, calledBy: self.tableView)
        
        if selectedShift.status == "idle"
        {
            actionSheet.includeActions(["Supply"])
        }
        if selectedShift.status == "Awaitting Approval" && selectedShift.owner == PFUser.currentUser()
        {
            actionSheet.includeActions(["Approve", "Revoke"])
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
    
    @IBAction func logOutCurrentRooster(sender: UIBarButtonItem)
    {
        PFUser.logOut()
        
        let loginViewController = self.storyboard!.instantiateViewControllerWithIdentifier("Login") as! LogInViewController
        UIApplication.sharedApplication().keyWindow?.rootViewController = loginViewController
    }
    
}
