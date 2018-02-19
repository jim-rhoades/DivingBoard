//
//  User.swift
//  UnsplashPickerController
//
//  Created by Jim Rhoades on 2/16/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import Foundation

// TODO: change to "UnsplashUser"?
struct User: Codable {
    let id: String
    let username: String
    let name: String
    let profileImage: ProfileImage
    let links: Links
    
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
    
    struct ProfileImage: Codable {
        let small: URL
        let medium: URL
        let large: URL
    }
    
    struct Links: Codable {
        // let selfURL: URL // the API uses 'self', but we can't use that
        let html: URL
        
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
