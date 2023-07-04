//
//  GalleryModels.swift
//  GalleryPDMX
//
//  Created by Daniel Sanchez on 04/07/23.
//

import Foundation
import UIKit

struct GalleryImageDTO: Decodable {
    var id: String?
    var slug: String?
    var width: Int?
    var height: Int?
    var description: String?
    var altDescription: String?
    var urls: GalleryImageURLSDTO?
    
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

struct GalleryImageURLSDTO: Decodable {
    var raw: String?
    var full: String?
    var regular: String?
    var small: String?
    var thumb: String?
}

struct GallerySearchResponseDTO: Decodable {
    var total: Int?
    var totalPages: Int?
    var results: [GalleryImageDTO]?
}

struct GalleryImage {
    var id: String
    var slug: String?
    var width: Int
    var height: Int
    var description: String?
    var altDescription: String?
    var urls: GalleryImageURLS
    var image: UIImage?
}

struct GalleryImageURLS {
    var raw: String
    var full: String
    var regular: String
    var small: String
    var thumb: String
}

struct GallerySearchResponse {
    var total: Int
    var totalPages: Int
    var results: [GalleryImage]
}

extension GalleryImageURLS {
    
    init?(dto: GalleryImageURLSDTO) {
        guard let raw = dto.raw,
              let full = dto.full,
              let regular = dto.regular,
              let small = dto.small,
              let thumb = dto.thumb else { return nil }
        self.raw = raw
        self.full = full
        self.regular = regular
        self.small = small
        self.thumb = thumb
    }
}

extension GalleryImage {
    
    init?(dto: GalleryImageDTO) {
        guard let id = dto.id,
              let width = dto.width,
              let height = dto.height,
              let urlsDTO = dto.urls,
              let urls = GalleryImageURLS(dto: urlsDTO) else { return nil }
        
        self.id = id
        self.slug = dto.slug
        self.width = width
        self.height = height
        self.description = dto.description
        self.altDescription = dto.altDescription
        self.urls = urls
    }
}

extension GallerySearchResponse {
    
    init?(dto: GallerySearchResponseDTO) {
        guard let total = dto.total,
              let totalPages = dto.totalPages,
              let resultsDTO = dto.results else { return nil }
        
        self.total = total
        self.totalPages = totalPages
        self.results = resultsDTO.compactMap(GalleryImage.init(dto:))
    }
}
