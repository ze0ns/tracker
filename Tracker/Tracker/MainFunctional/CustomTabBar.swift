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
            let button = UIButton(type: .custom)
            button.tag = index
            button.setTitle(item.title, for: .normal)
            
            if let image = item.image {
                button.setImage(
                    image.withRenderingMode(.alwaysTemplate),
                    for: .normal
                )
            }
            button.setTitleColor(.secondaryLabel, for: .normal)
            button.setTitleColor(.label, for: .selected)
            button.tintColor = .secondaryLabel
            
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
            button.tintColor = index == selectedIndex ? .ypWhiteDay : .ypBlackDay
        }
    }
    // MARK: - Public Methods , UI
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
            
            button.imageEdgeInsets = UIEdgeInsets(top: 6, left: 0, bottom: 2, right: 0)
            button.titleEdgeInsets = UIEdgeInsets(
                top: 0,
                left: -button.imageView!.frame.width,
                bottom: -6,
                right: 0
            )
        }
    }
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
}

