//
//  ImagesListVCProvider.swift
//  Project: Tracker
//  Created by Oschepkov Aleksandr on 09.03.2026.
//

import SwiftUI
//MARK: - SwiftUI
struct VCProvider<VC: UIViewController>: PreviewProvider {
    
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        let tabBarVC = VC()
        
        func makeUIViewController(context: Context) -> VC {
            return tabBarVC
        }
        
        func updateUIViewController(_ uiViewController: VC, context: Context) {
            // Здесь можно обновлять view controller при изменении данных
        }
    }
}
