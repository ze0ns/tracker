//
//  UIColorExtension.swift
//  Tracker
//
//  Created by Oschepkov Aleksandr on 12.04.2026.
//

import UIKit

// MARK: - Color Conversion Helper
extension UIColor {
    // Метод для сохранения (если его нет в другом месте)
    func toHexString() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
    }
    
    // Метод для чтения из CoreData
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        // Поддержка коротких форм (RGB) и полных (RRGGBB)
        let length = hexSanitized.count
        if length == 6 {
            self.init(
                red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgb & 0x0000FF) / 255.0,
                alpha: 1.0
            )
        } else if length == 3 {
            self.init(
                red: CGFloat((rgb & 0xF00) >> 8) / 15.0,
                green: CGFloat((rgb & 0x0F0) >> 4) / 15.0,
                blue: CGFloat(rgb & 0x00F) / 15.0,
                alpha: 1.0
            )
        } else {
            return nil
        }
    }
}
