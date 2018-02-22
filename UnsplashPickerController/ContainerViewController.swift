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
    var clientID = ""
    
    private weak var latestViewController: PhotoCollectionViewController?
    private weak var popularViewController: PhotoCollectionViewController?
    private weak var searchViewController: PhotoCollectionViewController?
    private var toCollectionTypeIndex: Int = 0
    private var fromCollectionTypeIndex: Int = 0
    private let commonBarColor = UIColor(white: 247.0/255.0, alpha: 1.0)
    private var previousStatusBarColor: UIColor?
    @IBOutlet private weak var collectionTypePickerView: CollectionTypePickerView!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Unsplash"
        
        // store the app's status bar color so it can be reset when UnsplashPicker is dismissed
        previousStatusBarColor = statusBarColor
        
        if let navigationController = navigationController {
            navigationController.navigationBar.setValue(true, forKey: "hidesShadow") // hide shadow line
            navigationController.navigationBar.barTintColor = commonBarColor
        }
        
        collectionTypePickerView.delegate = self
        
        // load the Latest photos
        performSegue(withIdentifier: .embedLatestVC, sender: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        statusBarColor = commonBarColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        statusBarColor = previousStatusBarColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Status bar
    
    var statusBarColor: UIColor? {
        get {
            guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else {
                return nil
            }
            return statusBar.backgroundColor
        }
        set {
            if let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView {
                statusBar.backgroundColor = newValue
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        // always return false on iPhone X
        if UIApplication.shared.statusBarFrame.height >= CGFloat(44.0) {
            return false
        }
        
        // hide the status bar when the navigation bar is hidden
        return navigationController?.isNavigationBarHidden ?? false
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    // MARK: - Interaction
    
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
        // assign the clientID and delegate
        photoCollectionViewController.clientID = clientID
        photoCollectionViewController.delegate = delegate
        
        // pass along CollectionTypePickerView's height, so collectionView insets can be adjusted
        photoCollectionViewController.topInsetAdjustment = collectionTypePickerView.bounds.size.height
        
        switch segueIdentifier {
        case .embedLatestVC:
            // configure to show the latest photos
            latestViewController = photoCollectionViewController
            latestViewController?.collectionType = .latest
            
        case .embedPopularVC:
            // configure to show popular photos
            popularViewController = photoCollectionViewController
            popularViewController?.collectionType = .popular
            
        case .embedSearchVC:
            // configure to show the search interface
            searchViewController = photoCollectionViewController
            searchViewController?.collectionType = .search
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
        } else {
            toViewController.view.frame = offScreenLeftFrame()
        }
        
        addChildViewController(toViewController)
        fromViewController.willMove(toParentViewController: nil)
        fromViewController.beginAppearanceTransition(false, animated: true)
        toViewController.beginAppearanceTransition(true, animated: false)
        
        transition(from: fromViewController, to: toViewController, duration: 0.25, options: [.curveEaseOut], animations: {
            toViewController.view.frame = visibleFrame
            
            if slideFromRight == true {
                fromViewController.view.frame = self.offScreenLeftFrame()
            } else {
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
