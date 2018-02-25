//
//  Photo.swift
//  UnsplashPickerController
//
//  Created by Jim Rhoades on 2/16/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import Foundation

public struct UnsplashPhoto: Codable {
    public let id: String
    
    /*
     let createdAt: Date
     let updatedAt: Date
     let likes: Int
     let likedByUser: Bool
     let description: String?
     */
    
    public let width: Int
    public let height: Int
    public let color: String // hex string like #60544D
    public let user: UnsplashUser
    public let urls: URLs
    public let links: Links
    
    enum CodingKeys: String, CodingKey {
        case id
        
        /*
         case createdAt = "created_at"
         case updatedAt = "updated_at"
         
         case color
         case likes
         case likedByUser = "liked_by_user"
         case description
         */
        
        case width
        case height
        case color
        case user
        case urls
        case links
    }
    
    public struct URLs: Codable {
        public let raw: URL
        public let full: URL
        public let regular: URL
        public let small: URL
        public let thumb: URL
    }
    
    public struct Links: Codable {
        public let selfURL: URL // the API uses 'self', but we can't use that
        public let html: URL
        public let download: URL
        public let downloadLocation: URL
        
        enum CodingKeys: String, CodingKey {
            case selfURL = "self"
            case html
            case download
            case downloadLocation = "download_location"
        }
    }
    
    public var size: CGSize {
        get {
            return CGSize(width: width, height: height)
        }
    }
}
