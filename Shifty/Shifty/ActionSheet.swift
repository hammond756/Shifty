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

// definiton of protocol that all viewcontrollers incorporating an actionsheet or alertview conform to
@objc protocol ActionSheetDelegate
{
    func refresh()
    func switchStateOfActivityView(on: Bool)
    optional func popViewController()
    optional func showAlert(alertView: UIAlertController)
}

// handles the creation of UIAlertControllers throughout the application
class ActionSheet
{
    var selectedShift: Shift
    var associatedRequest: String?
    var actionList = [UIAlertAction]()
    var delegate: ActionSheetDelegate
    
    let helper = Helper()
    
    init(shift: Shift, delegate: ActionSheetDelegate, request: String?)
    {
        self.selectedShift = shift
        self.delegate = delegate
        self.associatedRequest = request
    }
    
    // add a action the the action sheet that supplies a shift to the marketplace and save the changes in the database
    func createSupplyAction()
    {
        let supplyAction = UIAlertAction(title: "Aanbieden", style: .Default) { action -> Void in
            
            self.selectedShift.status = "Supplied"
            
            let query = PFQuery(className: "Shifts")
            query.getObjectInBackgroundWithId(self.selectedShift.objectID) { (shift: PFObject?, error: NSError?) -> Void in
                if let shift = self.helper.returnObjectAfterErrorCheck(shift, error: error) as? PFObject
                {
                    shift["Status"] = "Supplied"
                    shift.saveInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                        
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
            self.approveShiftChange()
        }
        
        actionList.append(approveAction)
    }
    
    // appriving a suggestion needs extra behaviour on top of approveShiftChange, namely removing the request
    func createApproveSuggestionAction()
    {
        approveShiftChange()
        
        let approveSuggestionAction = UIAlertAction(title: "Goedkeuren, sug", style: .Default) { action -> Void in
            let query = PFQuery(className: "RequestedShifts")
            let associatedRequestID = self.selectedShift.suggestedTo!.objectId
            query.getObjectInBackgroundWithId(associatedRequestID!) { (request: PFObject?, error: NSError?) -> Void in
                
                if let request = self.helper.returnObjectAfterErrorCheck(request, error: error) as? PFObject
                {
                    request.deleteInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                        self.delegate.popViewController?()
                        self.delegate.refresh()
                    }
                }
            }
        }
        
        actionList.append(approveSuggestionAction)
    }
    
    func createAcceptSuggestionAction()
    {
        let acceptSuggestionAction = UIAlertAction(title: "Accepteren", style: .Default) { action -> Void in
            
            let query = PFQuery(className: "Shifts")
            
            query.getObjectInBackgroundWithId(self.selectedShift.objectID) { (shift: PFObject?, error: NSError? ) -> Void in
                
                if let shift = self.helper.returnObjectAfterErrorCheck(shift, error: error) as? PFObject
                {
                    // check whether the shift is already accepted by another user
                    if shift["acceptedBy"] == nil
                    {
                        shift["acceptedBy"] = PFUser.currentUser()
                        shift["Status"] = "Awaitting Approval, sug"
                        shift.saveInBackgroundWithBlock() { (succes, error) -> Void in
                            
                            succes ? self.delegate.refresh() : println(error?.description)
                        }
                    }
                }
            }
        }
        
        actionList.append(acceptSuggestionAction)
    }
    
    // update properties in application and in the database
    private func approveShiftChange()
    {
        let query = PFQuery(className: "Shifts")
        query.getObjectInBackgroundWithId(self.selectedShift.objectID) { (shift: PFObject?, error: NSError?) -> Void in
            
            if let shift = self.helper.returnObjectAfterErrorCheck(shift, error: error) as? PFObject
            {
                shift["Status"] = "idle"
                shift["Owner"] = shift["acceptedBy"]
                shift.removeObjectForKey("acceptedBy")
                shift.removeObjectForKey("suggestedTo")
                shift.saveInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                    // self.selectedShift.status = "idle"
                    succes ? self.delegate.refresh() : println(error?.description)
                }
            }
        }
    }
    
