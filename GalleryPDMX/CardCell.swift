//
//  CardCell.swift
//  GalleryPDMX
//
//  Created by Daniel Sanchez on 03/07/23.
//

import UIKit

class CardCell: UICollectionViewCell {
    
    let label = UILabel()
    let imageView = UIImageView()
    
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
        label.text = "Label"
        label.textAlignment = .center
        bv.addSubview(label)
        label.fillSuperview()
        contentView.addSubview(bv)
        bv.fillSuperview()
    }
}
