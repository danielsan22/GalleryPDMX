//
//  EmptyGalleryView.swift
//  GalleryPDMX
//
//  Created by Daniel Sanchez on 04/07/23.
//

import UIKit

class EmptyGalleryView: UIView {
    
    private let iconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "photo.fill.on.rectangle.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .lightText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.text = "We currently do not have any images to show"
        return label
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
        addSubview(iconView)
        addSubview(messageLabel)
        
        layout {
            iconView.centerXAnchor.constraint(equalTo: $0.centerXAnchor)
            iconView.centerYAnchor.constraint(equalTo: $0.centerYAnchor)
            iconView.heightAnchor.constraint(equalToConstant: 72)
            iconView.widthAnchor.constraint(equalToConstant: 72)
            
            messageLabel.centerXAnchor.constraint(equalTo: $0.centerXAnchor)
            messageLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 16)
            messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: $0.leadingAnchor, constant: 16)
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: $0.trailingAnchor, constant: -16)
        }
    }
}
