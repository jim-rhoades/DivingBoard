//
//  UnsplashSearchResults.swift
//  DivingBoard
//
//  Created by Jim Rhoades on 2/22/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import Foundation

struct UnsplashSearchResults: Codable {
    let total: Int
    let totalPages: Int
    let results: [UnsplashPhoto]
    
    enum CodingKeys: String, CodingKey {
        case total
        case totalPages = "total_pages"
        case results
    }
}

enum UnsplashPhotoOrientation: String {
    case landscape
    case portrait
    case squarish
}
