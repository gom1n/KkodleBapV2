//
//  UIColor.swift
//  KkodleBap
//
//  Created by gomin on 8/20/25.
//

import UIKit

public extension UIColor{
    // MARK: Blue
    public static let light_blue = UIColor(r: 193, g: 241, b: 252)
}

extension UIColor {
    convenience init(r: Int, g: Int, b: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: a
        )
    }
}
