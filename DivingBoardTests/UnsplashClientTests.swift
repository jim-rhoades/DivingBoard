//
//  UnsplashClientTests.swift
//  DivingBoardTests
//
//  Created by Jim Rhoades on 3/13/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import XCTest
@testable import DivingBoard

class MockURLSession: URLSessionProtocol {
    var nextDataTask = MockURLSessionDataTask()
    // TODO: this 'lastURL' part seems only necessary if testing dataTask with URLRequest?
    private (set) var lastURL: URL?
    
    func dataTask(with url: URL, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        lastURL = url
        return nextDataTask
    }
}

class MockURLSessionDataTask: URLSessionDataTaskProtocol {
    private (set) var resumeWasCalled = false
    
    func resume() {
        resumeWasCalled = true
    }
}

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
    
    func testResumeWasCalled() {
        let session = MockURLSession()
        let unsplashClient = UnsplashClient(session: session)
        
        let dataTask = MockURLSessionDataTask()
        session.nextDataTask = dataTask
        
        let collectionType = CollectionType.new
        guard let url = UnsplashClient.urlForJSONRequest(withClientID: clientID,
                                                         collectionType: collectionType,
                                                         resultsPerPage: 40,
                                                         pageNumber: 1) else {
                                                            XCTFail("failed to get URL for request")
                                                            return
        }
        
        unsplashClient.requestPhotosFor(url: url, collectionType: collectionType) { _, _, _ in }
        
        XCTAssert(dataTask.resumeWasCalled)
    }
    
    
    // makes a network call, so I don't want to use this... but shows it's working for now
    /*
    func testReceivesData() {
        let unsplashClient = UnsplashClient()
        let collectionType = CollectionType.new
        guard let url = UnsplashClient.urlForJSONRequest(withClientID: clientID,
                                                         collectionType: collectionType,
                                                         resultsPerPage: 40,
                                                         pageNumber: 1) else {
                                                            XCTFail("failed to get URL for request")
                                                            return
        }
        
        print(url.absoluteString)
        
        let promise = expectation(description: "something")
        unsplashClient.requestPhotosFor(url: url, collectionType: collectionType) { requestedPhotos, searchResultsTotalPages, error in
            
            promise.fulfill()
            
            // handle errors
            if let error = error {
                print("ERROR: \(error.localizedDescription)")
            }
            
            if let _ = requestedPhotos {
                // currently this will never happen
                // how will I provide fake data?
                print("RECEIVED PHOTOS")
            }
            
            if collectionType == .search {
                XCTAssertNotNil(searchResultsTotalPages)
            }
        }
        
        waitForExpectations(timeout: 5)
    }
    */
    
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
