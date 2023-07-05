//
//  ViewController.swift
//  GalleryPDMX
//
//  Created by Daniel Sanchez on 03/07/23.
//

import Combine
import UIKit

class ViewController: UIViewController {
    
    private var subscriptions = Set<AnyCancellable>()
    private let presenter: GalleryPresenter
    private lazy var emptyView: UIView = EmptyGalleryView()
    private let animationDuration: Double = 0.2
    private let delayBase: Double = 0.05
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout())
        cv.register(CardCell.self, forCellWithReuseIdentifier: CardCell.reuseIdentifier)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    init(presenter: GalleryPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupObservers()
        presenter.fetch()
    }
    
    private func setupObservers() {
        presenter.images.sink { data in
            self.collectionView.reloadData()
        }.store(in: &subscriptions)
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
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.images.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCell.reuseIdentifier, for: indexPath) as! CardCell
        let item = presenter.images.value[indexPath.row]
        cell.label.text = item.description ?? item.altDescription ?? "No Description"
        cell.imageView.image = item.image
        cell.contentView.alpha = 0.0
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        presenter.loadNextPage(for: indexPath)
        
        let delay = sqrt(Double(indexPath.row)) * delayBase
        
        UIView.animate(withDuration: animationDuration, delay: delay, options: .curveEaseOut, animations: {
            cell.contentView.alpha = 1
        })
    }
}
