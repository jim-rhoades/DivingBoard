//
//  UnsplashPickerViewControllerTests.swift
//  DivingBoardTests
//
//  Created by Jim Rhoades on 3/9/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import XCTest
@testable import DivingBoard

class UnsplashPickerViewControllerTests: XCTestCase {
    
    var storyboard: UIStoryboard!
    var unsplashPickerViewController: UnsplashPickerViewController!
    var stackedLayoutButton: UIBarButtonItem!
    var gridLayoutButton: UIBarButtonItem!
    
    override func setUp() {
        super.setUp()
        let bundle = Bundle(identifier: "com.crushapps.DivingBoard")!
        storyboard = UIStoryboard(name: "DivingBoard", bundle: bundle)
        unsplashPickerViewController = storyboard.instantiateViewController(withIdentifier: "UnsplashPickerViewController") as? UnsplashPickerViewController
        
        // note that this does NOT trigger a network request since clientID is nil
        // and nil is passed on to newViewController.clientID
        unsplashPickerViewController.loadViewIfNeeded()
        
        stackedLayoutButton = unsplashPickerViewController.stackedLayoutButton
        gridLayoutButton = unsplashPickerViewController.gridLayoutButton
    }
    
    override func tearDown() {
        storyboard = nil
        unsplashPickerViewController = nil
        stackedLayoutButton = nil
        gridLayoutButton = nil
        super.tearDown()
    }
    
    // MARK: Initial state tests
    
    func testInitialLayoutStyle() {
        XCTAssert(unsplashPickerViewController.currentLayoutStyle == .grid,
                  "currentLayoutStyle should initially be set to .grid")
    }
    
    func testInitialLayoutButtonState() {
        XCTAssert(stackedLayoutButton.isEnabled,
                  "stackedLayoutButton should be enabled initially")
        XCTAssert(!gridLayoutButton.isEnabled,
                  "gridLaybuttonButton should NOT be enabled initially")
    }
    
    func testInitialCollectionTypeIndices() {
        XCTAssert(unsplashPickerViewController.toCollectionTypeIndex == 0,
                  "toCollectionIndex should initially be set to 0")
        XCTAssert(unsplashPickerViewController.fromCollectionTypeIndex == 0,
                  "fromCollectionTypeIndex should initially be set to 0")
    }
    
    func testCollectionTypePickerViewExists() {
        XCTAssertNotNil(unsplashPickerViewController.collectionTypePickerView)
    }
    
    func testCollectionTypePickerViewDelegate() {
        XCTAssert(unsplashPickerViewController.collectionTypePickerView.delegate === unsplashPickerViewController,
                  "collectionTypePickerView's delegate was not set as the unsplashPickerViewController")
    }
    
    func testInitialChildViewControllerState() {
        XCTAssertNotNil(unsplashPickerViewController.newViewController,
                        "newViewController should be the initial child view controller, but was nil")
        XCTAssertNil(unsplashPickerViewController.curatedViewController,
                     "curatedViewController should be nil initially")
        XCTAssertNil(unsplashPickerViewController.searchViewController,
                     "searchViewController should be nil initially")
    }
    
    // MARK: - Interaction tests
    
    func testStackedLayoutButtonPress() {
        // tap the layout button
        unsplashPickerViewController.stackedLayoutButtonPressed(self)
        // test to make sure layout style and button states are correct
        XCTAssert(unsplashPickerViewController.currentLayoutStyle == .stacked)
        XCTAssert(!stackedLayoutButton.isEnabled,
                  "stackedLayoutButton should be disabled after tapping stackedLayoutButton")
        XCTAssert(gridLayoutButton.isEnabled,
                  "gridLayoutButton should be enabled after tapping stackedLayoutButton")
    }
    
    func testGridLayoutButtonPress() {
        // tap the layout button
        unsplashPickerViewController.gridLayoutButtonPressed(self)
        // test to make sure layout style and button states are correct
        XCTAssert(unsplashPickerViewController.currentLayoutStyle == .grid)
        XCTAssert(stackedLayoutButton.isEnabled,
                  "stackedLayoutButton should be enabled after tapping gridLayoutButton")
        XCTAssert(!gridLayoutButton.isEnabled,
                  "gridLayoutButton should be disabled after tapping gridLayoutButton")
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate
    
    func testConformsToPopoverPresentationControllerDelegate() {
        XCTAssert(unsplashPickerViewController.conforms(to: UIPopoverPresentationControllerDelegate.self))
    }
    
    // MARK: - CollectionTypePickerViewDelegate
    
    func testCollectionTypeChangeToCurated() {
        unsplashPickerViewController.collectionTypeChanged(.curated)
        XCTAssertNotNil(unsplashPickerViewController.curatedViewController)
        
        // currentlyDisplayedViewController isn't set immediately due to the transition animation
        // forcing the assertion to happen on the next runloop ensures that it's set
        let promise = expectation(description: "currentlyDisplayedViewController is expected to be curatedViewController")
        DispatchQueue.main.async {
            promise.fulfill()
        }
        waitForExpectations(timeout: 1)
 
        XCTAssert(unsplashPickerViewController.currentlyDisplayedViewController === unsplashPickerViewController.curatedViewController,
                  "curatedViewController was not the currentlyDisplayedViewController")
    }
    
    func testCollectionTypeChangeToSearch() {
        unsplashPickerViewController.collectionTypeChanged(.search)
        XCTAssertNotNil(unsplashPickerViewController.searchViewController)
        
        // currentlyDisplayedViewController isn't set immediately due to the transition animation
        // forcing the assertion to happen on the next runloop ensures that it's set
        let promise = expectation(description: "currentlyDisplayedViewController is expected to be searchViewController")
        DispatchQueue.main.async {
            promise.fulfill()
        }
        waitForExpectations(timeout: 1)
        
        XCTAssert(unsplashPickerViewController.currentlyDisplayedViewController === unsplashPickerViewController.searchViewController,
                  "searchViewController was not the currentlyDisplayedViewController")
    }
}
