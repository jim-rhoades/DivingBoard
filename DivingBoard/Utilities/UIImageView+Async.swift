//
//  UIImageView+Async.swift
//  DivingBoard
//
//  Created by Jim Rhoades on 2/16/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//
//  With help from: https://stackoverflow.com/a/45183939/234609

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
    
    /**
     Used to load an image asynchronously from a given URL. If the image has already been downloaded, it's retrieved from a cache.
     
     - Parameter url: The URL for the image to display.
     - Parameter completion: Invoked when the image has been displayed, or when the image has failed to load.
     */
    public func loadImageAsync(with url: URL, completion: ((_ success: Bool) -> Void)?) {
        // cancel prior task, if any
        weak var oldTask = currentTask
        currentTask = nil
        oldTask?.cancel()
        
        // use the cached image if possible
        let cache = ImageCache.shared
        let request = URLRequest(url: url)
        if let cachedData = cache.cachedResponse(for: request)?.data,
            let cachedImage = UIImage(data: cachedData) {
            image = cachedImage
            completion?(true)
            return
        }
        
        // image wasn't in the cache, so download it
        image = nil // remove old image
        currentURL = url
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            self?.currentTask = nil
            
            if let error = error as NSError? {
                // don't log task cancellation errors
                if error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
                    completion?(false)
                    return
                }
                
                print(error)
                completion?(false)
                return
            }
            
            guard let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let downloadedImage = UIImage(data: data) else {
                    completion?(false)
                    return
            }
            
            let cachedResponse = CachedURLResponse(response: response, data: data)
            cache.storeCachedResponse(cachedResponse, for: request)
            
            if url == self?.currentURL {
                DispatchQueue.main.async {
                    self?.alpha = 0
                    self?.image = downloadedImage
                    UIView.animate(withDuration: 0.25, animations: {
                        self?.alpha = 1.0
                    }, completion: { completed in
                        completion?(true)
                    })
                }
            }
        })
        
        currentTask = task
        task.resume()
    }
}

class ImageCache {
    static let shared = URLCache(memoryCapacity: 4 * 1024 * 1024,
                                 diskCapacity: 20 * 1024 * 1024,
                                 diskPath: "DivingBoard")
    
    private init() { }
}
