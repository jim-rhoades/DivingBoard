//
//  UIColor+HexTests.swift
//  DivingBoardTests
//
//  Created by Jim Rhoades on 3/9/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import XCTest

class UIColor_HexTests: XCTestCase {
    
    func testHexToUIColor() {
        let colors: [String: UIColor] = ["f00": UIColor.red,
                                         "#f00": UIColor.red,
                                         "ff0000": UIColor.red,
                                         "#ff0000": UIColor.red,
                                         "#00FF00": UIColor.green,
                                         "#0000FF": UIColor.blue,
                                         "#101010": UIColor(red: 16.0/255.0, green: 16.0/255.0, blue: 16.0/255.0, alpha: 1.0),
                                         "#987654": UIColor(red: 152.0/255.0, green: 118.0/255.0, blue: 84.0/255.0, alpha: 1.0),
                                         "6fc": UIColor(red: 102.0/255.0, green: 1.0, blue: 204.0/255.0, alpha: 1.0)]
        
        for color in colors {
            XCTAssertEqual(UIColor(hexString: color.key), color.value)
        }
    }
}
