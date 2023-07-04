//
//  ViewController.swift
//  GalleryPDMX
//
//  Created by Daniel Sanchez on 03/07/23.
//

import Combine
import UIKit

class ViewController: UIViewController {
    
    private let galleryClient: GalleryClient
    private var subscriptions = Set<AnyCancellable>()
    private var images: [GalleryImage] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    private var total: Int = 0
    private var totalPages: Int = 0
    private var currentPage = 1
    private var isLoading = false
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout())
        cv.register(CardCell.self, forCellWithReuseIdentifier: "Cell")
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    init(galleryClient: GalleryClient) {
        self.galleryClient = galleryClient
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadData()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.layout {
            $0.leftAnchor.constraint(equalTo: view.leftAnchor)
            $0.rightAnchor.constraint(equalTo: view.rightAnchor)
            $0.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
            $0.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        }
    }
    
    private func makeCollectionViewLayout() -> UICollectionViewLayout {
        let l = UICollectionViewCompositionalLayout { sectionIndex, environment in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.5))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
        return l
    }
    
    private func loadData() {
        isLoading = true
        galleryClient
            .fetchImages(page: currentPage)
            .asyncMap { response in
                var response = response
                let images = try? await response
                    .results
                    .concurrentMap { item in
                        var item = item
                        guard let imageURL = URL(string: item.urls?.small ?? "") else { return item }
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
            .sink { [weak self] completion in
                print(completion)
                self?.isLoading = false
            } receiveValue: { [weak self] (result: GallerySearchResponse) in
                print("receive value")
                self?.images.append(contentsOf: result.results)
                self?.total = result.total ?? 0
                self?.totalPages = result.totalPages ?? 0
            }.store(in: &subscriptions)
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CardCell
        let item = images[indexPath.row]
        cell.label.text = item.description ?? item.altDescription ?? "No Description"
        cell.imageView.image = item.image
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if currentPage < totalPages && indexPath.row == images.count - 1 && !isLoading {
            currentPage = currentPage + 1
            isLoading = true
            print("fetching new for page \(currentPage)")
//            loadData()
        }
    }
}
