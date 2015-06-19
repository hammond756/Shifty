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

class LogInViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate
{
    var logInSucceeded = false
    
    override func viewDidAppear(animated: Bool)
    {
        if !logInSucceeded
        {
            var loginController = CustomPFLoginViewController()
            loginController.signUpController?.delegate = self
            loginController.delegate = self
            presentViewController(loginController, animated: true, completion: nil)
        }
        else
        {
            self.performSegueWithIdentifier("Logged In", sender: nil)
        }
        
        super.viewDidAppear(animated)
    }
    
    // delegate functions
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser)
    {
        logInSucceeded = true
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser)
    {
        PFUser.logInWithUsername(user.username!, password: user.password!)
        logInSucceeded = true
        dismissViewControllerAnimated(false, completion: nil)
    }
    
}
