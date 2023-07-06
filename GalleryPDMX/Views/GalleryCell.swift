//
//  GalleryCell.swift
//  GalleryPDMX
//
//  Created by Daniel Sanchez on 03/07/23.
//

import UIKit

class GalleryCell: UICollectionViewCell {
    
    private(set) var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.backgroundColor = .black.withAlphaComponent(0.4)
        return label
    }()
    private(set) var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        label.textAlignment = .center
        contentView.addSubview(imageView)
        imageView.fillSuperview()
        imageView.addSubview(label)
        
        label.layout {
            $0.leadingAnchor.constraint(equalTo: imageView.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: imageView.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: imageView.bottomAnchor)
            $0.heightAnchor.constraint(lessThanOrEqualToConstant: 72)
        }
    }
}

extension UICollectionViewCell {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}
