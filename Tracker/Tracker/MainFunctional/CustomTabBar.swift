//  CreateTrackerViewController.swift
//  Project: Tracker
//  Created by Oschepkov Aleksandr on 09.03.2026.
//

import UIKit

final class CustomTabBar: UIView {
    // MARK: - Public Properties
    var onItemSelected: ((Int) -> Void)?
    var selectedIndex: Int = 0 {
        didSet { updateSelection() }
    }
    var height: CGFloat = 83 {
        didSet { setNeedsLayout() }
    }
    
    private var items: [UITabBarItem] = []
    private var buttons: [UIButton] = []
    
    init(items: [UITabBarItem]) {
        self.items = items
        super.init(frame: .zero)
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        for (index, item) in items.enumerated() {
            var config = UIButton.Configuration.plain()
            config.title = item.title
            config.image = item.image?.withRenderingMode(.alwaysTemplate)
            config.imagePlacement = .top
            config.imagePadding = 4.0
            
            
            var bgConfig = UIBackgroundConfiguration.clear()
            
            
            bgConfig.backgroundColorTransformer = UIConfigurationColorTransformer { [weak self] color in
                return .clear
            }
            
            config.background = bgConfig
            
            
            config.baseForegroundColor = .secondaryLabel
            
            
            let button = UIButton(configuration: config)
            button.tag = index
            
            
            button.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = .systemFont(ofSize: 10, weight: .medium)
                return outgoing
            }
            
            button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            
            buttons.append(button)
            addSubview(button)
        }
        
        updateSelection()
    }
    
    // MARK: - Actions
    @objc private func buttonTapped(_ sender: UIButton) {
        selectedIndex = sender.tag
        onItemSelected?(selectedIndex)
    }
    
    private func updateSelection() {
        for (index, button) in buttons.enumerated() {
            button.isSelected = (index == selectedIndex)
            
            let color: UIColor = index == selectedIndex ? .systemBlue : .secondaryLabel
            
            var config = button.configuration
            config?.baseForegroundColor = color
            if !button.isHighlighted {
                config?.background.backgroundColor = .clear
            }
            
            button.configuration = config
        }
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let count = buttons.count
        let width = bounds.width / CGFloat(count)
        
        for (index, button) in buttons.enumerated() {
            button.frame = CGRect(
                x: width * CGFloat(index),
                y: 0,
                width: width,
                height: height
            )
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
}
