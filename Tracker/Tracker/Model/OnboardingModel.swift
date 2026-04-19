//
//  OnboardingModel.swift
//  Project: Tracker
//  Created by Oschepkov Aleksandr on 09.03.2026.
//

import UIKit

struct OnboardingPage {
    let title: String
    let imageName: String
    let backgroundColor: UIColor
    
    init(title: String, imageName: String, backgroundColor: UIColor = .white) {
        self.title = title
        self.imageName = imageName
        self.backgroundColor = backgroundColor
    }
}
