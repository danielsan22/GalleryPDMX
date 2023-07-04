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
    private let client: GalleryClient
    private(set) var total: Int = 0
    private(set) var totalPages: Int = 0
    private(set) var currentPage = 0
    private var currentItems = 0
    
    init(provider: GalleryClient) {
        self.client = provider
    }
    
    func fetchGallery() -> AnyPublisher<GallerySearchResponse, Error> {
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

