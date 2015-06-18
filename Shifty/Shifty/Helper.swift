//
//  Helper.swift
//  Shifty
//
//  Created by Aron Hammond on 17/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import Foundation
import Parse
import UIKit

class Helper
{
    // log out current user and show the loginViewController
    func logOut(viewController: UIViewController)
    {
        PFUser.logOut()
        
        let loginViewController = viewController.storyboard!.instantiateViewControllerWithIdentifier("Login") as! LogInViewController
        UIApplication.sharedApplication().keyWindow?.rootViewController = loginViewController
    }
    
    // set properties for the accessoryView of a tableViewCell
    func createTimeLabel(time: String) -> UILabel
    {
        var label = UILabel()
        label.font = UIFont.systemFontOfSize(14)
        label.textAlignment = NSTextAlignment.Center
        label.text = time
        label.sizeToFit()
        
        return label
    }
    
}
