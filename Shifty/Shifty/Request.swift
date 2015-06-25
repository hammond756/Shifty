//
//  Request.swift
//  Shifty
//
//  Created by Aron Hammond on 16/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//
//  Class that represents a request made by a user. It will be displayed
//  in the GezochtViewController for all others to see. They can send
//  suggestions (shifts which they offer to the owner of the Request).

import Foundation
import Parse

class Request: ContentInterface
{
    // initialize instance from PFObject
    convenience required init(parseObject: PFObject)
    {
        let date = parseObject[ParseKey.date] as! NSDate
        let requestedBy = parseObject[ParseKey.requestedBy] as! PFUser
        
        self.init(date: date, owner: requestedBy, objectID: parseObject.objectId!)
    }
}