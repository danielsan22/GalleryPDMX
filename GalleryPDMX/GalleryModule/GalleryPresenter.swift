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
    var images: CurrentValueSubject<[GalleryImage], Never> { get }
    var shareSubject: AnyPublisher<UIImage, Never> { get }
    var showEmptyScreen: AnyPublisher<Bool, Never> { get }
    
    func fetch()
    
    func loadNextPage(for indexPath: IndexPath)
    
    func needAnimation(for indexPath: IndexPath) -> Bool
    
    func cellSelected(at indexPath: IndexPath)
}

class GalleryPresenter: GalleryPresenting {
    
    private let interactor: GalleryInteracting
    private var animationCache: [Int: Bool] = [:]
    private var subscriptions = Set<AnyCancellable>()
    
    private(set) var isLoading = CurrentValueSubject<Bool, Never>(false)
    private(set) var images = CurrentValueSubject<[GalleryImage], Never>([])
    private let _shareSubject = PassthroughSubject<UIImage, Never>()
    private let _showEmptyScreen = PassthroughSubject<Bool, Never>()
    
    var shareSubject: AnyPublisher<UIImage, Never> { _shareSubject.eraseToAnyPublisher() }
    var showEmptyScreen: AnyPublisher<Bool, Never> { _showEmptyScreen.eraseToAnyPublisher() }
    
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
                if case .failure = completion {
                    self._showEmptyScreen.send(true)
                }
                self.isLoading.send(false)
            }, receiveValue: { (result: GallerySearchResponse) in
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
    
    func needAnimation(for indexPath: IndexPath) -> Bool {
        if animationCache[indexPath.row] != nil {
            return false
        }
        animationCache[indexPath.row] = true
        return true
    }
    
    func cellSelected(at indexPath: IndexPath) {
        let image = images.value[indexPath.row]
        guard let imageURL = URL(string: image.urls.regular) else { return }
        Task {
            if let image = await downloadImage(for: imageURL) {
                self._shareSubject.send(image)
            }
        }
    }
    
    private func downloadImage(for url: URL) async -> UIImage? {
        let imageDownloadResult = try? await URLSession.shared.data(for: URLRequest(url: url))
        if let data = imageDownloadResult?.0 {
            return UIImage(data: data)
        }
        return nil
    }
}
