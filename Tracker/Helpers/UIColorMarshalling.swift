//
//  UIColorMarshalling.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 21.12.2023.
//

import UIKit

class  UIColorMarshalling {
    func hexString(from color: UIColor) -> String {
        let components = color.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0
        return String.init(
            format: "%02lX%02lX%02lX",
            lround(r * 255),
            lround(g * 255),
            lround(b * 255)
        )
    }
    
    func color(from hex: String) -> UIColor {
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        return UIColor(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
