//
//  User.swift
//  UnsplashPickerController
//
//  Created by Jim Rhoades on 2/16/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import Foundation

public struct UnsplashUser: Codable {
    public let id: String
    public let username: String
    public let name: String
    public let profileImage: ProfileImage
    public let links: Links
    
    /*
     let portfolioURL: URL
     let bio: String?
     let location: String?
     let totalLikes: Int
     let totalPhotos: Int
     let totalCollections: Int
     */
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case name
        case profileImage = "profile_image"
        case links
        
        /*
         case portfolioURL = "portfolio_url"
         case bio
         case location
         case totalLikes = "total_likes"
         case totalPhotos = "total_photos"
         case totalCollections = "total_collections"
         */
    }
    
    public struct ProfileImage: Codable {
        public let small: URL
        public let medium: URL
        public let large: URL
    }
    
    public struct Links: Codable {
        // let selfURL: URL // the API uses 'self', but we can't use that
        public let html: URL
        
        // TODO: use 'photos' if I decide to allow viewing of that user's photos
        // let photos: URL
        // let likes: URL
        // let portfolio: URL
        
        /*
         enum CodingKeys: String, CodingKey {
         // case selfURL = "self"
         case html
         case photos
         // case likes
         case portfolio
         }
         */
    }
}
