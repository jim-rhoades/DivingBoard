//
//  UIColor+Hex.swift
//  UnsplashPickerController
//
//  Created by Jim Rhoades on 2/21/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import Foundation

public extension UIColor {
    public convenience init(hexString: String) {
        var uppercasedString = hexString.uppercased()
        if uppercasedString.hasPrefix("#") {
            uppercasedString.remove(at: hexString.startIndex)
        }
        
        var rgbValue: UInt32 = 0
        Scanner(string: uppercasedString).scanHexInt32(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
