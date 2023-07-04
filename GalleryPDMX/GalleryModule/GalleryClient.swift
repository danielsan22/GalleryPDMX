//
//  GalleryClient.swift
//  GalleryPDMX
//
//  Created by Daniel Sanchez on 03/07/23.
//

import Combine
import Foundation

enum GalleryClientError: Error {
    case invalidResponse
}

struct GalleryClient {
    
    func fetchImages(page: Int) -> AnyPublisher<GallerySearchResponseDTO, Error> {
        var request = URLRequest(url: URL(string: "https://api.unsplash.com/search/photos?query=porsche&per_page=20&page=\(page)")!)
        request.allHTTPHeaderFields = [
            "Accept-Version": "v1",
            "Authorization": "Client-ID \(Config.unsplashAccessKey)"
        ]
        
        return URLSession
            .shared
            .dataTaskPublisher(for: request)
            .map { data, _ in data }
            .decode(type: GallerySearchResponseDTO.self, decoder: galleryJSonDecoder)
            .eraseToAnyPublisher()
    }
    
    private let galleryJSonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }()
}
