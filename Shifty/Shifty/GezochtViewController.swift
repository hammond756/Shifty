//
//  GezochtViewController.swift
//  Shifty
//
//  Created by Aron Hammond on 01/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import UIKit
import Parse

class GezochtViewController: UITableViewController
{
    let wantedShifts: [Shift] = [Shift(day: 3, month: 6, year: 2015, time: (18,0)), Shift(day: 3, month: 6, year: 2015, time: (15,0)), Shift(day: 5, month: 6, year: 2015, time: (17,0)), Shift(day: 10, month: 6, year: 2015, time: (16,30)), Shift(day: 12, month: 6, year: 2015, time: (17,0)), Shift(day: 13, month: 6, year: 2015, time: (17,0)), Shift(day: 16, month: 6, year: 2015, time: (18,0)), Shift(day: 23, month: 6, year: 2015, time: (17,0)), Shift(day: 29, month: 6, year: 2015, time: (18,0)), Shift(day: 3, month: 7, year: 2015, time: (17,0)), Shift(day: 17, month: 7, year: 2015, time: (17,0))]
    
    var sectionsInTable = [String]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        for shift in wantedShifts
        {
            let weekOfYear = shift.getWeekOfYear()
            let sections = NSSet(array: sectionsInTable)
            
            if !sections.containsObject(weekOfYear)
            {
                sectionsInTable.append(weekOfYear)
            }
        }
        
        tableView.hidden = true
    }
    
    func getSectionItems(section: Int) -> [Shift]
    {
        var sectionItems = [Shift]()
        
        for shift in wantedShifts
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
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return sectionsInTable[section]
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return sectionsInTable.count
    }

}
