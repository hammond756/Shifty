//
//  RoosterViewController.swift
//  Shifty
//
//  Created by Aron Hammond on 01/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import UIKit

class RoosterViewController: UITableViewController
{
    var shifts: [Shift] = [Shift(day: 3, month: 6, year: 2015, time: (18,0)), Shift(day: 10, month: 6, year: 2015, time: (18,0)), Shift(day: 16, month: 6, year: 2015, time: (18,0))]
    
    var sectionsInTable = [String]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let sections = NSSet(array: sectionsInTable)
        
        for shift in shifts
        {
            if !sections.containsObject(shift.getWeekOfYear())
            {
                sectionsInTable.append(shift.getWeekOfYear())
            }
        }
    }
    
    func getSectionItems(section: Int) -> [Shift]
    {
        var sectionItems = [Shift]()
        
        for shift in shifts
        {
            if shift.getWeekOfYear() == sectionsInTable[section]
            {
                sectionItems.append(shift)
            }
        }
        
        return sectionItems
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return getSectionItems(section).count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Shift", forIndexPath: indexPath) as! UITableViewCell
        let sectionItems = getSectionItems(indexPath.section)
        
        cell.textLabel?.text = sectionItems[indexPath.row].dateString
        
        var timeLabel = UILabel()
        timeLabel.font = UIFont.systemFontOfSize(14)
        timeLabel.textAlignment = NSTextAlignment.Center
        timeLabel.text = sectionItems[indexPath.row].timeString
        timeLabel.sizeToFit()
        
        cell.accessoryView = timeLabel
        
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
}
