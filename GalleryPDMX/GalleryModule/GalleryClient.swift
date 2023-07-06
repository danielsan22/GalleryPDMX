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

protocol GalleryClientProviding {
    
    func fetchImages(page: Int) -> AnyPublisher<GallerySearchResponseDTO, Error>
}

struct GalleryClient: GalleryClientProviding {
    
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
}

struct GalleryMockClient: GalleryClientProviding {
    
    func fetchImages(page: Int) -> AnyPublisher<GallerySearchResponseDTO, Error> {
        Future<GallerySearchResponseDTO, Error> { promise in
            guard let url = Bundle.main.url(forResource: "mock", withExtension: "json") else {
                promise(.failure(GalleryClientError.invalidResponse))
                return
            }
            guard let data = try? Data(contentsOf: url),
                  let result = try? galleryJSonDecoder.decode(GallerySearchResponseDTO.self, from: data) else {
                promise(.failure(GalleryClientError.invalidResponse))
                return
            }
            promise(.success(result))
        }.eraseToAnyPublisher()
    }
}

struct FailingGalleryMockClient: GalleryClientProviding {
    
    func fetchImages(page: Int) -> AnyPublisher<GallerySearchResponseDTO, Error> {
        Fail(error: GalleryClientError.invalidResponse).eraseToAnyPublisher()
    }
}

private let galleryJSonDecoder: JSONDecoder = {
    let jsonDecoder = JSONDecoder()
    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    return jsonDecoder
}()
