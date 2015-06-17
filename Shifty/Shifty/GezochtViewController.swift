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
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        rooster.requestRequestedShifts() { sections -> Void in
            
            self.sectionsInTable = sections
            self.tableView.reloadData()
        }
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
