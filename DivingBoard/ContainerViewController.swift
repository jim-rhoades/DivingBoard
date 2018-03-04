//
//  ContainerViewController.swift
//  DivingBoard
//
//  Created by Jim Rhoades on 2/15/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import UIKit

enum LayoutStyle {
    case stacked
    case grid
}

class ContainerViewController: UIViewController, SegueHandlerType {
    enum SegueIdentifier: String {
        case embedNewVC = "EmbedNewVC"
        case embedCuratedVC = "EmbedCuratedVC"
        case embedSearchVC = "EmbedSearchVC"
    }
    
    weak var delegate: UnsplashPickerDelegate?
    var clientID = ""
    
    private var newViewController: PhotoCollectionViewController?
    private var curatedViewController: PhotoCollectionViewController?
    private var searchViewController: PhotoCollectionViewController?
    private var toCollectionTypeIndex: Int = 0
    private var fromCollectionTypeIndex: Int = 0
    private let commonBarColor = UIColor(white: 247.0/255.0, alpha: 1.0)
    private var previousStatusBarColor: UIColor?
    private var stackedLayoutButton: UIBarButtonItem?
    private var gridLayoutButton: UIBarButtonItem?
    private var currentLayoutStyle: LayoutStyle = .grid
    @IBOutlet private weak var collectionTypePickerView: CollectionTypePickerView!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // store the app's status bar color so it can be reset when the unsplashPicker is dismissed
        previousStatusBarColor = statusBarColor
        
        createLayoutButtons()
        
        if let navigationController = navigationController {
            navigationController.navigationBar.setValue(true, forKey: "hidesShadow") // hide shadow line
            navigationController.navigationBar.barTintColor = commonBarColor
        }
        
        collectionTypePickerView.delegate = self
        
        // load the newest photos
        performSegue(withIdentifier: .embedNewVC, sender: self)
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
    
    // MARK: - Layout buttons
    
