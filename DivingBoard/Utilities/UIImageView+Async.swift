//
//  UIImageView+Async.swift
//  DivingBoard
//
//  Created by Jim Rhoades on 2/16/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import UIKit

public extension UIImageView {
    /**
     Used to load an image asynchronously from a given URL. If the image has already been downloaded, it's retrieved from a cache.
     
     - Parameter url: The URL for the image to display.
     - Parameter completion: Invoked when the image has been displayed, or when the image has failed to load.
     */
    public func loadImageAsync(with url: URL, completion: ((_ success: Bool) -> Void)?) {
        let cache = ImageCache.shared
        let request = URLRequest(url: url)
        if let data = cache.cachedResponse(for: request)?.data,
            let cachedImage = UIImage(data: data) {
            image = cachedImage
            completion?(true)
        } else {
            image = nil
            URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
                guard let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200,
                    let downloadedImage = UIImage(data: data) else {
                        completion?(false)
                        return
                }
                
                let cachedData = CachedURLResponse(response: response, data: data)
                cache.storeCachedResponse(cachedData, for: request)
                
                DispatchQueue.main.async {
                    self?.alpha = 0
                    self?.image = downloadedImage
                    UIView.animate(withDuration: 0.25, animations: {
                        self?.alpha = 1.0
                    }, completion: { completed in
                        completion?(true)
                    })
                }
            }).resume()
        }
    }
}

class ImageCache {
    static let shared = URLCache(memoryCapacity: 4 * 1024 * 1024,
                                 diskCapacity: 20 * 1024 * 1024,
                                 diskPath: "DivingBoard")
    
    private init() { }
}
