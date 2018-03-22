//
//  UIView+AutoLayoutTests.swift
//  DivingBoardTests
//
//  Created by Jim Rhoades on 3/22/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import XCTest
@testable import DivingBoard

class UIView_AutoLayoutTests: XCTestCase {
    
    func testAddCenteredSubview() {
        let viewFrame = CGRect(x: 0, y: 0, width: 400, height: 400)
        let view = UIView(frame: viewFrame)
        
        let subviewFrame = CGRect(x: 0, y: 0, width: 200, height: 200)
        let subview = UIView(frame: subviewFrame)
        
        view.addCenteredSubview(subview)
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        XCTAssertEqual(view.center, subview.center)
    }
}
