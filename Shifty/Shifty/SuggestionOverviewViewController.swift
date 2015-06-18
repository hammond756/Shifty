//
//  SuggestionOverviewViewController.swift
//  Shifty
//
//  Created by Aron Hammond on 18/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import UIKit

class SuggestionOverviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    let rooster = Rooster()
    let helper = Helper()
    var suggestions = [Shift]()
    var associatedRequest = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(animated: Bool)
    {
        rooster.requestSuggestions(associatedRequest) { suggestions -> Void in
            self.rooster.requestShiftsFromIDs(suggestions) { shifts -> Void in
                self.suggestions = shifts
                self.tableView.reloadData()
            }
        }
        
        super.viewWillAppear(animated)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Suggestion") as! UITableViewCell
        
        let shiftForCell = suggestions[indexPath.row]
        cell.textLabel?.text = shiftForCell.dateString
        cell.accessoryView = helper.createTimeLabel(shiftForCell.timeString)
        
        return cell
    }
}