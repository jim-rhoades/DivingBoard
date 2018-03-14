//
//  DivingBoardTests.swift
//  DivingBoardTests
//
//  Created by Jim Rhoades on 2/15/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import XCTest
@testable import DivingBoard

class DivingBoardTests: XCTestCase {
    
    func testUnsplashPickerCreation() {
        let clientID = "xxxxxx" // ID is unimportant for this
        let viewController = ViewControllerForPresentingPicker()
        guard let unsplashPicker = DivingBoard.unsplashPicker(withClientID: clientID,
                                                              presentingViewController: viewController,
                                                              modalPresentationStyle: .popover) as? UINavigationController else {
            
            XCTFail("Failed to create unsplashPicker")
            return
        }
        
        guard let containerViewController = unsplashPicker.viewControllers.first as? ContainerViewController else {
            XCTFail("Failed to create containerViewController")
            return
        }
        
        guard let _ = containerViewController.delegate else {
            XCTFail("UnsplashPickerDelegate was not set")
            return
        }
        
        // since a clientID was provided, going any further would trigger a network call,
        // so don't do this here: containerViewController.loadViewIfNeeded()
    }
    
    func testUnsplashWebsiteURLWithReferral() {
        guard let inputURL = URL(string: "https://unsplash.com/photos/YNQgPXShu7g") else {
            XCTFail("Failed to create inputURL from string")
            return
        }
        
        guard let expectedOutputURL = URL(string: "https://unsplash.com/photos/YNQgPXShu7g?utm_source=Diving%20Board&utm_medium=referral") else {
            XCTFail("Failed to create expectedOutputURL from string")
            return
        }
        
        let appName = "Diving Board"
        guard let outputURL = DivingBoard.unsplashWebsiteURLWithReferral(baseURL: inputURL, appName: appName) else {
            XCTFail("Failed to retreive URL from unsplashURLWithReferral")
            return
        }
        
        XCTAssert(outputURL == expectedOutputURL, "outputURL didn't match expectectOutputURL | outputURL: \(outputURL.absoluteString) | expectedOutputURL: \(expectedOutputURL.absoluteString)")
    }
}
