//
//  Tracker.swift
//  Project: Tracker
//  Created by Oschepkov Aleksandr on 09.03.2026.
//

import UIKit
struct Tracker {
    let id: UUID
    let name: String
    let color: String
    let emodji: String
    let schedule: [Weekday]
    var isPinned: Bool
    
    // Добавляем явный инициализатор со значением по умолчанию для id
    init(id: UUID = UUID(), name: String, color: String, emodji: String, schedule: [Weekday], isPinned: Bool) {
        self.id = id
        self.name = name
        self.color = color
        self.emodji = emodji
        self.schedule = schedule
        self.isPinned = isPinned
    }
}
