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
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var collectionTypePickerView: CollectionTypePickerView!
    
    weak var delegate: UnsplashPickerDelegate?
    var clientID: String?
    var newViewController: PhotoCollectionViewController?
    var curatedViewController: PhotoCollectionViewController?
    var searchViewController: PhotoCollectionViewController?
    var currentlyDisplayedViewController: PhotoCollectionViewController?
    var toCollectionTypeIndex: Int = 0
    var fromCollectionTypeIndex: Int = 0
    let commonBarColor = UIColor(white: 247.0/255.0, alpha: 1.0)
    var previousStatusBarColor: UIColor?
    var stackedLayoutButton: UIBarButtonItem?
    var gridLayoutButton: UIBarButtonItem?
    var currentLayoutStyle: LayoutStyle = .grid
    
    private lazy var isPhoneDevice: Bool = {
        return UIDevice.current.userInterfaceIdiom == .phone
    }()
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // store the app's status bar color so it can be reset when the unsplashPicker is dismissed
        // (really only necessary for iPhone X, but this has no negative affect on other iPhones,
        //  and helps ensure compatibility with future devices)
        if isPhoneDevice {
            previousStatusBarColor = statusBarColor
        }
        
        createLayoutButtons()
        
        if let navigationController = navigationController {
            navigationController.navigationBar.setValue(true, forKey: "hidesShadow") // hide shadow line
            navigationController.navigationBar.barTintColor = commonBarColor
            
            // on iPhone, hide navigation bar when scrolling down
            if isPhoneDevice {
                navigationController.hidesBarsOnSwipe = true
            }
        }
        
        collectionTypePickerView.delegate = self
        
        // load the newest photos
        performSegue(withIdentifier: .embedNewVC, sender: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isPhoneDevice {
            // this is for iPhone X
            // set a color for status bar, so that photos don't show behind it
            statusBarColor = commonBarColor
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isPhoneDevice {
            statusBarColor = previousStatusBarColor
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // get rid of any PhotoCollectionViewController instances
        // that are NOT the one currently being displayed
        for child in childViewControllers {
            if child !== currentlyDisplayedViewController {
                child.willMove(toParentViewController: nil)
                child.view.removeFromSuperview()
                child.removeFromParentViewController()
                
                if child === newViewController {
                    newViewController = nil
                } else if child === curatedViewController {
                    curatedViewController = nil
                } else if child === searchViewController {
                    searchViewController = nil
                }
            }
        }
    }
    
    // MARK: - Layout buttons
    
    func createLayoutButtons() {
        // only if they haven't already been created
        guard stackedLayoutButton == nil || gridLayoutButton == nil else {
            return
        }
        
        let bundle = Bundle(for: DivingBoard.self)
        guard let stackedImage = UIImage(named: "layoutButtonStacked", in: bundle, compatibleWith: nil) else {
            fatalError("failed to load image: layoutButtonStacked")
        }
        guard let stackedImageDisabled = UIImage(named: "layoutButtonStacked_Disabled", in: bundle, compatibleWith: nil) else {
            fatalError("failed to load image: layoutButtonStacked_Disabled")
        }
        guard let gridImage = UIImage(named: "layoutButtonGrid", in: bundle, compatibleWith: nil) else {
            fatalError("failed to load image: layoutButtonGrid")
        }
        guard let gridImageDisabled = UIImage(named: "layoutButtonGrid_Disabled", in: bundle, compatibleWith: nil) else {
            fatalError("failed to load image: layoutButtonGrid_Disabled")
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
        // never hide status bar on iPhone X in portrait
        if UIApplication.shared.statusBarFrame.height >= 44.0 {
            return false
        }
        
        // always hide status bar in landscape on iPhone devices
        if isPhoneDevice && UIDevice.current.orientation.isLandscape {
            return true
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
        if let currentlyDisplayed = currentlyDisplayedViewController {
            // there is an existing childViewController, so perform a swap
            swap(fromViewController: currentlyDisplayed,
                 toViewController: photoCollectionViewController,
                 shouldAddAsChild: true)
        } else {
            // no existing childViewController, so load it from scratch
            // have to force onto next runloop to fix issue with black bar at bottom
            DispatchQueue.main.async {
                self.addChildViewController(photoCollectionViewController)
                self.containerView.addSubview(photoCollectionViewController.view)
                photoCollectionViewController.didMove(toParentViewController: self)
                
                self.currentlyDisplayedViewController = photoCollectionViewController
            }
        }
    }
    
    func swap(fromViewController: PhotoCollectionViewController, toViewController: PhotoCollectionViewController, shouldAddAsChild: Bool = false) {
        // decide whether to slide left or right
        let slideFromRight = toCollectionTypeIndex > fromCollectionTypeIndex
        let viewWidth = containerView.bounds.size.width
        toViewController.view.frame.origin.x = slideFromRight ? viewWidth : -viewWidth
        
        if shouldAddAsChild {
            addChildViewController(toViewController)
            containerView.addSubview(toViewController.view)
        }
        
        // animate the transition
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
            toViewController.view.frame.origin.x = 0
            fromViewController.view.frame.origin.x = slideFromRight ? -viewWidth : viewWidth
        }) { finished in
            if shouldAddAsChild {
                toViewController.didMove(toParentViewController: self)
            }
            
            self.currentlyDisplayedViewController = toViewController
            self.fromCollectionTypeIndex = self.toCollectionTypeIndex
        }
    }
}

// MARK: - CollectionTypePickerViewDelegate

extension ContainerViewController: CollectionTypePickerViewDelegate {
    func collectionTypeChanged(_ collectionType: CollectionType) {
        guard let currentlyDisplayed = currentlyDisplayedViewController else {
            return
        }
        
        toCollectionTypeIndex = collectionType.rawValue
        
        switch collectionType {
        case .new:
            if let newViewController = newViewController {
                swap(fromViewController: currentlyDisplayed, toViewController: newViewController)
            } else {
                performSegue(withIdentifier: .embedNewVC, sender: self)
            }
        case .curated:
            if let curatedViewController = curatedViewController {
                swap(fromViewController: currentlyDisplayed, toViewController: curatedViewController)
            } else {
                performSegue(withIdentifier: .embedCuratedVC, sender: self)
            }
        case .search:
            if let searchViewController = searchViewController {
                swap(fromViewController: currentlyDisplayed, toViewController: searchViewController)
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
