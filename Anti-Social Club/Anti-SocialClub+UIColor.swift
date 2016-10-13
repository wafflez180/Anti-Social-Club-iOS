//
//  Anti-SocialClub+UIColor.swift
//  Anti-Social Club
//
//  Created by Arthur De Araujo on 10/11/16.
//  Copyright © 2016 Cult of the Old Gods. All rights reserved.
//

import Foundation
import UIKit

extension UIColor{
    class func getCustomBlueColor() -> UIColor{
        // CODE REVIEW:
        // These are magic numbers.
        // They should be defined at the top of the class as constants.
        // Better yet, they should be defined as (255_VALUE / 255), so that you aren't dealing with these tiny numbers.
        // For example:
        // let blueColorRed = 150 / 255
    
        return UIColor(red:0.043, green:0.576 ,blue:0.588 , alpha:1.00)
    }
}

// CODE REVIEW:
// What's up with the naming conventions on these files? It's a bit rediculous, you shouldn't use
// special characters in file names, also there's no need to put "ASC" or "Anti-SocialClub" beforehand.
// The cleanest way to name these files is just to do something like UIColorExtension and UIViewExtension.
// Also, the folder titles should be "View", "Model", and "Controller". This is to emphasize the MVC pattern.
// It is common convention to name directories singularly, so "View" instead of "Views".
