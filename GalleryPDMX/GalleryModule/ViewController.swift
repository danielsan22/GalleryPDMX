//
//  ViewController.swift
//  GalleryPDMX
//
//  Created by Daniel Sanchez on 03/07/23.
//

import Combine
import UIKit

class ViewController: UIViewController {
    
    private let presenter: GalleryPresenting
    private let animationDuration: Double = 0.2
    private let delayBase: Double = 0.05
    private var subscriptions = Set<AnyCancellable>()
    
    private lazy var emptyView: UIView = EmptyGalleryView()
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout())
        cv.register(GalleryCell.self, forCellWithReuseIdentifier: GalleryCell.reuseIdentifier)
        cv.dataSource = self
        cv.delegate = self
        cv.backgroundColor = .clear
        return cv
    }()
    
    init(presenter: GalleryPresenting) {
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
        presenter
            .images
            .sink { [weak self] data in
                self?.collectionView.reloadData()
            }.store(in: &subscriptions)
        
        presenter
            .shareSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.share(image: image)
            }.store(in: &subscriptions)
        presenter
            .showEmptyScreen
            .sink { [weak self] value in
                self?.updateEmptyScreen(value)
            }.store(in: &subscriptions)
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 1.00)
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
    
    private func share(image: UIImage) {
        let imageToShare = [ image ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.postToFacebook]
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    private func updateEmptyScreen(_ show: Bool) {
        if show && emptyView.superview == nil {
            view.addSubview(emptyView)
            emptyView.fillSuperview()
        } else if !show && emptyView.superview != nil {
            emptyView.removeFromSuperview()
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.images.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryCell.reuseIdentifier, for: indexPath) as! GalleryCell
        let item = presenter.images.value[indexPath.row]
        cell.label.text = item.description ?? item.altDescription ?? "No Description"
        cell.imageView.image = item.image
        cell.contentView.alpha = 0.0
        cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        presenter.loadNextPage(for: indexPath)
        
        if presenter.needAnimation(for: indexPath) {
            let delay = sqrt(Double(indexPath.row % 20)) * delayBase
            UIView.animate(withDuration: animationDuration, delay: delay, options: .curveEaseOut, animations: {
                cell.contentView.alpha = 1
                cell.transform = .identity
            })
        } else {
            cell.contentView.alpha = 1.0
            cell.transform = .identity
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.cellSelected(at: indexPath)
    }
}
