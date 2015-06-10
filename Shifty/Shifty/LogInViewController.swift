//
//  LogInViewController.swift
//  Shifty
//
//  Created by Aron Hammond on 02/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class LogInViewController: UIViewController, PFLogInViewControllerDelegate
{
    var logInSucceeded = false
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if !logInSucceeded
        {
            var loginController = PFLogInViewController()
            loginController.delegate = self
            presentViewController(loginController, animated: true, completion: nil)
        }
        else
        {
            self.performSegueWithIdentifier("Logged In", sender: nil)
        }
    }
    
    
    // delegate functions
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser)
    {
        logInSucceeded = true
        dismissViewControllerAnimated(false, completion: nil)
    }

}
