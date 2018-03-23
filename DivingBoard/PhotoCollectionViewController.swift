//
//  PhotoCollectionViewController.swift
//  DivingBoard
//
//  Created by Jim Rhoades on 2/15/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class PhotoCollectionViewController: UICollectionViewController {
    
    var clientID: String?
    weak var delegate: UnsplashPickerDelegate?
    var topInsetAdjustment: CGFloat = 0
    var collectionType: CollectionType = .new
    let cellSpacing: CGFloat = 2 // spacing between the photo thumbnails
    var loadingView: LoadingView?
    var photos: [UnsplashPhoto] = []
    var pageNumber = 1
    var searchBar: UISearchBar?
    var currentSearchPhrase: String?
    var currentSearchTotalPages: Int = 0
    let sectionHeaderIdentifier = "SectionHeader"
    
    // MARK: - Layout style switching
    
    var currentIndexPath: IndexPath?
    var currentLayoutStyle: LayoutStyle = .grid {
        willSet {
            // abort if view not loaded to prevent UI glitch
            guard isViewLoaded,
                let collectionView = collectionView else {
                return
            }
            // abort if scrolled to top
            if collectionView.contentOffset.y == -topInsetAdjustment {
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
            if collectionView.contentOffset.y == -topInsetAdjustment {
                return
            }
            
            // scroll to the same item that was being displayed near the center
            if let currentIndexPath = currentIndexPath {
                collectionView.scrollToItem(at: currentIndexPath, at: .centeredVertically, animated: false)
            }
        }
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // adjust insets to make room for the collectionTypePickerView
        collectionView?.contentInset.top += topInsetAdjustment
        collectionView?.scrollIndicatorInsets.top += topInsetAdjustment
        
        if collectionType == .search {
            configureToShowSearchBar()
        } else {
            // display a loading indicator
            loadingView = LoadingView()
            view.addCenteredSubview(loadingView!)
            
            // load photos from Unsplash
            loadPhotos()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionViewLayout.invalidateLayout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Photo loading
    
    func loadPhotos() {
        guard let url = UnsplashClient.urlForJSONRequest(withClientID: clientID,
                                                   collectionType: collectionType,
                                                   resultsPerPage: 40,
                                                   pageNumber: pageNumber,
                                                   searchPhrase: currentSearchPhrase) else {
            return
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
            loadPhotos()
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
            let scale = cellWidth / photo.size.width
            let cellHeight = photo.size.height * scale
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
        if collectionType == .search {
            return CGSize(width: view.bounds.width, height: searchBarHeight)
        } else {
            return CGSize.zero
        }
    }
}
