//
//  UnsplashClientTests.swift
//  DivingBoardTests
//
//  Created by Jim Rhoades on 3/13/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import XCTest
@testable import DivingBoard

class UnsplashClientTests: XCTestCase {
    
    let clientID = "1234567890"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testURLForJSONRequestWithNilClientID() {
        let outputURL = UnsplashClient.urlForJSONRequest(withClientID: nil,
                                                         collectionType: .new,
                                                         resultsPerPage: 40,
                                                         pageNumber: 1)
        XCTAssertNil(outputURL)
    }
    
    func testURLForJSONRequestWithCollectionTypeNew() {
        let expectedURLString = "https://api.unsplash.com/photos?client_id=" + "\(clientID)" + "&per_page=40&page=1"
        let expectedOutputURL: URL! = URL(string: expectedURLString)
        
        let outputURL = UnsplashClient.urlForJSONRequest(withClientID: clientID,
                                                         collectionType: .new,
                                                         resultsPerPage: 40,
                                                         pageNumber: 1)
        
        XCTAssertNotNil(outputURL)
        XCTAssertEqual(expectedOutputURL.absoluteString, outputURL!.absoluteString)
    }
    
    func testURLForJSONRequestWithCollectionTypeCurated() {
        let expectedURLString = "https://api.unsplash.com/photos/curated?client_id=" + "\(clientID)" + "&per_page=30&page=3"
        let expectedOutputURL: URL! = URL(string: expectedURLString)
        
        let outputURL = UnsplashClient.urlForJSONRequest(withClientID: clientID,
                                                         collectionType: .curated,
                                                         resultsPerPage: 30,
                                                         pageNumber: 3)
        
        XCTAssertNotNil(outputURL)
        XCTAssertEqual(expectedOutputURL.absoluteString, outputURL!.absoluteString)
    }
    
    func testURLForJSONRequestWithCollectionTypeSearch() {
        let searchPhrase = "puppies"
        let expectedURLString = "https://api.unsplash.com/search/photos?client_id=" + "\(clientID)" + "&per_page=40&page=1&query=" + "\(searchPhrase)"
        let expectedOutputURL: URL! = URL(string: expectedURLString)
        
        let outputURL = UnsplashClient.urlForJSONRequest(withClientID: clientID,
                                                         collectionType: .search,
                                                         resultsPerPage: 40,
                                                         pageNumber: 1,
                                                         searchPhrase: searchPhrase)
        
        XCTAssertNotNil(outputURL)
        XCTAssertEqual(expectedOutputURL.absoluteString, outputURL!.absoluteString)
    }
    
    func testURLForIncrementingDownloadCount() {
        let inputURL: URL! = URL(string: "https://api.unsplash.com/photos/YNQgPXShu7g/download")
        let expectedOutputURL: URL! = URL(string: "https://api.unsplash.com/photos/YNQgPXShu7g/download?client_id=" + "\(clientID)")
        
        let outputURL = UnsplashClient.urlForIncrementingDownloadCount(baseURL: inputURL,
                                                                       clientID: clientID)
        
        XCTAssertNotNil(outputURL)
        XCTAssertEqual(expectedOutputURL.absoluteString, outputURL!.absoluteString)
    }
}
