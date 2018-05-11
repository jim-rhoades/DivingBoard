//
//  PhotoCollectionViewControllerTests.swift
//  DivingBoardTests
//
//  Created by Jim Rhoades on 3/12/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import XCTest
@testable import DivingBoard

class PhotoCollectionViewControllerTests: XCTestCase {
    
    var storyboard: UIStoryboard!
    var photoCollectionViewController: PhotoCollectionViewController!
    var stackedLayoutButton: UIBarButtonItem!
    var gridLayoutButton: UIBarButtonItem!
    
    override func setUp() {
        super.setUp()
        let bundle = Bundle(identifier: "com.crushapps.DivingBoard")!
        storyboard = UIStoryboard(name: "DivingBoard", bundle: bundle)
        photoCollectionViewController = storyboard.instantiateViewController(withIdentifier: "PhotoCollectionViewController") as? PhotoCollectionViewController
        
        // note that this does NOT trigger a network request since clientID is nil
        photoCollectionViewController.loadViewIfNeeded()
        
        stackedLayoutButton = photoCollectionViewController.stackedLayoutButton
        gridLayoutButton = photoCollectionViewController.gridLayoutButton
    }
    
    override func tearDown() {
        storyboard = nil
        photoCollectionViewController = nil
        stackedLayoutButton = nil
        gridLayoutButton = nil
        super.tearDown()
    }
    
    // MARK: - Initial state
    
    func testInitialLayoutStyle() {
        XCTAssert(photoCollectionViewController.currentLayoutStyle == .grid,
                  "currentLayoutStyle should initially be set to .grid")
    }
    
    func testInitialLayoutButtonState() {
        XCTAssert(stackedLayoutButton.isEnabled,
                  "stackedLayoutButton should be enabled initially")
        XCTAssert(!gridLayoutButton.isEnabled,
                  "gridLaybuttonButton should NOT be enabled initially")
    }
    
    func testCollectionViewIsNotNilAfterViewDidLoad() {
        XCTAssertNotNil(photoCollectionViewController.collectionView)
    }
    
    // MARK: - Interaction tests
    
    func testStackedLayoutButtonPress() {
        // tap the layout button
        photoCollectionViewController.stackedLayoutButtonPressed(self)
        // test to make sure layout style and button states are correct
        XCTAssert(photoCollectionViewController.currentLayoutStyle == .stacked)
        XCTAssert(!stackedLayoutButton.isEnabled,
                  "stackedLayoutButton should be disabled after tapping stackedLayoutButton")
        XCTAssert(gridLayoutButton.isEnabled,
                  "gridLayoutButton should be enabled after tapping stackedLayoutButton")
    }
    
    func testGridLayoutButtonPress() {
        // tap the layout button
        photoCollectionViewController.gridLayoutButtonPressed(self)
        // test to make sure layout style and button states are correct
        XCTAssert(photoCollectionViewController.currentLayoutStyle == .grid)
        XCTAssert(stackedLayoutButton.isEnabled,
                  "stackedLayoutButton should be enabled after tapping gridLayoutButton")
        XCTAssert(!gridLayoutButton.isEnabled,
                  "gridLayoutButton should be disabled after tapping gridLayoutButton")
    }
    
    // MARK: - UICollectionViewDataSource
    
    func testCollectionViewDataSourceIsNotNil() {
        XCTAssertNotNil(photoCollectionViewController.collectionView?.dataSource)
    }
    
    func testConformsToCollectionViewDataSource() {
        XCTAssert(photoCollectionViewController.conforms(to: UICollectionViewDataSource.self))
        XCTAssert(photoCollectionViewController.responds(to: #selector(photoCollectionViewController.collectionView(_:numberOfItemsInSection:))))
        XCTAssert(photoCollectionViewController.responds(to: #selector(photoCollectionViewController.collectionView(_:cellForItemAt:))))
    }
    
    // MARK: - UICollectionViewDelegate
    
    func testShouldSetCollectionViewDelegate() {
        XCTAssertNotNil(photoCollectionViewController.collectionView?.delegate)
    }
    
    func testConformsToCollectionViewDelegate() {
        XCTAssert(photoCollectionViewController.conforms(to: UICollectionViewDelegate.self))
        XCTAssert(photoCollectionViewController.responds(to: #selector(photoCollectionViewController.collectionView(_:didSelectItemAt:))))
    }
    
    func testConformsToCollectionViewDelegateFlowLayout () {
        XCTAssert(photoCollectionViewController.conforms(to: UICollectionViewDelegateFlowLayout.self))
        XCTAssert(photoCollectionViewController.responds(to: #selector(photoCollectionViewController.collectionView(_:layout:sizeForItemAt:))))
        XCTAssert(photoCollectionViewController.responds(to: #selector(photoCollectionViewController.collectionView(_:layout:minimumLineSpacingForSectionAt:))))
        XCTAssert(photoCollectionViewController.responds(to: #selector(photoCollectionViewController.collectionView(_:layout:minimumInteritemSpacingForSectionAt:))))
    }
}
