//
//  ActionSheet.swift
//  Shifty
//
//  Created by Aron Hammond on 17/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import Foundation
import UIKit
import Parse

protocol ActionSheetDelegate
{
    func refresh()
}

class ActionSheet
{
    var selectedShift: Shift
    var actionList = [UIAlertAction]()
    var delegate: ActionSheetDelegate
    
    let helper = Helper()
    
    init(shift: Shift, delegate: ActionSheetDelegate)
    {
        selectedShift = shift
        self.delegate = delegate
    }
    
    // add a action the the action sheet that supplies a shift to the marketplace and save the changes in the database
    func createSupplyAction()
    {
        let supplyAction = UIAlertAction(title: "Aanbieden", style: .Default) { action -> Void in
            
            self.selectedShift.status = "Supplied"
            
            let query = PFQuery(className: "Shifts")
            query.getObjectInBackgroundWithId(self.selectedShift.objectID) { (shift: PFObject?, error: NSError?) -> Void in
                
                if let shift = self.helper.returnObjectAfterErrorCheck(shift, error: error)
                {
                    shift[0]["Status"] = "Supplied"
                    shift[0].saveInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                        
                        succes ? self.delegate.refresh() : println(error?.description)
                    }
                }
            }
        }
        
        actionList.append(supplyAction)
    }
    
    // add a action the the action sheet that approves a deal and save changes in the database
    func createApproveAction()
    {
        let approveAction = UIAlertAction(title: "Goedkeuren", style: .Default) { action -> Void in
            self.selectedShift.status = "idle"
            
            let query = PFQuery(className: "Shifts")
            query.getObjectInBackgroundWithId(self.selectedShift.objectID) { (shift: PFObject?, error: NSError?) -> Void in
                
                if let shift = self.helper.returnObjectAfterErrorCheck(shift, error: error)
                {
                    shift[0]["Status"] = "idle"
                    shift[0]["Owner"] = shift[0]["acceptedBy"]
                    
                    shift[0].saveInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                        
                        succes ? self.delegate.refresh() : println(error?.description)
                    }
                }
            }
        }
        
        actionList.append(approveAction)
    }
    
    // add a action the the action sheet that revokes a shift from the marketplace and save change in the database
    func createRevokeAction()
    {
        let revokeAction = UIAlertAction(title: "Terugrekken", style: .Default) { action -> Void in
            
            self.selectedShift.status = "idle"
            
            let query = PFQuery(className: "Shifts")
            query.getObjectInBackgroundWithId(self.selectedShift.objectID) { (shift: PFObject?, error: NSError?) -> Void in
                
                if let shift = self.helper.returnObjectAfterErrorCheck(shift, error: error)
                {
                    shift[0]["Status"] = "idle"
                    
                    shift[0].saveInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                        
                        succes ? self.delegate.refresh() : println(error?.description)
                    }
                }
            }
        }
        
        actionList.append(revokeAction)
    }
    
    // add a action the the action sheet that accepts a supplied shift and save change in the database
    func createAcceptAction()
    {
        let acceptAction = UIAlertAction(title: "Accepteren", style: .Default) { action -> Void in
            
            let query = PFQuery(className: "Shifts")
            
            query.getObjectInBackgroundWithId(self.selectedShift.objectID) { (shift: PFObject?, error: NSError? ) -> Void in
                
                if let shift = self.helper.returnObjectAfterErrorCheck(shift, error: error)
                {
                    shift[0]["Status"] = "Awaitting Approval"
                    shift[0]["acceptedBy"] = PFUser.currentUser()
                    shift[0].saveInBackgroundWithBlock() { (succes, error) -> Void in
                        
                        succes ? self.delegate.refresh() : println(error?.description)
                    }
                }
            }
        }
        
        actionList.append(acceptAction)
    }
    
    // optional before segue (now directly from willselectrow)
    func createSuggestAction()
    {
        let suggestAction = UIAlertAction(title: "Doe Suggestie", style: .Default) { action -> Void in
            
            
        }
    }
    
    func getAlertController() -> UIAlertController
    {
        let actionSheetController = UIAlertController()
        
        for action in actionList
        {
            actionSheetController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Annuleren", style: .Cancel) { action -> Void in
            
            actionSheetController.dismissViewControllerAnimated(true, completion: nil)
        }
        
        actionSheetController.addAction(cancelAction)
        
        return actionSheetController
    }
    
    func includeActions(actions: [String])
    {
        for action in actions
        {
            switch action
            {
            case "Supply": createSupplyAction()
            case "Revoke": createRevokeAction()
            case "Approve": createApproveAction()
            case "Accept": createAcceptAction()
            default: break
            }
        }
    }

}