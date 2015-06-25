//
//  CustomPFLoginViewController.swift
//  Shifty
//
//  Created by Aron Hammond on 19/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import Foundation
import ParseUI

class CustomPFLoginViewController: PFLogInViewController
{
    // set properties vor loginView
    override func viewDidLoad()
    {
        //self.view.backgroundColor = UIColor.darkGrayColor()
        let shiftyLogoView = UIImageView(image: UIImage(named: "SHIFTY-logo.png"))
        shiftyLogoView.contentMode = UIViewContentMode.ScaleAspectFit
        
        self.logInView?.logo?.contentMode = .ScaleAspectFit
        (self.logInView?.logo as! UIImageView).image = shiftyLogoView.image
        (self.signUpController?.signUpView?.logo as! UIImageView).image = shiftyLogoView.image
        
        self.logInView?.backgroundColor = .darkGrayColor()
        self.signUpController?.signUpView?.backgroundColor = .darkGrayColor()
        
        super.viewDidLoad()
    }
    
    // settings for subViews
    override func viewDidLayoutSubviews()
    {
        self.logInView?.usernameField?.backgroundColor = .grayColor()
        self.logInView?.passwordField?.backgroundColor = .grayColor()
        self.logInView?.usernameField?.separatorColor = .darkGrayColor()
        self.logInView?.passwordField?.separatorColor = .darkGrayColor()
        
        self.signUpController?.signUpView?.emailField?.backgroundColor = .grayColor()
        self.signUpController?.signUpView?.usernameField?.backgroundColor = .grayColor()
        self.signUpController?.signUpView?.passwordField?.backgroundColor = .grayColor()
        self.signUpController?.signUpView?.emailField?.separatorColor = .darkGrayColor()
        self.signUpController?.signUpView?.usernameField?.separatorColor = .darkGrayColor()
        self.signUpController?.signUpView?.passwordField?.separatorColor = .darkGrayColor()
    }
}