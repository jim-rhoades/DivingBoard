//
//  UnsplashPhoto.swift
//  DivingBoard
//
//  Created by Jim Rhoades on 2/16/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import Foundation

public struct UnsplashPhoto: Codable {
    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let width: Int
    public let height: Int
    public let color: String // hex string like #60544D
    public let description: String?
    public let urls: URLs
    public let links: Links
    public let likes: Int
    public let user: UnsplashUser
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case width
        case height
        case color
        case description
        case urls
        case links
        case likes
        case user
    }
    
    public struct URLs: Codable {
        public let raw: URL
        public let full: URL
        public let regular: URL
        public let small: URL
        public let thumb: URL
    }
    
    public struct Links: Codable {
        public let html: URL
        public let download: URL
    }
    
    public var size: CGSize {
        get {
            return CGSize(width: width, height: height)
        }
    }
}
