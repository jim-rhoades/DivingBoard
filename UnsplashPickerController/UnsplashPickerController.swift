//
//  UnsplashPickerController.swift
//  UnsplashPickerController
//
//  Created by Jim Rhoades on 2/15/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import UIKit

public protocol UnsplashPickerControllerDelegate: class {
    func unsplashPickerControllerDidCancel()
    func unsplashPickerControllerDidFinishPicking(photo: UnsplashPhoto)
}

public class UnsplashPickerController {
    
    private init() {
        // private init, to prevent instantiating UnsplashPickerController
    }
    
    /**
     Used to retrieve the view controller that contains the UI for picking a photo from Unsplash. You should present this view controller just as you would a UIImagePickerController.
     - Parameter presentingViewController: The UIViewController that you are presenting from, which gets set as the delegate. (Make sure your presenting view controller conforms to UnsplashPickerControllerDelegate).
     - Returns: The view controller to present.
    */
    public static func unsplashPicker(withClientID clientID: String, presentingViewController: UIViewController) -> UIViewController {
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle(for: self))
        let navController = storyboard.instantiateInitialViewController() as! UINavigationController
        let containerViewController = navController.topViewController as! ContainerViewController
        containerViewController.delegate = presentingViewController as? UnsplashPickerControllerDelegate
        containerViewController.clientID = clientID
        return navController
    }
}
