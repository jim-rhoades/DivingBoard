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
    var searchOrientation: UnsplashPhotoOrientation? = nil
    let reuseIdentifier = "Cell"
    let sectionHeaderIdentifier = "SectionHeader"
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
        configureLayoutButton()
        
        guard isModal, // continue only if presented modally
            let navigationController = navigationController else {
                return
        }
        navigationController.navigationBar.setValue(true, forKey: "hidesShadow") // hide shadow line
        navigationController.navigationBar.barTintColor = commonBarColor
        navigationController.hidesBarsOnSwipe = true // hide navigation bar when scrolling down
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
    
    // MARK: - Layout style switching
    
    func configureLayoutButton() {
        let bundle = Bundle(for: DivingBoard.self)
        guard let stackedImage = UIImage(named: "layoutButtonStacked", in: bundle, compatibleWith: nil),
            let gridImage = UIImage(named: "layoutButtonGrid", in: bundle, compatibleWith: nil) else {
                fatalError("failed to load layout button image")
        }
        
        let button = UIButton(type: .custom)
        if #available(iOS 11.0, *) {
            button.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
            button.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        } else {
            button.frame = CGRect(x: 0, y: 0, width: 44.0, height: 44.0)
        }
        
        button.addTarget(self, action: #selector(layoutButtonPressed(_:)), for: .touchUpInside)
        switch currentLayoutStyle {
        case .stacked:
            button.setImage(gridImage, for: .normal)
        case .grid:
            button.setImage(stackedImage, for: .normal)
        }
        
        let barButton = UIBarButtonItem(customView: button)
        if isModal {
            button.contentHorizontalAlignment = .left
            navigationItem.leftBarButtonItem = barButton
        } else {
            // unsplashPicker was presented by pushing it onto a navigationController stack
            // so place button on right (leaving "< Back" button on left)
            button.contentHorizontalAlignment = .right
            navigationItem.rightBarButtonItem = barButton
        }
    }
    
    @objc func layoutButtonPressed(_ sender: Any) {
        switch currentLayoutStyle {
        case .stacked:
            currentLayoutStyle = .grid
        case .grid:
            currentLayoutStyle = .stacked
        }
        
        configureLayoutButton()
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
                                                   searchPhrase: currentSearchPhrase,
                                                   searchOrientation: searchOrientation) else {
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
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: sectionHeaderIdentifier, for: indexPath as IndexPath) as! CollectionReusableSearchView
            headerView.searchBar.delegate = self
            
            // if an initial search phrase was provided, set the searchBar text
            if searchBar == nil, let searchPhrase = currentSearchPhrase {
                headerView.searchBar.text = searchPhrase
            }
            
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
