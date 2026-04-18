//
//  MainTabBarController.swift
//  temp_ImagesFeed
//
//  Created by Oschepkov Aleksandr on 19.01.2026.
//
import UIKit

final class MainTabBarController: UITabBarController {
    
    private let customTabBarHeight: CGFloat = 84
    private var customTabBar: CustomTabBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomTabBar()
        makeUI()
    }
    
    private func setupCustomTabBar() {
        tabBar.isHidden = true
        let tabItems = createTabItems()
        let tabBar = CustomTabBar(items: tabItems)
        tabBar.backgroundColor = .backgroundColorDay
        tabBar.height = customTabBarHeight
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        tabBar.onItemSelected = { [weak self] index in
            self?.selectedIndex = index
        }
        
        view.addSubview(tabBar)
        
        self.customTabBar = tabBar
        
        // MARK: - Добавление границы (линии сверху)
        let topBorderView = UIView()
        topBorderView.backgroundColor = .lineColor
        topBorderView.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(topBorderView)
        
        NSLayoutConstraint.activate([
            
            //          tabBar.topAnchor.constraint(equalTo: topBorderView.topAnchor),
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabBar.heightAnchor.constraint(equalToConstant: customTabBarHeight),
            
            topBorderView.topAnchor.constraint(equalTo: tabBar.topAnchor),
            topBorderView.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            topBorderView.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            topBorderView.heightAnchor.constraint(equalToConstant: 0.5),
        ])
    }
    
    private func createTabItems() -> [UITabBarItem] {
        let items = [
            createTabBarItem(title: NSLocalizedString("Trackers", comment: "Trackers button"), imageResource: .trackers, tag: 0),
            createTabBarItem(title: NSLocalizedString("Statistics", comment: "Statistics button"), imageResource: .statistic, tag: 1)
        ]
        return items.compactMap { $0 }
    }
    
    private func createTabBarItem(title: String,
                                  imageResource: ImageResource,
                                  tag: Int) -> UITabBarItem? {
        let image: UIImage
        do {
            image = try UIImage(resource: imageResource)
        } catch {
            print("⚠️ Не удалось загрузить изображение: \(error)")
            if let fallbackImage = UIImage(systemName: tag == 0 ? "photo.fill" : "person.fill") {
                image = fallbackImage
            } else {
                let size = CGSize(width: 24, height: 24)
                let renderer = UIGraphicsImageRenderer(size: size)
                image = renderer.image { context in
                    UIColor.blue.setFill()
                    context.fill(CGRect(origin: .zero, size: size))
                }
            }
        }
        
        return UITabBarItem(title: title, image: image, tag: tag)
    }
    
    private func makeUI() {
        let firstVC = TrackViewController()
        let secondVC = StatisticViewController()
        viewControllers = [firstVC, secondVC]
    }
}

// MARK: - UITabBarControllerDelegate
extension MainTabBarController: UITabBarControllerDelegate {
    internal func tabBarController(_ tabBarController: UITabBarController,
                                   didSelect viewController: UIViewController) {
        customTabBar?.selectedIndex = tabBarController.selectedIndex
    }
}

// MARK: - UIView Lifecycle
extension MainTabBarController {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTabBarSafeArea()
    }
    
    private func updateTabBarSafeArea() {
        guard let tabBar = customTabBar else { return }
        if view.safeAreaInsets.bottom > 0 {
            tabBar.height = customTabBarHeight
            // tabBar.height = customTabBarHeight + view.safeAreaInsets.bottom
        }
    }
}

//MARK: SwiftUI - for working canvas
import SwiftUI
struct MainTabBarControllerProvider: PreviewProvider {
    static var previews: some View {
        VCProvider<MainTabBarController>.previews
    }
}