    // add a action the the action sheet that revokes a shift from the marketplace and save change in the database
    func createRevokeAction()
    {
        let revokeAction = UIAlertAction(title: "Terugtrekken", style: .Default) { action -> Void in
            
            self.selectedShift.status = "idle"
            
            let query = PFQuery(className: "Shifts")
            query.getObjectInBackgroundWithId(self.selectedShift.objectID) { (shift: PFObject?, error: NSError?) -> Void in
                
                if let shift = self.helper.returnObjectAfterErrorCheck(shift, error: error) as? PFObject
                {
                    shift["Status"] = "idle"
                    shift.saveInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                        
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
                
                if let shift = self.helper.returnObjectAfterErrorCheck(shift, error: error) as? PFObject
                {
                    // check whether the shift is already accepted by another user
                    if shift["acceptedBy"] == nil
                    {
                        shift["acceptedBy"] = PFUser.currentUser()
                        shift["Status"] = "Awaitting Approval"
                        shift.saveInBackgroundWithBlock() { (succes, error) -> Void in
                            
                            succes ? self.delegate.refresh() : println(error?.description)
                        }
                    }
                    else
                    {
                        self.delegate.showAlert?(self.getAlertViewForMissedOppurtunity())
                    }
                }
            }
        }
        
        actionList.append(acceptAction)
    }
    
    // destructive button on the actionsheet
    func createDeleteAction()
    {
        let deleteAction = UIAlertAction(title: "Verwijderen", style: .Destructive) { action -> Void in
            self.delegate.showAlert?(self.getConfirmationAlertView())
        }
        
        actionList.append(deleteAction)
    }
    
    // create ActionSheet that holds all possible actions for a selected cell
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
    
    // create an AlertView that shows in the special case that a displayed shift is already accepted by another user
    func getAlertViewForMissedOppurtunity() -> UIAlertController
    {
        let alertView = UIAlertController(title: nil, message: "Helaas, deze dienst is net voor je weggekaapt.", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Oke, jammer", style: .Cancel) { action -> Void in
            alertView.dismissViewControllerAnimated(true, completion: nil)
            self.delegate.refresh()
        }
        
        alertView.addAction(cancelAction)
        return alertView
    }
    
    // shows UIAlertView warning user that he/she is about to delete something
    func getConfirmationAlertView() -> UIAlertController
    {
        let alertView = UIAlertController(title: nil, message: "Je staat op het punt je diensten te verwijderen.", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Laat maar", style: .Cancel) { action -> Void in
            alertView.dismissViewControllerAnimated(true, completion: nil)
        }
        
        // prefroms the actual deletion.
        let confirmAction = UIAlertAction(title: "I know", style: .Destructive) { action -> Void in
            self.delegate.switchStateOfActivityView(true)
            
            let shiftQuery = PFQuery(className: "Shifts")
                .whereKey("createdFrom", equalTo: self.selectedShift.createdFrom)
                .whereKey("Owner", equalTo: PFUser.currentUser()!)
                // remove this constraint?
                .whereKey("Status", notContainedIn: ["Awaitting Approval", "Supplied"])
            
            shiftQuery.findObjectsInBackgroundWithBlock() { (objects: [AnyObject]?, error: NSError?) -> Void in
                
                if let objects = self.helper.returnObjectAfterErrorCheck(objects, error: error) as? [PFObject]
                {
                    for (i,object) in enumerate(objects)
                    {
                        if i == objects.count - 1
                        {
                            object.deleteInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                                succes ? self.delegate.refresh() : println(error?.description)
                            }
                            return
                        }
                        object.deleteInBackground()
                    }
                }
            }
            
            let fixedShift = PFQuery(className: "FixedShifts").getObjectWithId(self.selectedShift.createdFrom.objectId!)
            fixedShift?.deleteInBackground()
        }
        
        alertView.addAction(confirmAction)
        alertView.addAction(cancelAction)
        return alertView
    }
    
    // function to easily include one or more actions in the actionsheet
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
            case "Delete": createDeleteAction()
            case "Approve Suggestion": createApproveSuggestionAction()
            case "Accept Suggestion": createAcceptSuggestionAction()
            default: break
            }
        }
    }

}