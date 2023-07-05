//
//  GalleryPDMXTests.swift
//  GalleryPDMXTests
//
//  Created by Daniel Sanchez on 05/07/23.
//

import Combine
import XCTest
@testable import GalleryPDMX

final class GalleryPDMXTests: XCTestCase {

    var subscriptions = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        subscriptions = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
    }

    func testPagination() throws {
        let galleryClient = GalleryMockClient()
        let interactor = GalleryInteractor(client: galleryClient)
        
        interactor
            .fetchGallery()
            .sink { _ in
            } receiveValue: { _ in }
            .store(in: &subscriptions)
        
        XCTAssert(interactor.currentPage == 1, "Page gets incremented after fetching")
        
        interactor.fetchGallery()
            .sink(receiveCompletion: {_ in }, receiveValue: { _ in })
            .store(in: &subscriptions)
        interactor.fetchGallery()
            .sink(receiveCompletion: {_ in }, receiveValue: { value in
                XCTAssert(value.results.isEmpty, "When the last page is reached out, the subsequent calls should return an empty data set")
            }).store(in: &subscriptions)
        
        XCTAssertEqual(interactor.currentPage, 2, "Page does not increment once the last data set was fetched.")
    }

}
