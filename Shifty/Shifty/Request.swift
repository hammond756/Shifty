//
//  Request.swift
//  Shifty
//
//  Created by Aron Hammond on 16/06/15.
//  Copyright (c) 2015 Aron Hammond. All rights reserved.
//

import Foundation
import Parse

class Request: ContentInterface
{
    convenience required init(parseObject: PFObject)
    {
        let date = parseObject[ParseKey.date] as! NSDate
        let requestedBy = parseObject[ParseKey.requestedBy] as! PFUser
        
        self.init(date: date, owner: requestedBy, objectID: parseObject.objectId!)
    }
}