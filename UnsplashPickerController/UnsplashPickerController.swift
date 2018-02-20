//
//  UnsplashPickerController.swift
//  UnsplashPickerController
//
//  Created by Jim Rhoades on 2/15/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import UIKit

public protocol UnsplashPickerControllerDelegate: class {
    
    // func unsplashPickerControllerDidCancel(_ picker: UnsplashPickerController)
    func unsplashPickerControllerDidCancel()
    
    // func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    func unsplashPickerControllerDidFinishPicking(photo: UnsplashPhoto)
}

public class UnsplashPickerController {
    
    private init() {
        // private init, to prevent instantiating UnsplashPickerController
    }
    
    
    // TODO: show error when someone uses bad clientID
    
    
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
    
    
    /*
    public static func initialViewController() -> UIViewController {
        // TODO: but how do I assign the delegate?
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle(for: self))
        let pickerViewController = storyboard.instantiateInitialViewController()!
        return pickerViewController
    }
    */
    
    
    /*
    // usage: UnsplashPickerController.presentPicker(from: self)
    // TODO: wouldn't work as popup like UIImagePickerController?
    public static func presentPicker(from presentingViewController: UIViewController) {
        // load and configure the ContainerViewController
        let bundle = Bundle(identifier: "com.crushapps.UnsplashPickerController")
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        guard let navController = storyboard.instantiateInitialViewController() as? UINavigationController else {
            print("failed to load UINavigationController")
            return
        }
        guard let containerViewController = navController.topViewController as? ContainerViewController else {
            print("failed to load PhotoToolboxViewController")
            return
        }
        
        containerViewController.delegate = presentingViewController as? UnsplashPickerControllerDelegate
        presentingViewController.present(navController, animated: true, completion: nil)
    }
    */
    
    
    /*
    init(presentingViewController: UIViewController) {
        // load and configure the ContainerViewController
        let bundle = Bundle(identifier: "com.crushapps.UnsplashPickerController")
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        guard let navController = storyboard.instantiateInitialViewController() as? UINavigationController else {
            print("failed to load UINavigationController")
            return
        }
        guard let containerViewController = navController.topViewController as? ContainerViewController else {
            print("failed to load PhotoToolboxViewController")
            return
        }
        
        containerViewController.delegate = presentingViewController as? UnsplashPickerControllerDelegate
        presentingViewController.present(navController, animated: true, completion: nil)
    }
    */
}
