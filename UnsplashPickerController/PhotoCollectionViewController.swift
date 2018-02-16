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
    
    // TODO: make this something you have to provide while creating the UnsplashPickerController
    private let appID = "a8c9e9169a140922f4b1d4cfb744a8f01c45244842b0306a1dd107c2516d9bfb"
    
    private let cellSpacing: CGFloat = 2 // spacing between the photo thumbnails
    private var photos: [Photo] = []
    private var pageNumber = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        loadPhotos()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadPhotos() {
        guard let url = URL(string: "https://api.unsplash.com/photos?client_id=\(appID)&per_page=20&page=\(pageNumber)") else {
            print("ERROR: url was nil")
            return
        }
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: url, completionHandler: { (data, response, error) in
            
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
                self.photos.append(contentsOf: newPhotos)
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            } catch {
                print("error trying to convert data to JSON: \(error)")
            }
        })
        
        dataTask.resume()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

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
