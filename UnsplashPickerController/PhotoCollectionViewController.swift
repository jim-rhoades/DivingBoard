//
//  PhotoCollectionViewController.swift
//  UnsplashPickerController
//
//  Created by Jim Rhoades on 2/15/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class PhotoCollectionViewController: UICollectionViewController {
    
    var clientID = ""
    var topInsetAdjustment: CGFloat = 0
    var collectionType: CollectionType = .latest
    private let cellSpacing: CGFloat = 2 // spacing between the photo thumbnails
    private var photos: [Photo] = []
    private var pageNumber = 1
    private var loadingView: LoadingView?
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // adjust insets to make room for the collectionTypePickerView
        collectionView?.contentInset.top += topInsetAdjustment
        collectionView?.scrollIndicatorInsets.top += topInsetAdjustment
        
        // display a loading indicator
        loadingView = LoadingView(color: .lightGray)
        view.addCenteredSubview(view: loadingView!)
        
        // load photos from Unsplash
        loadPhotos()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Photo loading
    
    private func loadPhotos() {
        
        guard let url = unsplashURL() else {
            return
        }
        
        print(url.absoluteString)
        
        let dataTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
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
            
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            guard error == nil else {
                print(error!)
                return
            }
            
            
            // TODO: for testing purposes
            /*
             if let jsonString = String(data: responseData, encoding: .utf8) {
             print(jsonString)
             } else {
             print("FAILED TO CONVERT DATA TO JSON STRING")
             }
             */
            
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                let newPhotos = try decoder.decode([Photo].self, from: responseData)
                self?.photos.append(contentsOf: newPhotos)
                
                DispatchQueue.main.async {
                    self?.collectionView?.reloadData()
                }
            } catch {
                print("error trying to convert data to JSON: \(error)")
            }
        }
        
        dataTask.resume()
    }
    
    private func unsplashURL() -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https";
        urlComponents.host = "api.unsplash.com";
        urlComponents.path = "/photos";
        
        let clientIDItem = URLQueryItem(name: "client_id", value: clientID)
        let perPageItem = URLQueryItem(name: "per_page", value: "20")
        let pageNumberItem = URLQueryItem(name: "page", value: "\(pageNumber)")
        urlComponents.queryItems = [clientIDItem, perPageItem, pageNumberItem]
        
        if collectionType == .popular {
            let orderByItem = URLQueryItem(name: "order_by", value: "popular")
            urlComponents.queryItems?.append(orderByItem)
        }
        
        return urlComponents.url
    }

    // MARK: - UICollectionViewDataSource
    
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
        
        if cell.imageView == nil {
            print("IMAGE VIEW IS NIL???")
            return cell
        }
        
        cell.imageView.loadImageAsync(with: thumbnailURL) // load image asynchronously, using cached version if it's there
        return cell
    }

    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // load more photos when scrolling to the last cell
        let indexOfLastPhoto = photos.count - 1
        if indexPath.item == indexOfLastPhoto {
            pageNumber += 1
            loadPhotos()
        }
    }

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

// MARK: - UICollectionViewDelegateFlowLayout

extension PhotoCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var cellWidth: CGFloat = 0
        var columns: CGFloat = 2
        
        // if 'regular' horizontalSizeClass, show 4 columns
        if traitCollection.horizontalSizeClass == .regular {
            columns = 4
        }
        
        cellWidth = (self.view.bounds.size.width - cellSpacing * (columns - 1)) / columns
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
}
