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
    
    /**
     Used to retrieve the view controller that contains the UI for picking a photo from Unsplash. You should present this view controller just as you would a UIImagePickerController.
     - Parameter presentingViewController: The UIViewController that you are presenting from, which gets set as the delegate. (Make sure your presenting view controller conforms to UnsplashPickerDelegate).
     - Returns: The view controller to present.
    */
    public static func unsplashPicker(withClientID clientID: String, presentingViewController: UIViewController, modalPresentationStyle: UIModalPresentationStyle) -> UIViewController {
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle(for: self))
        let navController = storyboard.instantiateInitialViewController() as! UINavigationController
        let containerViewController = navController.topViewController as! ContainerViewController
        containerViewController.delegate = presentingViewController as? UnsplashPickerDelegate
        containerViewController.clientID = clientID
        
        navController.modalPresentationStyle = modalPresentationStyle
        if modalPresentationStyle == .popover {
            // have containerViewController handle removing the cancel button if needed
            navController.popoverPresentationController?.delegate = containerViewController
        }
        
        return navController
    }
}
