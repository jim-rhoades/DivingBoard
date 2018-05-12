//
//  PhotoCollectionViewController.swift
//  DivingBoard
//
//  Created by Jim Rhoades on 2/15/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import UIKit

let commonBarColor = UIColor(white: 247.0/255.0, alpha: 1.0)

class PhotoCollectionViewController: UICollectionViewController {
    enum LayoutStyle {
        case stacked
        case grid
    }
    
    var clientID: String?
    weak var delegate: UnsplashPickerDelegate?
    var collectionType: CollectionType = .new
    let cellSpacing: CGFloat = 2 // spacing between the photo thumbnails
    var loadingView: LoadingView?
    var photos: [UnsplashPhoto] = []
    var pageNumber = 1
    var searchBar: UISearchBar?
    var currentSearchPhrase: String?
    var currentSearchTotalPages: Int = 0
    let reuseIdentifier = "Cell"
    let sectionHeaderIdentifier = "SectionHeader"
    var stackedLayoutButton: UIBarButtonItem?
    var gridLayoutButton: UIBarButtonItem?
    var previousStatusBarColor: UIColor?
    
    private lazy var isPhoneDevice: Bool = {
        return UIDevice.current.userInterfaceIdiom == .phone
    }()
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // store the app's status bar color so it can be reset when the unsplashPicker is dismissed
        // (really only necessary for iPhone X, but this has no negative affect on other iPhones,
        //  and helps ensure compatibility with future devices)
        if isPhoneDevice && isModal {
            previousStatusBarColor = statusBarColor
        }
        
        // configure UI
        configureNavigationBar()
        configureSearchBar()
        
