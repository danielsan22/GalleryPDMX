//
//  GalleryPresenter.swift
//  GalleryPDMX
//
//  Created by Daniel Sanchez on 04/07/23.
//

import Combine
import Foundation
import UIKit

protocol GalleryPresenting {
    
    func fetch()
    
    func loadNextPage(for indexPath: IndexPath)
}

class GalleryPresenter: GalleryPresenting {
    
    private let interactor: GalleryInteracting
    private var subscriptions = Set<AnyCancellable>()
    private(set) var isLoading = CurrentValueSubject<Bool, Never>(false)
    private(set) var images = CurrentValueSubject<[GalleryImage], Never>([])
    
    init(interactor: GalleryInteracting) {
        self.interactor = interactor
    }
    
    func fetch() {
        isLoading.send(true)
        interactor
            .fetchGallery()
            .asyncMap { response in
                var response = response
                let images = try? await response
                    .results
                    .concurrentMap { item in
                        var item = item
                        guard let imageURL = URL(string: item.urls.small) else { return item }
                        let imageDownloadResult = try? await URLSession.shared.data(for: URLRequest(url: imageURL))
                        if let data = imageDownloadResult?.0 {
                            item.image = UIImage(data: data)
                        }
                        return item
                    }
                response.results = images ?? []
                return response
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isLoading.send(false)
                print("finished withCompletion:  \(completion)")
            }, receiveValue: { (result: GallerySearchResponse) in
                print(result.results.count)
                var imgs = self.images.value
                imgs.append(contentsOf: result.results)
                self.isLoading.send(false)
                self.images.send(imgs)
            }).store(in: &subscriptions)
    }
    
    func loadNextPage(for indexPath: IndexPath) {
        if interactor.hasMorePages(for: indexPath) && !isLoading.value {
            fetch()
        }
    }
}
