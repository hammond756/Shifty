//
//  SuggestionViewController.swift
//  Shifty
//
//  Created by Aron Hammond on 17/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import UIKit
import Parse

class SuggestionViewController: ShiftControllerInterface
{
    @IBOutlet weak var submitButton: UIButton!
    
    // objectID's of shifts
    var selectedShifts = [String]()
    
    // objectID of associated request
    var requestID = ""
    var request: Request? = nil
    var parseObject: PFObject? = nil
    
    @IBAction func finishedSuggesting(sender: UIBarButtonItem)
    {
        let query = PFQuery(className: "RequestedShifts")
        query.getObjectInBackgroundWithId(requestID) { (request: PFObject?, error: NSError?) -> Void in

            if let request = self.helper.returnObjectAfterErrorCheck(request, error: error) as? PFObject
            {
                request.addUniqueObjectsFromArray(self.selectedShifts, forKey: "replies")
                request.saveInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                    
                    if succes
                    {
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                }
            }
        }
        
        helper.updateShiftStatuses(selectedShifts, newStatus: "Suggested", suggestedTo: parseObject)
    }
    
//    func updateShiftStatuses(shiftIDs: [String])
//    {
//        for ID in shiftIDs
//        {
//            PFQuery(className: "Shifts").getObjectInBackgroundWithId(ID) { (shift: PFObject?, error: NSError?) -> Void in
//                if let shift = self.helper.returnObjectAfterErrorCheck(shift, error: error) as? PFObject
//                {
//                    shift["Status"] = "Suggested"
//                    shift["suggestedTo"] = self.parseObject!
//                    shift.saveInBackground()
//                }
//            }
//        }
//    }
    
    override func viewDidLoad()
    {
        submitButton.layer.cornerRadius = 10
        submitButton.clipsToBounds = true
        parseObject = PFQuery(className: "RequestedShifts").getObjectWithId(requestID)
        request = Request(parseObject: parseObject!)
        super.viewDidLoad()
    }
    
    // everything to do with the table view
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let selectedShift = rooster.ownedShifts[indexPath.section][indexPath.row]
        if selectedShift.status == "idle"
        {
            selectedShifts.append(selectedShift.objectID)
        }
        // else: "Je hebt diensten geselecteerd die al in behandeling zijn"
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath)
    {
        let deselectedShift = rooster.ownedShifts[indexPath.section][indexPath.row]
        
        if let index = find(selectedShifts, deselectedShift.objectID)
        {
            selectedShifts.removeAtIndex(index)
        }
    }
}
