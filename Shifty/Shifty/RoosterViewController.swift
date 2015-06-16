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
        callActionSheet(selectedShift)
        
        return indexPath
    }
    
    private func callActionSheet(selectedShift: Shift)
    {
        let actionSheetController = UIAlertController()
        
        let supplyAction = UIAlertAction(title: "Aanbieden", style: .Default) { action -> Void in
            
            selectedShift.status = "Supplied"
            
            let query = PFQuery(className: "Shifts")
            query.getObjectInBackgroundWithId(selectedShift.objectID) { (shift: PFObject?, error: NSError?) -> Void in
                
                if error != nil
                {
                    println(error?.description)
                }
                else if let shift = shift
                {
                    shift["Status"] = "Supplied"
                    shift.saveInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                        
                        if error != nil
                        {
                            println(error?.description)
                        }
                        else
                        {
                            self.tableView.reloadData()

                        }
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Annuleren", style: .Cancel) { action -> Void in
            
            actionSheetController.dismissViewControllerAnimated(true, completion: nil)
        }
        
        let approveAction = UIAlertAction(title: "Goedkeuren", style: .Default) { action -> Void in
            selectedShift.status = "idle"
            
            let query = PFQuery(className: "Shifts")
            query.getObjectInBackgroundWithId(selectedShift.objectID) { (shift: PFObject?, error: NSError?) -> Void in
                
                if error != nil
                {
                    println(error?.description)
                }
                else if let shift = shift
                {
                    shift["Status"] = "idle"
                    shift["Owner"] = shift["acceptedBy"]
                    
                    shift.saveInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                        
                        if error != nil
                        {
                            println(error?.description)
                        }
                        else
                        {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
        
        let revokeAction = UIAlertAction(title: "Terugrekken", style: .Default) { action -> Void in
            
            selectedShift.status = "idle"
            
            let query = PFQuery(className: "Shifts")
            query.getObjectInBackgroundWithId(selectedShift.objectID) { (shift: PFObject?, error: NSError?) -> Void in
                    
                if error != nil
                {
                    println(error?.description)
                }
                else if let shift = shift
                {
                    shift["Status"] = "idle"
                    
                    shift.saveInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                        
                        if error != nil
                        {
                            println(error?.description)
                        }
                        else
                        {
                            self.tableView.reloadData()
                        }
                    }
                }
                
            }
        }
        
        switch selectedShift.status
        {
            case "idle": actionSheetController.addAction(supplyAction)
            case "Awaitting Approval": actionSheetController.addAction(approveAction)
            case "Supplied": actionSheetController.addAction(revokeAction)
            default: break
        }
        actionSheetController.addAction(cancelAction)
        
        actionSheetController.popoverPresentationController?.sourceView = self.view
        presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    @IBAction func logOutCurrentRooster(sender: UIBarButtonItem)
    {
        PFUser.logOut()
        
        let loginViewController = self.storyboard!.instantiateViewControllerWithIdentifier("Login") as! LogInViewController
        UIApplication.sharedApplication().keyWindow?.rootViewController = loginViewController
    }
    
}
