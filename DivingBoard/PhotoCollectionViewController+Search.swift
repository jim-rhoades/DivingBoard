//
//  PhotoCollectionViewController+Search.swift
//  DivingBoard
//
//  Created by Jim Rhoades on 2/22/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import UIKit

// MARK: - Search bar

let searchBarHeight: CGFloat = 56.0

class CollectionReusableSearchView: UICollectionReusableView {
    var searchBar: UISearchBar!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        let searchBarFrame = CGRect(x: 0,
                                    y: 0,
                                    width: bounds.width,
                                    height: searchBarHeight) // default height
        searchBar = UISearchBar(frame: searchBarFrame)
        searchBar.autoresizingMask = [.flexibleWidth]
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = commonBarColor
	searchBar.placeholder = "Search"
        addSubview(searchBar)
    }
}

extension PhotoCollectionViewController {
    func configureSearchBar() {
        // prepare to add the UISearchBar as a section header in collectionView
        collectionView?.register(CollectionReusableSearchView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: sectionHeaderIdentifier)
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.sectionHeadersPinToVisibleBounds = true
        }
    }
}

// MARK: - UISearchBarDelegate

extension PhotoCollectionViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // if a search was performed, reset and show .new photos again
        if collectionType == .search {
            reset()
            collectionType = .new
            loadPhotos(showLoadingIndicator: true)
        }
        searchBar.text = nil
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        reset()
        collectionType = .search
        
        // perform the search
        if let searchPhrase = searchBar.text,
            !searchPhrase.isEmpty {
            currentSearchPhrase = searchPhrase
            loadPhotos(showLoadingIndicator: true)
        }
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func reset() {
        photos.removeAll()
        pageNumber = 1
        currentSearchPhrase = nil
        collectionView?.reloadData()
    }
}
