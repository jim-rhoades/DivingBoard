//
//  ContainerViewController.swift
//  UnsplashPickerController
//
//  Created by Jim Rhoades on 2/15/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController, SegueHandlerType {
    enum SegueIdentifier: String {
        case embedLatestVC = "EmbedLatestVC"
        case embedPopularVC = "EmbedPopularVC"
        case embedSearchVC = "EmbedSearchVC"
    }
    
    weak var delegate: UnsplashPickerControllerDelegate?
    weak var latestViewController: PhotoCollectionViewController?
    weak var popularViewController: PhotoCollectionViewController?
    weak var searchViewController: PhotoCollectionViewController?
    // var transitionInProgress = false
    var toCollectionTypeIndex: Int = 0
    var fromCollectionTypeIndex: Int = 0
    @IBOutlet weak var collectionTypePickerView: CollectionTypePickerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Unsplash"
        
        // hide the shadow line on the navigationBar
        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        
        collectionTypePickerView.delegate = self
        
        // load the Latest photos initially
        performSegue(withIdentifier: .embedLatestVC, sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        delegate?.unsplashPickerControllerDidCancel()
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let segueIdentifier = segueIdentifierForSegue(segue)
        
        guard let photoCollectionViewController = segue.destination as? PhotoCollectionViewController else {
            print("segue.destination was not a PhotoCollectionViewController")
            return
        }
        
        // adjust inset to make room for the collectionTypePickerView
        photoCollectionViewController.collectionView?.contentInset.top += collectionTypePickerView.frame.size.height
        photoCollectionViewController.collectionView?.scrollIndicatorInsets.top += collectionTypePickerView.frame.size.height
        
        switch segueIdentifier {
        case .embedLatestVC:
            latestViewController = photoCollectionViewController
            // TODO: configure latestViewController to show the latest photos
            
        case .embedPopularVC:
            popularViewController = photoCollectionViewController
            // TODO: configure popularViewController to show popular photos
            
        case .embedSearchVC:
            searchViewController = photoCollectionViewController
            // TODO: configure searchViewController to show the search interface
        }
        
        handleSegue(to: photoCollectionViewController)
    }
    
    func handleSegue(to photoCollectionViewController: PhotoCollectionViewController) {
        if childViewControllers.count > 0 {
            // there is an existing childViewController, so perform a swap
            let currentlyDisplayedViewController = childViewControllers[0]
            swapFromViewController(currentlyDisplayedViewController, toViewController: photoCollectionViewController)
        } else {
            // no existing childViewController, so load it from scratch
            self.addChildViewController(photoCollectionViewController)
            let destView = photoCollectionViewController.view
            destView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            destView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            self.view.addSubview(destView!)
            photoCollectionViewController.didMove(toParentViewController: self)
        }
        // bring the collectionTypePickerView to the front
        view.bringSubview(toFront: collectionTypePickerView)
    }
    
    
    
    /*
     // CROSS DISSOLVE
     func swapFromViewController(fromViewController: UIViewController, toViewController: UIViewController) {
     #if DEBUG
     printDebugLog(#function)
     #endif
     
     toViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
     
     // via:
     // http://sandmoose.com/post/35714028270/storyboards-with-custom-container-view-controllers
     
     fromViewController.willMoveToParentViewController(nil)
     self.addChildViewController(toViewController)
     self.transitionFromViewController(fromViewController, toViewController: toViewController, duration: 0.1, options: .TransitionCrossDissolve, animations: nil) { (finished: Bool) in
     if finished {
     fromViewController.removeFromParentViewController()
     toViewController.didMoveToParentViewController(self)
     self.transitionInProgress = false
     }
     }
     }
     */
    
    
    
    // SLIDE FROM LEFT / RIGHT
    func swapFromViewController(_ fromViewController: UIViewController, toViewController: UIViewController) {
        // decide whether to slide left or right
        var slideFromRight = false
        if toCollectionTypeIndex > fromCollectionTypeIndex {
            slideFromRight = true
        }
        
        let visibleFrame = view.bounds
        
        // start the incoming viewController offscreen
        if slideFromRight == true {
            toViewController.view.frame = offScreenRightFrame()
        }
        else {
            toViewController.view.frame = offScreenLeftFrame()
        }
        
        
        // with help from:
        // http://sandmoose.com/post/35714028270/storyboards-with-custom-container-view-controllers
        
        // and:
        // http://code.tutsplus.com/tutorials/implementing-container-containment-sliding-menu-controller--mobile-14562
        
        // NOTE: added beginAppearanceTransition and endAppearanceTransition
        // to fix iOS 11 issue where completion block wasn't being called
        
        addChildViewController(toViewController)
        fromViewController.willMove(toParentViewController: nil)
        fromViewController.beginAppearanceTransition(false, animated: true)
        toViewController.beginAppearanceTransition(true, animated: false)
        
        transition(from: fromViewController, to: toViewController, duration: 0.25, options: [.curveEaseOut], animations: {
            toViewController.view.frame = visibleFrame
            
            if slideFromRight == true {
                fromViewController.view.frame = self.offScreenLeftFrame()
            }
            else {
                fromViewController.view.frame = self.offScreenRightFrame()
            }
        }) { (finished: Bool) in
            if finished {
                toViewController.endAppearanceTransition()
                fromViewController.endAppearanceTransition()
                toViewController.didMove(toParentViewController: self)
                fromViewController.removeFromParentViewController()
                
                self.fromCollectionTypeIndex = self.toCollectionTypeIndex // at this point, the toCollectionTypeIndex is the one that's currently selected
               //  self.transitionInProgress = false
                
                /*
                 if fromViewController === self.listViewController {
                 self.listViewController = nil
                 }
                 else if fromViewController === self.dueDatesViewController {
                 self.dueDatesViewController = nil
                 }
                 else if fromViewController === self.searchAllViewController {
                 self.searchAllViewController = nil
                 }
                 */
            }
        }
    }
    
    func offScreenRightFrame() -> CGRect {
        return CGRect(x: view.bounds.size.width, y: 0, width: view.bounds.size.width, height: view.bounds.size.height)
    }
    
    func offScreenLeftFrame() -> CGRect {
        return CGRect(x: -view.bounds.size.width, y: 0, width: view.bounds.size.width, height: view.bounds.size.height)
    }
}

extension ContainerViewController: CollectionTypePickerViewDelegate {
    func collectionTypeChanged(_ collectionType: CollectionType) {
        
        toCollectionTypeIndex = collectionType.rawValue
        
        switch collectionType {
        case .latest:
            performSegue(withIdentifier: .embedLatestVC, sender: self)
        case .popular:
            performSegue(withIdentifier: .embedPopularVC, sender: self)
        case .search:
            performSegue(withIdentifier: .embedSearchVC, sender: self)
        }
    }
}
