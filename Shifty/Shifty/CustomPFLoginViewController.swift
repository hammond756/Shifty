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
    override func viewDidLoad()
    {
        self.view.backgroundColor = UIColor.darkGrayColor()
        
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews()
    {
        self.logInView?.usernameField?.backgroundColor = .grayColor()
        self.logInView?.passwordField?.backgroundColor = .grayColor()
        self.logInView?.passwordField?.separatorStyle = .None
        self.logInView?.usernameField?.separatorStyle = .None
    }
}