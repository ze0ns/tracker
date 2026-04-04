//
//  ConvetColorToString.swift
//  Tracker
//
//  Created by Oschepkov Aleksandr on 31.03.2026.
//

import UIKit

extension UIColor {
    // Удобный инициализатор для создания цвета из Hex-строки
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        // Проверяем, что строка корректна и состоит из 6 символов (RRGGBB)
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        guard hexSanitized.count == 6 else {
            return nil
        }
        
        // Извлекаем компоненты цвета
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

