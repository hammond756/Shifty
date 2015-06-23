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
    
    func returnObjectAfterErrorCheck(object: AnyObject?, error: NSError?) -> AnyObject?
    {
        if error != nil
        {
            println(error?.description)
            return nil
        }
        
        return object
    }
    
    // split an array of generic type T into a two-dimensional array
    func splitIntoSections<T: HasDate>(var array: [T], sections: [String]) -> [[T]]
    {
        var sectionedArray = [[T]]()
        array.sort() { $0.date < $1.date }
        
        // get all elemenents where the week number equals that of the current section
        for section in sections
        {
            sectionedArray.append(array.filter() { $0.getWeekOfYear() == section })
        }
        
        return sectionedArray
    }
    
    // generate array of section titles from an array of generic type T
    func getSections<T: HasDate>(var array: [T]) -> [String]
    {
        var sections = [String]()
        array.sort() { $0.date < $1.date }
        
        for element in array
        {
            let weekOfYear = element.getWeekOfYear()
            
            if !contains(sections, weekOfYear)
            {
                sections.append(weekOfYear)
            }
        }
        
        return sections
    }
}
