//
//  UIColor+Hex.swift
//  DivingBoard
//
//  Created by Jim Rhoades on 2/21/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import UIKit

public extension UIColor {
    public convenience init(hexString: String) {
        var uppercasedString = hexString.uppercased()
        if uppercasedString.hasPrefix("#") {
            uppercasedString.remove(at: hexString.startIndex)
        }
        
        // convert 3 character hex strings to 6 characters
        if uppercasedString.count == 3 {
            let c0 = String(Array(uppercasedString)[0])
            let c1 = String(Array(uppercasedString)[1])
            let c2 = String(Array(uppercasedString)[2])
            uppercasedString = c0 + c0 + c1 + c1 + c2 + c2
        }
        
        var rgbValue: UInt32 = 0
        Scanner(string: uppercasedString).scanHexInt32(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