        // load photos from Unsplash
        loadPhotos(showLoadingIndicator: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isPhoneDevice && isModal {
            // set status bar color, so that photos don't show behind it on iPhone X
            statusBarColor = commonBarColor
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // DivingBoard is being dismissed
        
        if isPhoneDevice && isModal {
            // change status bar color back to what it was
            statusBarColor = previousStatusBarColor
        }
        
        // dismiss keyboard if needed
        searchBar?.resignFirstResponder()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - Navigation bar
    
    lazy var isModal: Bool = {
        return presentingViewController != nil
    }()
    
    func configureNavigationBar() {
        createLayoutButtons()
        
        guard isModal, // continue only if presented modally
            let navigationController = navigationController else {
                return
        }
        navigationController.navigationBar.setValue(true, forKey: "hidesShadow") // hide shadow line
        navigationController.navigationBar.barTintColor = commonBarColor
        
        // on iPhone, hide navigation bar when scrolling down
        if isPhoneDevice {
            navigationController.hidesBarsOnSwipe = true
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
    
    // MARK: - Layout style buttons
    
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
        
        if isModal {
            navigationItem.leftBarButtonItems = [stackedBarButton, fixedSpace, gridBarButton]
        } else {
            // unsplashPicker was presented by pushing it onto a navigationController stack
            // so place buttons on right (leaving "< Back" button on left)
            navigationItem.rightBarButtonItems = [stackedBarButton, fixedSpace, gridBarButton]
        }
        
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
    
    // MARK: - Layout style switching
    
    @objc func stackedLayoutButtonPressed(_ sender: Any) {
        currentLayoutStyle = .stacked
        updateLayoutButtons()
    }
    
    @objc func gridLayoutButtonPressed(_ sender: Any) {
        currentLayoutStyle = .grid
        updateLayoutButtons()
    }
    
    var currentIndexPath: IndexPath?
    var currentLayoutStyle: LayoutStyle = .grid {
        willSet {
            // abort if view not loaded to prevent UI glitch
            guard isViewLoaded,
                let collectionView = collectionView else {
                    return
            }
            
            // abort if scrolled to top
            if collectionView.contentOffset.y <= 0 {
                return
            }
            
            // store the indexPath for the item displayed near the center
            let visibleIndexPaths = collectionView.indexPathsForVisibleItems
            guard visibleIndexPaths.count > 0 else {
                return
            }
            let sortedIndexPaths = visibleIndexPaths.sorted(by: <)
            let medianIndex = sortedIndexPaths.count / 2
            let medianIndexPath = sortedIndexPaths[medianIndex]
            currentIndexPath = medianIndexPath
        }
        didSet {
            // abort if view not loaded to prevent UI glitch
            guard isViewLoaded,
                let collectionView = collectionView else {
                    return
            }
            
            // update the layout
            collectionViewLayout.invalidateLayout()
            
            // abort if scrolled to top
            if collectionView.contentOffset.y <= 0 {
                return
            }
            
            // scroll to the same item that was being displayed near the center
            if let currentIndexPath = currentIndexPath {
                collectionView.scrollToItem(at: currentIndexPath, at: .centeredVertically, animated: false)
            }
        }
    }
    
    // MARK: - Photo loading
    
    func loadPhotos(showLoadingIndicator: Bool) {
        guard let url = UnsplashClient.urlForJSONRequest(withClientID: clientID,
                                                   collectionType: collectionType,
                                                   resultsPerPage: 40,
                                                   pageNumber: pageNumber,
                                                   searchPhrase: currentSearchPhrase) else {
            return
        }
        
        if showLoadingIndicator {
            loadingView = LoadingView()
            view.addCenteredSubview(loadingView!)
        }
        
        let unsplashClient = UnsplashClient()
        unsplashClient.requestPhotosFor(url: url, collectionType: collectionType) { [weak self] requestedPhotos, searchResultsTotalPages, error in
            
            // remove the loadingView regardless of whether or not there was an error
            DispatchQueue.main.async {
                if let loadingView = self?.loadingView {
                    UIView.animate(withDuration: 0.15, animations: {
                        loadingView.alpha = 0.0
                    }, completion: { completed in
                        loadingView.removeFromSuperview()
                    })
                }
            }
            
            // handle errors
            if let error = error {
                DispatchQueue.main.async {
                    self?.showErrorAlert(message: error.localizedDescription)
                }
                return
            }
            
            // append the requested photos to the photos array
            guard let requestedPhotos = requestedPhotos else {
                print("Error: did not receive photos") // this should never happen?
                return
            }
            self?.photos.append(contentsOf: requestedPhotos)
            
            // if searching, keep track of the total number of pages in the search
            if self?.collectionType == .search,
                let searchResultsTotalPages = searchResultsTotalPages {
                self?.currentSearchTotalPages = searchResultsTotalPages
            }
            
            DispatchQueue.main.async {
                self?.collectionView?.reloadData()
            }
        }
    }
    
    private func showErrorAlert(message: String) {
        let alertTitle = NSLocalizedString("Error", comment: "title of 'Error' alert")
        let alertController = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
        let okTitle = NSLocalizedString("OK", comment: "'OK' button title")
        let okAction = UIAlertAction(title: okTitle, style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Interaction
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        delegate?.unsplashPickerDidCancel()
    }
}

// MARK: - UICollectionViewDataSource

extension PhotoCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        let photo = photos[indexPath.item]
        let thumbnailURL = photo.urls.small // photo.urls.thumb images are too small
        
        // load image asynchronously, using cached version if it's there
        cell.imageView.loadImageAsync(with: thumbnailURL, completion: nil)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: sectionHeaderIdentifier, for: indexPath as IndexPath) as! CollectionReusableSearchView
            headerView.searchBar.delegate = self
            searchBar = headerView.searchBar
            return headerView
        default:
            fatalError("Invalid UICollectionElementKind for this collection view")
        }
    }
}

// MARK: - UICollectionViewDelegate

extension PhotoCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // load more photos when scrolling to the last cell
        let indexOfLastPhoto = photos.count - 1
        if indexPath.item == indexOfLastPhoto {
            // don't attempt to load more search results if the end has been reached
            if collectionType == .search,
                pageNumber == currentSearchTotalPages {
                print("do NOT load more photos... reached last page of search results")
                return
            }
            
            pageNumber += 1
            loadPhotos(showLoadingIndicator: false)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = photos[indexPath.item]
        delegate?.unsplashPickerDidFinishPicking(photo: photo)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension PhotoCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var cellWidth: CGFloat = 0
        var columns: CGFloat = 1
        
        if currentLayoutStyle == .grid {
            let portraitWidthOfPlusSizePhones: CGFloat = 414.0
            if view.bounds.size.width > portraitWidthOfPlusSizePhones {
                columns = 4
            } else {
                columns = 2
            }
        }
        
        cellWidth = (view.bounds.size.width - cellSpacing * (columns - 1)) / columns
        
        switch currentLayoutStyle {
        case .stacked:
            let photo = photos[indexPath.item]
            var cellHeight = cellWidth
            if let width = photo.size?.width, let height = photo.size?.height {
                let scale = cellWidth / width
                cellHeight = height * scale
            }
            return CGSize(width: cellWidth, height: cellHeight)
        case .grid:
            return CGSize(width: cellWidth, height: cellWidth)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.bounds.width, height: searchBarHeight)
    }
}
