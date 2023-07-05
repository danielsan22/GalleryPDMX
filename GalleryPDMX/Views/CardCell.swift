//
//  CardCell.swift
//  GalleryPDMX
//
//  Created by Daniel Sanchez on 03/07/23.
//

import UIKit

class CardCell: UICollectionViewCell {
    
    private(set) var label: UILabel = {
        let label = UILabel()
        return label
    }()
    private(set) var imageView:UIImageView = {
        let imageView = UIImageView()
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
        let bv = imageView
        label.textAlignment = .center
        bv.addSubview(label)
        label.fillSuperview()
        contentView.addSubview(bv)
        bv.fillSuperview()
    }
}

extension UICollectionViewCell {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}


