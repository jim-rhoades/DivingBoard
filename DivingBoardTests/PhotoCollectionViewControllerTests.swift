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
    
    override func setUp() {
        super.setUp()
        let bundle = Bundle(identifier: "com.crushapps.DivingBoard")!
        storyboard = UIStoryboard(name: "DivingBoard", bundle: bundle)
        photoCollectionViewController = storyboard.instantiateViewController(withIdentifier: "PhotoCollectionViewController") as? PhotoCollectionViewController
        
        // note that this does NOT trigger a network request since clientID is nil
        photoCollectionViewController.loadViewIfNeeded()
    }
    
    override func tearDown() {
        storyboard = nil
        photoCollectionViewController = nil
        super.tearDown()
    }
    
    // MARK: - Initial state
    
    func testCollectionViewIsNotNilAfterViewDidLoad() {
        XCTAssertNotNil(photoCollectionViewController.collectionView)
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
