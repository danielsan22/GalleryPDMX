//
//  GalleryProvider.swift
//  GalleryPDMX
//
//  Created by Daniel Sanchez on 03/07/23.
//

import Combine
import Foundation

struct GalleryClient {
    
    func fetchImages(page: Int = 1) -> AnyPublisher<GallerySearchResponse, Error> {
        var request = URLRequest(url: URL(string: "https://api.unsplash.com/search/photos?query=porsche&per_page=20&page=\(page)")!)
        request.allHTTPHeaderFields = [
            "Accept-Version": "v1",
            "Authorization": "Client-ID \(Config.unsplashAccesKey)"
        ]
        
        return URLSession
            .shared
            .dataTaskPublisher(for: request)
            .map { data, _ in data }
            .decode(type: GallerySearchResponse.self, decoder: galleryJSonDecoder)
            .eraseToAnyPublisher()
    }
    
    private let galleryJSonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }()
}
