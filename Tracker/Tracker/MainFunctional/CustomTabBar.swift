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
            
            // Настройка цветов
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
            // Используем ваши цвета .blue и .gray для примера, или .ypBlackDay/.ypGray
            button.tintColor = index == selectedIndex ? .blue : .gray
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
            
            // 1. Общий отступ содержимого кнопки.
            // Уменьшаем нижний отступ, чтобы "втолкнуть" контент вверх.
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
            
            // 2. Смещение иконки.
            // top: 8 добавляет пространство сверху, поднимая иконку выше относительно центра.
            // bottom: -8 компенсирует это смещение, чтобы не обрезалось.
            button.imageEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
            
            // Если нужно сместить текст (если он есть):
            button.titleEdgeInsets = UIEdgeInsets(
                top: 0,
                left: -(button.imageView?.frame.width ?? 0),
                bottom: -30, // Опускаем текст еще ниже
                right: 0
            )
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
}
