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
import SwiftDate
import Darwin

// definiton of protocol that all viewcontrollers incorporating an actionsheet or alertview conform to
@objc protocol ActionSheetDelegate
{
    func getData()
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
        let supplyAction = UIAlertAction(title: Label.supply, style: .Default) { action -> Void in
            
            self.selectedShift.status = Status.supplied
            
            let query = PFQuery(className: ParseClass.shifts)
            query.getObjectInBackgroundWithId(self.selectedShift.objectID) { (shift: PFObject?, error: NSError?) -> Void in
                if let shift = self.helper.returnObjectAfterErrorCheck(shift, error: error) as? PFObject
                {
                    shift[ParseKey.status] = Status.supplied
                    shift.saveInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                        
                        succes ? self.delegate.getData() : println(error?.description)
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
        
        let approveSuggestionAction = UIAlertAction(title: Label.approve, style: .Default) { action -> Void in
            let query = PFQuery(className: ParseClass.requests)
            let associatedRequestID = self.selectedShift.suggestedTo!.objectId
            query.getObjectInBackgroundWithId(associatedRequestID!) { (request: PFObject?, error: NSError?) -> Void in
                
                if let request = self.helper.returnObjectAfterErrorCheck(request, error: error) as? PFObject
                {
                    let suggestedShiftIDs = request["replies"] as! [String]
                    request.deleteInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                        self.delegate.popViewController?()
                        self.delegate.getData()
                        self.helper.updateShiftStatuses(suggestedShiftIDs, newStatus: Status.idle, suggestedTo: nil) { }
                    }
                }
            }
        }
        
        actionList.append(approveSuggestionAction)
    }
    
    func createDisapproveAction()
    {
        let disapproveAction = UIAlertAction(title: Label.disapprove, style: .Default) { action -> Void in
            // =nil may be irrelevant
            self.selectedShift.acceptedBy = nil
            self.helper.updateShiftStatuses([self.selectedShift.objectID], newStatus: Status.supplied, suggestedTo: nil) { () -> Void in
                self.delegate.getData()
            }
        }
        
        actionList.append(disapproveAction)
    }
    
    // WAAROM?????? Owner verandert out of the blue
    func createDisapproveSuggestionAction()
    {
        let disapproveAction = UIAlertAction(title: Label.disapprove, style: .Default) { action -> Void in
            // acceptedBy=nil may be irrelevant
            self.selectedShift.acceptedBy = nil
            self.helper.updateShiftStatuses([self.selectedShift.objectID], newStatus: Status.idle, suggestedTo: nil) { () -> Void in
                self.delegate.getData()
            }
        }
        
        actionList.append(disapproveAction)
    }
    
    func createAcceptSuggestionAction()
    {
        let acceptSuggestionAction = UIAlertAction(title: Label.accept, style: .Default) { action -> Void in
            
            let query = PFQuery(className: ParseClass.shifts)
            
            query.getObjectInBackgroundWithId(self.selectedShift.objectID) { (shift: PFObject?, error: NSError? ) -> Void in
                
                if let shift = self.helper.returnObjectAfterErrorCheck(shift, error: error) as? PFObject
                {
                    // check whether the shift is already accepted by another user
                    if shift[ParseKey.acceptedBy] == nil
                    {
                        shift[ParseKey.acceptedBy] = PFUser.currentUser()
                        shift[ParseKey.status] = Status.awaittingFromSug
                        shift.saveInBackgroundWithBlock() { (succes, error) -> Void in
                            
                            succes ? self.delegate.getData() : println(error?.description)
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
        let query = PFQuery(className: ParseClass.shifts)
        query.getObjectInBackgroundWithId(self.selectedShift.objectID) { (shift: PFObject?, error: NSError?) -> Void in
            
            if let shift = self.helper.returnObjectAfterErrorCheck(shift, error: error) as? PFObject
            {
                shift[ParseKey.status] = Status.idle
                shift[ParseKey.owner] = shift[ParseKey.acceptedBy]
                shift.removeObjectForKey(ParseKey.acceptedBy)
                shift.removeObjectForKey(ParseKey.suggestedTo)
                shift.saveInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                    // self.selectedShift.status = Status.idle
                    succes ? self.delegate.getData() : println(error?.description)
                }
            }
        }
    }
    
    // add a action the the action sheet that revokes a shift from the marketplace and save change in the database
    func createRevokeAction()
    {
        let revokeAction = UIAlertAction(title: Label.revoke, style: .Default) { action -> Void in
            
            self.selectedShift.status = Status.idle
            
            let query = PFQuery(className: ParseClass.shifts)
            query.getObjectInBackgroundWithId(self.selectedShift.objectID) { (shift: PFObject?, error: NSError?) -> Void in
                
                if let shift = self.helper.returnObjectAfterErrorCheck(shift, error: error) as? PFObject
                {
                    shift[ParseKey.status] = Status.idle
                    shift.saveInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                        
                        succes ? self.delegate.getData() : println(error?.description)
                    }
                }
            }
        }
        
        actionList.append(revokeAction)
    }
    
    // add a action the the action sheet that accepts a supplied shift and save change in the database
    func createAcceptAction()
    {
        let acceptAction = UIAlertAction(title: Label.accept, style: .Default) { action -> Void in
            
            let query = PFQuery(className: ParseClass.shifts)
            
            query.getObjectInBackgroundWithId(self.selectedShift.objectID) { (shift: PFObject?, error: NSError? ) -> Void in
                
                if let shift = self.helper.returnObjectAfterErrorCheck(shift, error: error) as? PFObject
                {
                    // check whether the shift is already accepted by another user
                    self.helper.checkIfDateIsTaken(self.selectedShift.date) { taken -> Void in
                        if taken
                        {
                            self.delegate.showAlert?(self.getAlertViewForImpossibleAcceptAction())
                            return
                        }
                        else if (shift[ParseKey.acceptedBy] == nil) && (shift[ParseKey.owner] as? PFUser != PFUser.currentUser())
                        {
                            shift[ParseKey.acceptedBy] = PFUser.currentUser()
                            shift[ParseKey.status] = Status.awaitting
                            shift.saveInBackgroundWithBlock() { (succes, error) -> Void in
                                
                                succes ? self.delegate.getData() : println(error?.description)
                            }
                        }
                        else if shift[ParseKey.acceptedBy] != nil
                        {
                            self.delegate.showAlert?(self.getAlertViewForMissedOppurtunity())
                        }
                    }
                }
            }
        }
        
        actionList.append(acceptAction)
    }
    
    // destructive button on the actionsheet
    func createDeleteAction()
    {
        let deleteAction = UIAlertAction(title: Label.delete, style: .Destructive) { action -> Void in
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
        
        let cancelAction = UIAlertAction(title: Label.cancel, style: .Cancel) { action -> Void in
            actionSheetController.dismissViewControllerAnimated(true, completion: nil)
        }
        
        actionSheetController.addAction(cancelAction)
        return actionSheetController
    }
    
    // create an AlertView that shows in the special case that a displayed shift is already accepted by another user
    func getAlertViewForMissedOppurtunity() -> UIAlertController
    {
        let alertView = UIAlertController(title: nil, message: "Helaas, deze dienst is net voor je weggekaapt.", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: Label.cancel, style: .Cancel) { action -> Void in
            alertView.dismissViewControllerAnimated(true, completion: nil)
            self.delegate.getData()
        }
        
        alertView.addAction(cancelAction)
        return alertView
    }
    
    func getAlertViewForImpossibleAcceptAction() -> UIAlertController
    {
        let alertView = UIAlertController(title: nil, message: "Je werkt al op deze dag", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: Label.cancel, style: .Cancel) { action -> Void in
            alertView.dismissViewControllerAnimated(true, completion: nil)
        }
    
        alertView.addAction(cancelAction)
        return alertView
    }
    
    // shows UIAlertView warning user that he/she is about to delete something
    func getConfirmationAlertView() -> UIAlertController
    {
        let alertView = UIAlertController(title: nil, message: "Je staat op het punt je diensten te verwijderen.", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: Label.cancel, style: .Cancel) { action -> Void in
            alertView.dismissViewControllerAnimated(true, completion: nil)
        }
        
        // prefroms the actual deletion.
        let confirmAction = UIAlertAction(title: Label.delete, style: .Destructive) { action -> Void in
            self.delegate.switchStateOfActivityView(true)
            
            let shiftQuery = PFQuery(className: ParseClass.shifts)
                .whereKey(ParseKey.createdFrom, equalTo: self.selectedShift.createdFrom)
                .whereKey(ParseKey.owner, equalTo: PFUser.currentUser()!)
                // remove this constraint?
                .whereKey(ParseKey.status, notContainedIn: [Status.awaitting, Status.supplied])
            
            shiftQuery.findObjectsInBackgroundWithBlock() { (objects: [AnyObject]?, error: NSError?) -> Void in
                
                if let objects = self.helper.returnObjectAfterErrorCheck(objects, error: error) as? [PFObject]
                {
                    for (i,object) in enumerate(objects)
                    {
                        if i == objects.count - 1
                        {
                            object.deleteInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                                succes ? self.delegate.getData() : println(error?.description)
                            }
                            return
                        }
                        object.deleteInBackground()
                    }
                }
            }
            
            let fixedShift = PFQuery(className: ParseClass.fixed).getObjectWithId(self.selectedShift.createdFrom.objectId!)
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
                case Action.supply:         createSupplyAction()
                case Action.revoke:         createRevokeAction()
                case Action.approve:        createApproveAction()
                case Action.accept:         createAcceptAction()
                case Action.delete:         createDeleteAction()
                case Action.approveSug:     createApproveSuggestionAction()
                case Action.acceptSug:      createAcceptSuggestionAction()
                case Action.disapprove:     createDisapproveAction()
                case Action.disapproveSug:  createDisapproveSuggestionAction()
                default: break
            }
        }
    }

}