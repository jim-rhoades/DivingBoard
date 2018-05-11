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
    
    let clientID = "xxxxxx" // don't need a valid Unsplash app ID for these tests
    
    func testUnsplashPickerCreation() {
        let viewController = ViewControllerForPresentingPicker()
        guard let unsplashPicker = DivingBoard.unsplashPicker(withClientID: clientID,
                                                              presentingViewController: viewController,
                                                              modalPresentationStyle: .popover) as? UINavigationController else {
            
            XCTFail("Failed to create unsplashPicker")
            return
        }
        
        guard let photoCollectionViewController = unsplashPicker.viewControllers.first as? PhotoCollectionViewController else {
            XCTFail("Failed to create unsplashPickerViewController")
            return
        }
        
        guard let _ = photoCollectionViewController.delegate else {
            XCTFail("UnsplashPickerDelegate was not set")
            return
        }
        
        // since a clientID was provided, going any further would trigger a network call,
        // so don't do this here: unsplashPickerViewController.loadViewIfNeeded()
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
        
        XCTAssert(outputURL == expectedOutputURL,
                  "outputURL didn't match expectectOutputURL | outputURL: \(outputURL.absoluteString) | expectedOutputURL: \(expectedOutputURL.absoluteString)")
    }
    
    func testURLForIncrementingDownloadCount() {
        let inputURL: URL! = URL(string: "https://api.unsplash.com/photos/YNQgPXShu7g/download")
        let expectedOutputURL: URL! = URL(string: "https://api.unsplash.com/photos/YNQgPXShu7g/download?client_id=" + "\(clientID)")
        
        let outputURL = DivingBoard.urlForIncrementingDownloadCount(baseURL: inputURL,
                                                                    clientID: clientID)
        
        XCTAssertNotNil(outputURL)
        XCTAssertEqual(expectedOutputURL.absoluteString, outputURL!.absoluteString)
    }
}
