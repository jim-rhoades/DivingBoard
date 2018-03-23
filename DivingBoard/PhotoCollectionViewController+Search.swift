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
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = UIColor(white: 247.0/255.0, alpha: 0.9)
            
            // ugly fix for issue where cursor animates in from upper left
            // https://stackoverflow.com/q/46367768/234609
            let previousTintColor = textField.tintColor
            textField.tintColor = .clear
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                textField.tintColor = previousTintColor
            }
        }
        addSubview(searchBar)
    }
}

extension PhotoCollectionViewController {
    func configureToShowSearchBar() {
        // prepare to add the UISearchBar as a section header in collectionView
        collectionView?.register(CollectionReusableSearchView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: sectionHeaderIdentifier)
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.sectionHeadersPinToVisibleBounds = true
        }
    }
    
    func showKeyboardIfNeeded() {
        if let searchBar = searchBar,
            collectionType == .search,
            photos.count == 0 {
            searchBar.becomeFirstResponder()
        }
    }
    
    func hideKeyboardIfNeeded() {
        if collectionType == .search {
            searchBar?.resignFirstResponder()
        }
    }
}

// MARK: - UISearchBarDelegate

extension PhotoCollectionViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // reset for a new search
        photos.removeAll()
        pageNumber = 1
        currentSearchPhrase = nil
        
        // the new search might not produce any results,
        // so reloadData immediately to prevent old results from still showing
        collectionView?.reloadData()
        
        // perform the search
        if let searchPhrase = searchBar.text,
            searchPhrase != "" {
            currentSearchPhrase = searchPhrase
            
            // display a loading indicator
            loadingView = LoadingView()
            view.addCenteredSubview(loadingView!)
            
            loadPhotos()
        }
        searchBar.resignFirstResponder()
    }
}
