//
//  GalleryModels.swift
//  GalleryPDMX
//
//  Created by Daniel Sanchez on 04/07/23.
//

import Foundation
import UIKit

struct GalleryImage: Decodable {
    var id: String?
    var slug: String?
    var width: Int?
    var height: Int?
    var description: String?
    var altDescription: String?
    var urls: GalleryImageURLS?
    var image: UIImage?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case slug = "slug"
        case width = "width"
        case height = "height"
        case description = "description"
        case altDescription = "alt_description"
        case urls = "urls"
    }
}

struct GalleryImageURLS: Decodable {
    var raw: String
    var full: String
    var regular: String
    var small: String
    var thumb: String
}

struct GallerySearchResponse: Decodable {
    var total: Int?
    var totalPages: Int?
    var results: [GalleryImage]
}
