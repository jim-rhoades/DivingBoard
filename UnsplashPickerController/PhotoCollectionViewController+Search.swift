//
//  PhotoCollectionViewController+Search.swift
//  UnsplashPickerController
//
//  Created by Jim Rhoades on 2/22/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import UIKit

extension PhotoCollectionViewController {
    func configureSearchBar() {
        let searchBarFrame = CGRect(x: 0,
                                    y: view.safeAreaInsets.top + topInsetAdjustment,
                                    width: view.bounds.width,
                                    height: 56.0) // default height
        searchBar = UISearchBar(frame: searchBarFrame)
        guard let searchBar = searchBar else {
            return
        }
        
        searchBar.autoresizingMask = [.flexibleWidth]
        searchBar.backgroundImage = UIImage()
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = UIColor(white: 247.0/255.0, alpha: 0.9)
        }
        searchBar.delegate = self
        view.addSubview(searchBar)
        searchBar.becomeFirstResponder()
        
        // adjust insets to make room for the searchBar
        collectionView?.contentInset.top += searchBar.frame.size.height
        collectionView?.scrollIndicatorInsets.top += searchBar.frame.size.height
    }
}

// MARK: - UISearchBarDelegate

extension PhotoCollectionViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // reset for a new search
        photos.removeAll()
        pageNumber = 1
        currentSearchPhrase = nil
        
        // perform the search
        if let searchPhrase = searchBar.text,
            searchPhrase != "" {
            currentSearchPhrase = searchPhrase
            
            // display a loading indicator
            loadingView = LoadingView()
            view.addCenteredSubview(view: loadingView!)
            
            loadPhotos()
        }
        searchBar.resignFirstResponder()
    }
}
