//
//  LogInViewController.swift
//  Shifty
//
//  Created by Aron Hammond on 02/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//
//  Controls a empty view that shows a PFLoginViewController. User can sign up,
//  or login. Automatically log's in user that was using the app on termination.

import UIKit
import Parse
import ParseUI

class LogInViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate
{
    override func viewDidAppear(animated: Bool)
    {
        // if there is no user logged-in, show the loginController, else go to tab bar controller
        if (PFUser.currentUser() == nil)
        {
            let loginController = CustomPFLoginViewController()
            loginController.signUpController?.delegate = self
            loginController.delegate = self
            
            presentViewController(loginController, animated: true, completion: nil)
        }
        else
        {
            self.performSegueWithIdentifier(Segue.logIn, sender: nil)
        }
        
        super.viewDidAppear(animated)
    }
    
    // dismiss loginView when log-in is succesfull
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser)
    {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    // auto log-in after sign-up
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser)
    {
        PFUser.logInWithUsername(user.username!, password: user.password!)
        dismissViewControllerAnimated(false, completion: nil)
    }
}
