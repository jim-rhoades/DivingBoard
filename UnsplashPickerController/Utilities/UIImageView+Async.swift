//
//  UIImageView+Async.swift
//  UnsplashPickerController
//
//  Created by Jim Rhoades on 2/16/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//
//
//  slightly modified from: https://stackoverflow.com/a/45183939/234609

import UIKit

public extension UIImageView {
    private static var taskKey = 0
    private static var urlKey = 0
    
    private var currentTask: URLSessionTask? {
        get { return objc_getAssociatedObject(self, &UIImageView.taskKey) as? URLSessionTask }
        set { objc_setAssociatedObject(self, &UIImageView.taskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    private var currentURL: URL? {
        get { return objc_getAssociatedObject(self, &UIImageView.urlKey) as? URL }
        set { objc_setAssociatedObject(self, &UIImageView.urlKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    public func loadImageAsync(with url: URL?) {
        // cancel prior task, if any
        weak var oldTask = currentTask
        currentTask = nil
        oldTask?.cancel()
        
        // reset imageview's image
        self.image = nil
        
        // allow supplying of `nil` to remove old image and then return immediately
        guard let url = url else { return }
        
        // check cache
        if let cachedImage = ImageCache.shared.image(forKey: url.absoluteString) {
            self.image = cachedImage
            return
        }
        
        // download
        currentURL = url
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            self?.currentTask = nil
            
            // error handling
            if let error = error {
                // don't bother reporting cancelation errors
                if (error as NSError).domain == NSURLErrorDomain && (error as NSError).code == NSURLErrorCancelled {
                    return
                }
                
                print(error)
                return
            }
            
            guard let data = data, let downloadedImage = UIImage(data: data) else {
                print("unable to extract image")
                return
            }
            
            ImageCache.shared.save(image: downloadedImage, forKey: url.absoluteString)
            
            if url == self?.currentURL {
                DispatchQueue.main.async {
                    self?.alpha = 0
                    self?.image = downloadedImage
                    UIView.animate(withDuration: 0.25, animations: {
                        self?.alpha = 1.0
                    })
                }
            }
        }
        
        // save and start new task
        currentTask = task
        task.resume()
    }
}

class ImageCache {
    private let cache = NSCache<NSString, UIImage>()
    private var observer: NSObjectProtocol!
    
    static let shared = ImageCache()
    
    private init() {
        // TODO: limit memory usage?
        // cache.totalCostLimit = 10 * 1024 * 1024 // maximum of 10MB
        
        // make sure to purge cache on memory pressure
        observer = NotificationCenter.default.addObserver(forName: .UIApplicationDidReceiveMemoryWarning, object: nil, queue: nil) { [weak self] notification in
            self?.cache.removeAllObjects()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(observer)
    }
    
    func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func save(image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
