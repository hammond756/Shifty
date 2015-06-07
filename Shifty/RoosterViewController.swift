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
    
    let rooster = Rooster()
    var shifts: [Shift] = []
    var sectionsInTable = [String]()
    
    @IBAction func goToSubmitView()
    {
        performSegueWithIdentifier("Submit Rooster", sender: nil)
    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        requestFixedRooster()
//        
//        if shifts.count == 0
//        {
//            println("shifts == 0")
//            self.tableView.hidden = true
//        }
//        else
//        {
//            getSections(shifts)
//            self.tableView.reloadData()
//            self.tableView.hidden = false
//        }
//    }
//    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        requestFixedRooster()
        
        
        
        submitButton.layer.cornerRadius = 10
        submitButton.clipsToBounds = true
        
    }
    
    func requestFixedRooster()
    {
        var currentUser = PFUser.currentUser()
        let userID = currentUser?.objectId
        let query = PFQuery(className: "Shifts")
        query.whereKey("Owner", equalTo: userID!)
        
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            
            
            if error == nil
            {
                println("hooray")
                
                if let objects = objects as? [PFObject]
                {
                    for object in objects
                    {
                        let hour = object["Hour"] as! Int
                        let minute = object["Minute"] as! Int
                        let day = object["Day"] as! String
                        println("in loop")
                        let rooster = Rooster()
                        rooster.addRecurringShift(day, hour: hour, minute: minute)
                        
                        println("about to assign shifts")
                        self.shifts = rooster.recurringShifts
                        
                        getSections(shifts)
                        
                        if self.shifts != 0
                        {
                            self.tableView.hidden = false
                            self.tableView.reloadData()
                        }
                    }
                }
            }
            
        }
        
    }
    
    // everything to do with the table view
    private func getSections(shifts: [Shift])
    {
        for shift in shifts
        {
            let weekOfYear = shift.getWeekOfYear()
            let sections = NSSet(array: sectionsInTable)
            
            if !sections.containsObject(weekOfYear)
            {
                sectionsInTable.append(weekOfYear)
            }
        }
        
        println(sectionsInTable)
    }
    
    private func getSectionItems(section: Int) -> [Shift]
    {
        var sectionItems = [Shift]()
        
        for shift in shifts
        {
            if shift.getWeekOfYear() == sectionsInTable[section]
            {
                sectionItems.append(shift)
            }
        }
        println(sectionItems)
        return sectionItems
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return getSectionItems(section).count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Shift", forIndexPath: indexPath) as! UITableViewCell
        let sectionItems = getSectionItems(indexPath.section)
        
        var timeLabel = UILabel()
        timeLabel.font = UIFont.systemFontOfSize(14)
        timeLabel.textAlignment = NSTextAlignment.Center
        timeLabel.text = sectionItems[indexPath.row].timeString
        timeLabel.sizeToFit()
        
        cell.textLabel?.text = sectionItems[indexPath.row].dateString
        cell.accessoryView = timeLabel
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
}
