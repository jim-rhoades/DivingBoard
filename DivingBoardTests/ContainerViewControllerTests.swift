//
//  ContainerViewControllerTests.swift
//  DivingBoardTests
//
//  Created by Jim Rhoades on 3/9/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import XCTest
@testable import DivingBoard

class ContainerViewControllerTests: XCTestCase {
    
    var storyboard: UIStoryboard!
    var containerViewController: ContainerViewController!
    var stackedLayoutButton: UIBarButtonItem!
    var gridLayoutButton: UIBarButtonItem!
    
    override func setUp() {
        super.setUp()
        let bundle = Bundle(identifier: "com.crushapps.DivingBoard")!
        storyboard = UIStoryboard(name: "Main", bundle: bundle)
        containerViewController = storyboard.instantiateViewController(withIdentifier: "ContainerViewController") as? ContainerViewController
        
        // note that this does NOT trigger a network request since clientID is nil
        // and nil is passed on to newViewController.clientID
        containerViewController.loadViewIfNeeded()
        
        stackedLayoutButton = containerViewController.stackedLayoutButton
        gridLayoutButton = containerViewController.gridLayoutButton
    }
    
    override func tearDown() {
        storyboard = nil
        containerViewController = nil
        stackedLayoutButton = nil
        gridLayoutButton = nil
        super.tearDown()
    }
    
    // MARK: Initial state tests
    
    func testInitialLayoutStyle() {
        XCTAssert(containerViewController.currentLayoutStyle == .grid, "currentLayoutStyle should initially be set to .grid")
    }
    
    func testInitialLayoutButtonState() {
        XCTAssert(stackedLayoutButton.isEnabled, "stackedLayoutButton should be enabled initially")
        XCTAssert(!gridLayoutButton.isEnabled, "gridLaybuttonButton should NOT be enabled initially")
    }
    
    func testInitialCollectionTypeIndices() {
        XCTAssert(containerViewController.toCollectionTypeIndex == 0, "toCollectionIndex should initially be set to 0")
        XCTAssert(containerViewController.fromCollectionTypeIndex == 0, "fromCollectionTypeIndex should initially be set to 0")
    }
    
    func testCollectionTypePickerViewExists() {
        XCTAssertNotNil(containerViewController.collectionTypePickerView)
    }
    
    func testCollectionTypePickerViewDelegate() {
        XCTAssert(containerViewController.collectionTypePickerView.delegate === containerViewController, "collectionTypePickerView's delegate was not set as the containerViewController")
    }
    
    func testInitialChildViewControllerState() {
        XCTAssertNotNil(containerViewController.newViewController, "newViewController should be the initial child view controller, but was nil")
        XCTAssertNil(containerViewController.curatedViewController, "curatedViewController should be nil initially")
        XCTAssertNil(containerViewController.searchViewController, "searchViewController should be nil initially")
    }
    
    // MARK: - Interaction tests
    
    func testStackedLayoutButtonPress() {
        // tap the layout button
        containerViewController.stackedLayoutButtonPressed(self)
        // test to make sure layout style and button states are correct
        XCTAssert(containerViewController.currentLayoutStyle == .stacked)
        XCTAssert(!stackedLayoutButton.isEnabled, "stackedLayoutButton should be disabled after tapping stackedLayoutButton")
        XCTAssert(gridLayoutButton.isEnabled, "gridLayoutButton should be enabled after tapping stackedLayoutButton")
    }
    
    func testGridLayoutButtonPress() {
        // tap the layout button
        containerViewController.gridLayoutButtonPressed(self)
        // test to make sure layout style and button states are correct
        XCTAssert(containerViewController.currentLayoutStyle == .grid)
        XCTAssert(stackedLayoutButton.isEnabled, "stackedLayoutButton should be enabled after tapping gridLayoutButton")
        XCTAssert(!gridLayoutButton.isEnabled, "gridLayoutButton should be disabled after tapping gridLayoutButton")
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate
    
    func testConformsToPopoverPresentationControllerDelegate() {
        XCTAssert(containerViewController.conforms(to: UIPopoverPresentationControllerDelegate.self))
    }
}
