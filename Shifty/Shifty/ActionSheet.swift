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
    
    init(shift: Shift, delegate: ActionSheetDelegate)
    {
        selectedShift = shift
        self.delegate = delegate
    }
    
    func createSupplyAction()
    {
        let supplyAction = UIAlertAction(title: "Aanbieden", style: .Default) { action -> Void in
            
            self.selectedShift.status = "Supplied"
            
            let query = PFQuery(className: "Shifts")
            query.getObjectInBackgroundWithId(self.selectedShift.objectID) { (shift: PFObject?, error: NSError?) -> Void in
                
                if error != nil
                {
                    println(error?.description)
                }
                else if let shift = shift
                {
                    shift["Status"] = "Supplied"
                    shift.saveInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                        
                        if error != nil
                        {
                            println(error?.description)
                        }
                        else
                        {
                            self.delegate.refresh()
                        }
                    }
                }
            }
        }
        
        actionList.append(supplyAction)
    }
    
    func createApproveAction()
    {
        let approveAction = UIAlertAction(title: "Goedkeuren", style: .Default) { action -> Void in
            self.selectedShift.status = "idle"
            
            let query = PFQuery(className: "Shifts")
            query.getObjectInBackgroundWithId(self.selectedShift.objectID) { (shift: PFObject?, error: NSError?) -> Void in
                
                if error != nil
                {
                    println(error?.description)
                }
                else if let shift = shift
                {
                    shift["Status"] = "idle"
                    shift["Owner"] = shift["acceptedBy"]
                    
                    shift.saveInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                        
                        if error != nil
                        {
                            println(error?.description)
                        }
                        else
                        {
                            self.delegate.refresh()
                        }
                    }
                }
            }
        }
        
        actionList.append(approveAction)
    }
    
    func createRevokeAction()
    {
        let revokeAction = UIAlertAction(title: "Terugrekken", style: .Default) { action -> Void in
            
            self.selectedShift.status = "idle"
            
            let query = PFQuery(className: "Shifts")
            query.getObjectInBackgroundWithId(self.selectedShift.objectID) { (shift: PFObject?, error: NSError?) -> Void in
                
                if error != nil
                {
                    println(error?.description)
                }
                else if let shift = shift
                {
                    shift["Status"] = "idle"
                    
                    shift.saveInBackgroundWithBlock() { (succes: Bool, error: NSError?) -> Void in
                        
                        if error != nil
                        {
                            println(error?.description)
                        }
                        else
                        {
                            self.delegate.refresh()
                        }
                    }
                }
                
            }
        }
        
        actionList.append(revokeAction)
    }
    
    func createAcceptAction()
    {
        let acceptAction = UIAlertAction(title: "Accepteren", style: .Default) { action -> Void in
            
            let query = PFQuery(className: "Shifts")
            
            query.getObjectInBackgroundWithId(self.selectedShift.objectID) { (shift: PFObject?, error: NSError? ) -> Void in
                
                if error != nil
                {
                    println(error?.description)
                }
                else if let shift = shift
                {
                    shift["Status"] = "Awaitting Approval"
                    shift["acceptedBy"] = PFUser.currentUser()
                    shift.saveInBackgroundWithBlock() { (succes, error) -> Void in
                        
                        if error != nil
                        {
                            println(error?.description)
                        }
                        else
                        {
                            self.delegate.refresh()
                        }
                    }
                }
            }
        }
        
        actionList.append(acceptAction)
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