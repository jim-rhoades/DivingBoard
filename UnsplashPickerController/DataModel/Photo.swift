//
//  Photo.swift
//  UnsplashPickerController
//
//  Created by Jim Rhoades on 2/16/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import Foundation

// TODO: change to "UnsplashPhoto"?
struct Photo: Codable {
    let id: String
    
    /*
     let createdAt: Date
     let updatedAt: Date
     let width: Int
     let height: Int
     let color: String // hex string like #60544D
     let likes: Int
     let likedByUser: Bool
     let description: String?
     */
    
    let user: User
    let urls: URLs
    let links: Links
    
    // TODO: handle 'current_user_collections'?
    // that might only be necessary if logged into Unsplash while making the API call
    // and this says you don't have to parse every element, so leaving it out should be fine:
    // https://grokswift.com/json-swift-4/
    
    enum CodingKeys: String, CodingKey {
        case id
        
        /*
         case createdAt = "created_at"
         case updatedAt = "updated_at"
         case width
         case height
         case color
         case likes
         case likedByUser = "liked_by_user"
         case description
         */
        
        case user
        case urls
        case links
    }
    
    struct URLs: Codable {
        let raw: URL
        let full: URL
        let regular: URL
        let small: URL
        let thumb: URL
    }
    
    struct Links: Codable {
        let selfURL: URL // the API uses 'self', but we can't use that
        let html: URL
        let download: URL
        let downloadLocation: URL
        
        enum CodingKeys: String, CodingKey {
            case selfURL = "self"
            case html
            case download
            case downloadLocation = "download_location"
        }
    }
}
