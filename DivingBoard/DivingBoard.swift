//
//  DivingBoard.swift
//  DivingBoard
//
//  Created by Jim Rhoades on 2/15/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import UIKit

public protocol UnsplashPickerDelegate: class {
    func unsplashPickerDidCancel()
    func unsplashPickerDidFinishPicking(photo: UnsplashPhoto)
}

public class DivingBoard {
    
    private init() {
        // private init, to prevent instantiating DivingBoard
    }
    
    // MARK: - Presentation
    
    /**
     Used to retrieve the view controller that contains the UI for picking a photo from Unsplash.
     
     - Parameter clientID: Your Unsplash app ID.
     - Parameter presentingViewController: The UIViewController that you are presenting from,
    which gets set as the delegate. (Make sure your presenting view controller conforms to
    UnsplashPickerDelegate).
     - Parameter modalPresentationStyle: The presentation style to use (typically .popover or .fullscreen) when presenting modally. If you're pushing the unsplashPicker onto another UINavigationController's stack, leave modalPresentationStyle nil.
     - Parameter initialSearchPhrase: The initial search term to pre-populate
     
     - Returns: The view controller to present.
    */
    public static func unsplashPicker(withClientID clientID: String, presentingViewController: UIViewController, modalPresentationStyle: UIModalPresentationStyle? = nil, initialSearchPhrase: String? = nil) -> UIViewController {
        let storyboard = UIStoryboard.init(name: "DivingBoard", bundle: Bundle(for: self))
        let navController = storyboard.instantiateInitialViewController() as! UINavigationController
        
        var presentAsModal = false
        if let modalPresentationStyle = modalPresentationStyle {
            navController.modalPresentationStyle = modalPresentationStyle
            presentAsModal = true
        }
        
        let photoCollectionViewController = navController.topViewController as! PhotoCollectionViewController
        photoCollectionViewController.delegate = presentingViewController as? UnsplashPickerDelegate
        photoCollectionViewController.clientID = clientID
        
        if let searchPhrase = initialSearchPhrase {
            photoCollectionViewController.currentSearchPhrase = searchPhrase
            photoCollectionViewController.collectionType = .search
        }
        
        return presentAsModal ? navController : photoCollectionViewController
    }
    
    // MARK: - Public utilities
    
    /**
     When linking to a photo or user on the Unsplash website, use this to add proper attribution
     to the URL as described by the Unsplash guidelines:
     https://medium.com/unsplash/unsplash-api-guidelines-attribution-4d433941d777
     
     - Parameter baseURL: The URL you are linking to, usually obtained via an instance of
     UnsplashPhoto (such as photo.links.html or photo.user.links.html).
     - Parameter appName: The name of your app.
     
     - Returns: The baseURL with appended referral information in the form of:
     'utm_source=your_app_name&utm_medium=referral'
    */
    public static func unsplashWebsiteURLWithReferral(baseURL: URL, appName: String) -> URL? {
        guard var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            return nil
        }
        
        let sourceItem = URLQueryItem(name: "utm_source", value: appName)
        let mediumItem = URLQueryItem(name: "utm_medium", value: "referral")
        urlComponents.queryItems = [sourceItem, mediumItem]
        return urlComponents.url
    }
    
    /**
     Increments the download count of a photo on Unsplash. Per the Unsplash API guidelines, this
     must be done "when your application performs something similar to a download
     (like when a user chooses the image to include in a blog post, set as a wallpaper, etc.)":
     https://medium.com/unsplash/unsplash-api-guidelines-triggering-a-download-c39b24e99e02
     
     - Parameter photo: The photo that you want to increment the download count of.
     - Parameter clientID: Your Unsplash app ID.
    */
    public static func incrementUnsplashPhotoDownloadCount(photo: UnsplashPhoto, clientID: String) {
        let baseURL = photo.links.downloadLocation
        guard let url = DivingBoard.urlForIncrementingDownloadCount(baseURL: baseURL, clientID: clientID) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error)
                return
            }
            
            // don't need to do anything with the data that is returned
            /*
            guard let data = data,
                let dataString = String(data: data, encoding: .utf8) else {
                return
            }
            print(dataString)
            */
        }
        task.resume()
    }
    
    // MARK: - Internal utilities
    
    /**
     Adds an Unsplash app ID to the URL for incrementing the download count for a photo.
     
     - Parameter baseURL: The URL you obtain from an instance of UnsplashPhoto
     (via photo.links.downloadLocation).
     - Parameter clientID: Your Unsplash app ID.
     
     - Returns: The baseURL with the clientID properly appended to it.
     */
    internal static func urlForIncrementingDownloadCount(baseURL: URL, clientID: String) -> URL? {
        guard var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            return nil
        }
        let clientIDItem = URLQueryItem(name: "client_id", value: clientID)
        urlComponents.queryItems = [clientIDItem]
        return urlComponents.url
    }
}
