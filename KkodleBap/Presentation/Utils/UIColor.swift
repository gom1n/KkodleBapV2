//
//  UIColor.swift
//  KkodleBap
//
//  Created by gomin on 8/20/25.
//

import UIKit

public extension UIColor{
    // MARK: Blue
    public static let blue_1 = UIColor(r: 243, g: 248, b: 254)
    public static let blue_2 = UIColor(r: 193, g: 241, b: 252)
    public static let blue_3 = UIColor(r: 99, g: 216, b: 242)
    public static let blue_4 = UIColor(r: 165, g: 214, b: 234)
    public static let blue_5 = UIColor(r: 80, g: 147, b: 247)
    // MARK: Gray
    public static let gray_0 = UIColor(r: 255, g: 255, b: 255)
    public static let gray_1 = UIColor(r: 231, g: 231, b: 236)
    public static let gray_2 = UIColor(r: 199, g: 199, b: 203)
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
