//
//  UIViewExtensions.swift
//  GalleryPDMX
//
//  Created by Daniel Sanchez on 03/07/23.
//

import Foundation
import UIKit

@resultBuilder
struct ConstraintsBuilder {
    static func buildBlock(_ view: UIView) -> [NSLayoutConstraint] { [] }
}

extension ConstraintsBuilder {
    static func buildBlock(_ constraints: NSLayoutConstraint...) -> [NSLayoutConstraint] {
        constraints
    }
}

extension UIView {
    
    func layout(@ConstraintsBuilder builder: (UIView) -> [NSLayoutConstraint]) {
        self.translatesAutoresizingMaskIntoConstraints = false
        builder(self).forEach{
            $0.isActive = true
        }
    }
}

extension UIView {
    
    func fillSuperview() {
        guard let superview = self.superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: superview.topAnchor),
            self.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            self.leftAnchor.constraint(equalTo: superview.leftAnchor),
            self.rightAnchor.constraint(equalTo: superview.rightAnchor)
        ])
    }
    
    func fillSuperview(margin: CGFloat) {
        guard let superview = self.superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: superview.topAnchor, constant: margin),
            self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -margin),
            self.leftAnchor.constraint(equalTo: superview.leftAnchor, constant: margin),
            self.rightAnchor.constraint(equalTo: superview.rightAnchor, constant: -margin)
        ])
    }
}
