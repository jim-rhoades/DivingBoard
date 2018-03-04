//
//  UnsplashUser.swift
//  DivingBoard
//
//  Created by Jim Rhoades on 2/16/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import Foundation

public struct UnsplashUser: Codable {
    public let id: String
    public let username: String
    public let name: String
    public let firstName: String
    public let lastName: String?
    public let portfolioURL: URL?
    public let bio: String?
    public let location: String?
    public let profileImage: ProfileImage
    public let links: Links
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case name
        case firstName = "first_name"
        case lastName = "last_name"
        case portfolioURL = "portfolio_url"
        case bio
        case location
        case profileImage = "profile_image"
        case links
    }
    
    public struct ProfileImage: Codable {
        public let small: URL
        public let medium: URL
        public let large: URL
    }
    
    public struct Links: Codable {
        public let html: URL
    }
}