    func createLayoutButtons() {
        // only if they haven't already been created
        guard stackedLayoutButton == nil || gridLayoutButton == nil else {
            return
        }
        
        let bundle = Bundle(for: DivingBoard.self)
        guard let stackedImage = UIImage(named: "layoutButtonStacked", in: bundle, compatibleWith: nil) else {
            preconditionFailure("failed to load image: layoutButtonStacked")
        }
        guard let stackedImageDisabled = UIImage(named: "layoutButtonStacked_Disabled", in: bundle, compatibleWith: nil) else {
            preconditionFailure("failed to load image: layoutButtonStacked_Disabled")
        }
        guard let gridImage = UIImage(named: "layoutButtonGrid", in: bundle, compatibleWith: nil) else {
            preconditionFailure("failed to load image: layoutButtonGrid")
        }
        guard let gridImageDisabled = UIImage(named: "layoutButtonGrid_Disabled", in: bundle, compatibleWith: nil) else {
            preconditionFailure("failed to load image: layoutButtonGrid_Disabled")
        }
        
        let rect = CGRect(x: 0, y: 0, width: 32.0, height: 32.0)
        
        let stackedButton = UIButton(frame: rect)
        stackedButton.setImage(stackedImage, for: .normal)
        stackedButton.setImage(stackedImageDisabled, for: .disabled)
        stackedButton.addTarget(self, action: #selector(stackedLayoutButtonPressed(_:)), for: .touchUpInside)
        let stackedBarButton = UIBarButtonItem(customView: stackedButton)
        stackedLayoutButton = stackedBarButton
        
        let gridButton = UIButton(frame: rect)
        gridButton.setImage(gridImage, for: .normal)
        gridButton.setImage(gridImageDisabled, for: .disabled)
        gridButton.addTarget(self, action: #selector(gridLayoutButtonPressed(_:)), for: .touchUpInside)
        let gridBarButton = UIBarButtonItem(customView: gridButton)
        gridLayoutButton = gridBarButton
        
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 16.0
        
        navigationItem.leftBarButtonItems = [stackedBarButton, fixedSpace, gridBarButton]
        updateLayoutButtons()
    }
    
    func updateLayoutButtons() {
        guard let stackedLayoutButton = stackedLayoutButton,
            let gridLayoutButton = gridLayoutButton else {
            return
        }
        
        switch currentLayoutStyle {
        case .stacked:
            stackedLayoutButton.isEnabled = false
            gridLayoutButton.isEnabled = true
        case .grid:
            stackedLayoutButton.isEnabled = true
            gridLayoutButton.isEnabled = false
        }
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
    
    @objc func stackedLayoutButtonPressed(_ sender: Any) {
        currentLayoutStyle = .stacked
        updateLayoutButtons()
        newViewController?.currentLayoutStyle = currentLayoutStyle
        curatedViewController?.currentLayoutStyle = currentLayoutStyle
        searchViewController?.currentLayoutStyle = currentLayoutStyle
    }
    
    @objc func gridLayoutButtonPressed(_ sender: Any) {
        currentLayoutStyle = .grid
        updateLayoutButtons()
        newViewController?.currentLayoutStyle = currentLayoutStyle
        curatedViewController?.currentLayoutStyle = currentLayoutStyle
        searchViewController?.currentLayoutStyle = currentLayoutStyle
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        delegate?.unsplashPickerDidCancel()
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let segueIdentifier = segueIdentifierForSegue(segue)
        
        guard let photoCollectionViewController = segue.destination as? PhotoCollectionViewController else {
            print("segue.destination was not a PhotoCollectionViewController")
            return
        }
        // configure common vars
        photoCollectionViewController.clientID = clientID
        photoCollectionViewController.delegate = delegate
        photoCollectionViewController.currentLayoutStyle = currentLayoutStyle
        
        // pass along CollectionTypePickerView's height, so collectionView insets can be adjusted
        photoCollectionViewController.topInsetAdjustment = collectionTypePickerView.bounds.size.height
        
        switch segueIdentifier {
        case .embedNewVC:
            // configure to show the newest photos
            newViewController = photoCollectionViewController
            newViewController?.collectionType = .new
            
        case .embedCuratedVC:
            // configure to show curated photos
            curatedViewController = photoCollectionViewController
            curatedViewController?.collectionType = .curated
            
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
            addChildViewController(photoCollectionViewController)
            view.insertSubview(photoCollectionViewController.view, belowSubview: collectionTypePickerView)
            photoCollectionViewController.didMove(toParentViewController: self)
        }
    }
    
    func swapFromViewController(_ fromViewController: UIViewController, toViewController: UIViewController) {
        // decide whether to slide left or right
        var slideFromRight = false
        if toCollectionTypeIndex > fromCollectionTypeIndex {
            slideFromRight = true
        }
        
        // start the incoming viewController offscreen
        if slideFromRight == true {
            toViewController.view.frame = offScreenRightFrame()
        } else {
            toViewController.view.frame = offScreenLeftFrame()
        }
        
        addChildViewController(toViewController)
        fromViewController.willMove(toParentViewController: nil)
        
        transition(from: fromViewController, to: toViewController, duration: 0.25,
                   options: [.curveEaseOut], animations: {
            toViewController.view.frame = self.view.bounds
            
            if slideFromRight == true {
                fromViewController.view.frame = self.offScreenLeftFrame()
            } else {
                fromViewController.view.frame = self.offScreenRightFrame()
            }
        }) { finished in
            toViewController.didMove(toParentViewController: self)
            fromViewController.removeFromParentViewController()
            self.fromCollectionTypeIndex = self.toCollectionTypeIndex
        }
    }
    
    override func transition(from fromViewController: UIViewController, to toViewController: UIViewController, duration: TimeInterval, options: UIViewAnimationOptions = [], animations: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        super.transition(from: fromViewController, to: toViewController, duration: duration, options: options, animations: animations, completion: completion)
        
        // the transition automatically adds toViewController.view as a subview of self.view,
        // which covers up collectionTypePickerView
        
        // bring collectionTypePickerView to the front
        view.bringSubview(toFront: collectionTypePickerView)
    }
    
    func offScreenRightFrame() -> CGRect {
        return CGRect(x: view.bounds.size.width, y: 0, width: view.bounds.size.width, height: view.bounds.size.height)
    }
    
    func offScreenLeftFrame() -> CGRect {
        return CGRect(x: -view.bounds.size.width, y: 0, width: view.bounds.size.width, height: view.bounds.size.height)
    }
}

// MARK: - CollectionTypePickerViewDelegate

extension ContainerViewController: CollectionTypePickerViewDelegate {
    func collectionTypeChanged(_ collectionType: CollectionType) {
        
        toCollectionTypeIndex = collectionType.rawValue
        
        let currentlyDisplayedViewController = childViewControllers[0]
        
        switch collectionType {
        case .new:
            if let newViewController = newViewController {
                swapFromViewController(currentlyDisplayedViewController, toViewController: newViewController)
            } else {
                performSegue(withIdentifier: .embedNewVC, sender: self)
            }
        case .curated:
            if let curatedViewController = curatedViewController {
                swapFromViewController(currentlyDisplayedViewController, toViewController: curatedViewController)
            } else {
                performSegue(withIdentifier: .embedCuratedVC, sender: self)
            }
        case .search:
            if let searchViewController = searchViewController {
                swapFromViewController(currentlyDisplayedViewController, toViewController: searchViewController)
            } else {
                performSegue(withIdentifier: .embedSearchVC, sender: self)
            }
        }
    }
}

// MARK: - UIPopoverPresentationControllerDelegate

extension ContainerViewController: UIPopoverPresentationControllerDelegate {
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        // remove the "Cancel" button when the unsplashPicker is presented as a popover
        navigationItem.rightBarButtonItem = nil
    }
}
