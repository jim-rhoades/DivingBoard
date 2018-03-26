//
//  UnsplashClient.swift
//  DivingBoard
//
//  Created by Jim Rhoades on 3/13/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import Foundation

class UnsplashClient {
    
    typealias completionHandler = (_ photos: [UnsplashPhoto]?, _ searchResultsTotalPages: Int?, _ error: Error?) -> Void
    
    /**
     Used to request photos via the Unsplash API.
     
     - Parameter url: The URL to use for the API request. (Which you can get by using 'UnsplashClient.urlForJSONRequest'.)
     - Parameter collectionType: The CollectionType to use for the API call.
     - Parameter completionHandler: Invoked when the request has completed. If successful it provides an array of UnsplashPhoto's and optional searchResultsTotalPages Int, otherwise an Error is returned.
     */
    func requestPhotosFor(url: URL, collectionType: CollectionType, completionHandler: @escaping completionHandler) {
        #if DEBUG
            print("url: \(url.absoluteString)")
        #endif
        
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            // handle common errors
            if let response = response as? HTTPURLResponse {
                #if DEBUG
                    if response.statusCode != 200 {
                        print("request failed with status code: \(response.statusCode)")
                    }
                #endif
                
                switch response.statusCode {
                case UnsplashClientError.unauthorized.rawValue:
                    completionHandler(nil, nil, UnsplashClientError.unauthorized)
                    return
                case UnsplashClientError.forbidden.rawValue:
                    completionHandler(nil, nil, UnsplashClientError.forbidden)
                    return
                case UnsplashClientError.internalServerError.rawValue:
                    completionHandler(nil, nil, UnsplashClientError.internalServerError)
                    return
                case UnsplashClientError.serviceUnavailable.rawValue:
                    completionHandler(nil, nil, UnsplashClientError.serviceUnavailable)
                    return
                default:
                    break
                }
            }
            
            if let error = error {
                print("Unknown error: \(error)")
                completionHandler(nil, nil, UnsplashClientError.unknown)
                return
            }
            
            guard let data = data else {
                completionHandler(nil, nil, UnsplashClientError.didNotReceiveData)
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
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    print(jsonString)
                    completionHandler(nil, nil, UnsplashClientError.receivedUnexpectedData)
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

enum UnsplashClientError: Int, Error {
    case unknown
    case didNotReceiveData
    case receivedUnexpectedData
    case failedToParseJSON
    case unauthorized = 401
    case forbidden = 403
    case internalServerError = 500
    case serviceUnavailable = 503
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
        case .receivedUnexpectedData:
            return NSLocalizedString("The data received is not what was expected.",
                                     comment: "Error message for when the Unsplash API client receives data that it doesn't know how to handle.")
        case .failedToParseJSON:
            return NSLocalizedString("Failed to parse JSON data.",
                                     comment: "Error message for when the Unsplash API client fails to parse JSON data.")
        case .unauthorized:
            return NSLocalizedString("Invalid Unsplash app ID.",
                                     comment: "Error message for when an incorrect application ID has been used to access the Unsplash API.")
        case .forbidden:
            return NSLocalizedString("Access is forbidden, most likely because the rate limit has been exceeded.",
                                     comment: "Error message for when the Unsplash API has forbidden access, most likely because the rate limit has been exceeded.")
        case .internalServerError:
            return NSLocalizedString("Internal server error.",
                                     comment: "Error message for when the Unsplash API returns an 'Internal server error' message.")
        case .serviceUnavailable:
            return NSLocalizedString("Service unavailable.",
                                     comment: "Error message for when the Unsplash API is unavailable due to a temporary overload or maintenance.")
        }
    }
}

