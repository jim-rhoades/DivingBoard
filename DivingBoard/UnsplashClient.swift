//
//  UnsplashClient.swift
//  DivingBoard
//
//  Created by Jim Rhoades on 3/13/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import Foundation

class UnsplashClient {
    
    private let session: URLSessionProtocol
    typealias completionHandler = (_ photos: [UnsplashPhoto]?, _ searchResultsTotalPages: Int?, _ error: Error?) -> Void
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    /**
     Used to request photos via the Unsplash API.
     
     - Parameter url: The URL to use for the API request. (Which you can get by using 'UnsplashClient.urlForJSONRequest'.)
     - Parameter collectionType: The CollectionType to use for the API call.
     - Parameter completionHandler: Invoked when the request has completed. If successful it provides an array of UnsplashPhoto's and optional searchResultsTotalPages Int, otherwise an Error is returned.
     */
    func requestPhotosFor(url: URL, collectionType: CollectionType, completionHandler: @escaping completionHandler) {
        let dataTask = session.dataTask(with: url) { data, response, error in
            
            guard let data = data else {
                completionHandler(nil, nil, UnsplashClientError.didNotReceiveData)
                return
            }
            
            if let error = error {
                print("Unknown error: \(error)")
                completionHandler(nil, nil, UnsplashClientError.unknown)
                return
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                var newPhotos: [UnsplashPhoto]?
                var searchResultsTotalPages: Int?
                
                if collectionType == .search {
                    let searchResults = try decoder.decode(UnsplashSearchResults.self, from: data)
                    newPhotos = searchResults.results
                    searchResultsTotalPages = searchResults.totalPages
                } else {
                    newPhotos = try decoder.decode([UnsplashPhoto].self, from: data)
                }
                
                // pass on the photos array + optional searchResultsTotalPages
                completionHandler(newPhotos, searchResultsTotalPages, nil)
            } catch {
                print("error trying to convert data to JSON: \(error)")
                
                // handle common errors
                if let jsonString = String(data: data, encoding: .utf8) {
                    print(jsonString)
                    
                    if jsonString == "Rate Limit Exceeded" {
                        completionHandler(nil, nil, UnsplashClientError.rateLimitExceeded)
                    } else if jsonString.contains("The access token is invalid") {
                        completionHandler(nil, nil, UnsplashClientError.invalidAccessToken)
                    } else if jsonString.contains("Internal Server Error") {
                        completionHandler(nil, nil, UnsplashClientError.internalServerError)
                    } else {
                        completionHandler(nil, nil, UnsplashClientError.receivedUnexpectedData)
                    }
                } else {
                    completionHandler(nil, nil, UnsplashClientError.failedToParseJSON)
                }
            }
        }
        
        dataTask.resume()
    }
    
    /**
     Used to generate the URL for making a call to the Unsplash API.
     
     - Parameter clientID: Your Unsplash app ID.
     - Parameter collectionType: The CollectionType to use for the API call.
     - Parameter resultsPerPage: The number of results to return from the API call.
     - Parameter pageNumber: The page number for the API call. (For example, if resultsPerPage is set to 50 and pageNumber is 1, it would return results 1 - 50. If you want the results for 51 - 100, you'd set pageNumber to 2.)
     - Parameter searchPhrase: The phrase to search for if the collectionType is .search.
     
     - Returns: The URL to use when making a call to the Unsplash API.
     */
    static func urlForJSONRequest(withClientID clientID: String?, collectionType: CollectionType, resultsPerPage: Int, pageNumber: Int, searchPhrase: String? = nil) -> URL? {
        guard let clientID = clientID else {
            // allow for nil clientID
            // so that view controller tests can be run without triggering a call to the API
            return nil
        }
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.unsplash.com"
        
        switch collectionType {
        case .new:
            urlComponents.path = "/photos"
        case .curated:
            urlComponents.path = "/photos/curated"
        case .search:
            urlComponents.path = "/search/photos"
        }
        
        let clientIDItem = URLQueryItem(name: "client_id", value: clientID)
        let perPageItem = URLQueryItem(name: "per_page", value: "\(resultsPerPage)")
        let pageNumberItem = URLQueryItem(name: "page", value: "\(pageNumber)")
        urlComponents.queryItems = [clientIDItem, perPageItem, pageNumberItem]
        
        if collectionType == .search {
            if let searchPhrase = searchPhrase {
                let queryItem = URLQueryItem(name: "query", value: searchPhrase)
                urlComponents.queryItems?.append(queryItem)
            }
        }
        
        return urlComponents.url
    }
    
    /**
     Adds an Unsplash app ID to the URL for incrementing the download count for a photo.
     
     - Parameter baseURL: The URL you obtain from an instance of UnsplashPhoto
     (via photo.links.downloadLocation).
     - Parameter clientID: Your Unsplash app ID.
     
     - Returns: The baseURL with the clientID properly appended to it.
     */
    static func urlForIncrementingDownloadCount(baseURL: URL, clientID: String) -> URL? {
        guard var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            return nil
        }
        let clientIDItem = URLQueryItem(name: "client_id", value: clientID)
        urlComponents.queryItems = [clientIDItem]
        return urlComponents.url
    }
}

// MARK: - Error handling

enum UnsplashClientError: Error {
    case unknown
    case didNotReceiveData
    case rateLimitExceeded
    case invalidAccessToken
    case internalServerError
    case receivedUnexpectedData
    case failedToParseJSON
}

extension UnsplashClientError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unknown:
            return NSLocalizedString("Unknown error.",
                                     comment: "Error message for when the Unsplash API client receives and unknown error.")
        case .didNotReceiveData:
            return NSLocalizedString("Did not receive data.",
                                     comment: "Error message for when the Unsplash API client doesn't receive any data.")
        case .rateLimitExceeded:
            return NSLocalizedString("Rate limit exceeded.",
                                     comment: "Error message for when the Unsplash API rate limit has been exceeded.")
        case .invalidAccessToken:
            return NSLocalizedString("Invalid access token.",
                                     comment: "Error message for when an incorrect application ID has been used to access the Unsplash API.")
        case .internalServerError:
            return NSLocalizedString("Internal server error.",
                                     comment: "Error message for when the Unsplash API returns an 'Internal server error' message.")
        case .receivedUnexpectedData:
            return NSLocalizedString("The data received was not what was expected.",
                                     comment: "Error message for when the Unsplash API client receives data that it doesn't know how to handle.")
        case .failedToParseJSON:
            return NSLocalizedString("Failed to parse JSON data.",
                                     comment: "Error message for when the Unsplash API client fails to parse JSON data.")
        }
    }
}

// MARK: - Testability
// with help from: http://masilotti.com/testing-nsurlsession-input/

typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void

protocol URLSessionProtocol {
    func dataTask(with url: URL, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol
}

extension URLSession: URLSessionProtocol {
    func dataTask(with url: URL, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        return (dataTask(with: url, completionHandler: completionHandler) as URLSessionDataTask) as URLSessionDataTaskProtocol
    }
}

protocol URLSessionDataTaskProtocol {
    func resume()
}

extension URLSessionDataTask: URLSessionDataTaskProtocol { }

