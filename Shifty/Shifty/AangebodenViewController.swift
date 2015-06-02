//
//  AangebodenViewController.swift
//  Shifty
//
//  Created by Aron Hammond on 01/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import UIKit

class AangebodenViewController: UITableViewController {

    let shifts: [String] = ["Wo 3 jun 18:00", "Vr 5 jun 17:00", "Wo 3 jun 18:00", "Vr 5 jun 17:00", "Wo 3 jun 18:00", "Vr 5 jun 17:00"]
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Shift", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = shifts[indexPath.row]
        
        return cell
    }

}
