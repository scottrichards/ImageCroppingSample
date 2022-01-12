//
//  UIView+.swift
//  image-cropping-ios
//
//  Created by Scott Richards on 1/6/22.
//  Copyright © 2022 服部穣. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func makeConstraints(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, trailing: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, topMargin: CGFloat, leftMargin: CGFloat, rightMargin: CGFloat, bottomMargin: CGFloat, width: CGFloat?, height: CGFloat?) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: topMargin).isActive = true
        }
        
        if let leading = leading {
            self.leadingAnchor.constraint(equalTo: leading, constant: leftMargin).isActive = true
        }
        
        if let trailing = trailing {
            self.trailingAnchor.constraint(equalTo: trailing, constant: -rightMargin).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -bottomMargin).isActive = true
        }
        
        if let width = width {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func addSubviews(_ views: UIView...) {
        views.forEach{ addSubview($0) }
    }
}
