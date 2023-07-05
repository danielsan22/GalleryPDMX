//
//  GalleryInteractor.swift
//  GalleryPDMX
//
//  Created by Daniel Sanchez on 04/07/23.
//

import Combine
import Foundation

protocol GalleryInteracting {
    
    func fetchGallery() -> AnyPublisher<GallerySearchResponse, Error>
        
    func hasMorePages(for indexPath: IndexPath) -> Bool
    
}

class GalleryInteractor: GalleryInteracting {
    private let client: GalleryClientProviding
    private(set) var total: Int = 0
    private(set) var totalPages: Int = 0
    private(set) var currentPage = 0
    private var currentItems = 0
    
    init(client: GalleryClientProviding) {
        self.client = client
    }
    
    func fetchGallery() -> AnyPublisher<GallerySearchResponse, Error> {
        guard currentPage == 0 || currentPage < totalPages else {
            return Just(
                GallerySearchResponse(
                    total: total,
                    totalPages: totalPages,
                    results: []))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }
        
        currentPage += 1
        return client
            .fetchImages(page: currentPage)
            .tryMap {
                guard let response = GallerySearchResponse(dto: $0) else {
                    throw GalleryClientError.invalidResponse
                }
                self.currentItems += response.results.count
                self.total = response.total
                self.totalPages = response.totalPages
                return response
            }
            .eraseToAnyPublisher()
    }
    
    func hasMorePages(for indexPath: IndexPath) -> Bool {
        return currentPage < totalPages && indexPath.row == currentItems - 1
    }
}

