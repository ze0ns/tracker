import UIKit

final class TrackCell: UICollectionViewCell {
    
    static let identifier = "TrackCell"
    
    // MARK: - UI Elements
    private let cardContainerView: UIView = {
        let cardContainerView = UIView()
        cardContainerView.backgroundColor = .ypColorSelection5
        cardContainerView.layer.cornerRadius = 16
        cardContainerView.translatesAutoresizingMaskIntoConstraints = false
        return cardContainerView
    }()

    private let trackEmoji: UIImageView = {
        let trackEmoji = UIImageView()
        trackEmoji.image = UIImage(resource: .emoji)
        trackEmoji.translatesAutoresizingMaskIntoConstraints = false
        return trackEmoji
    }()

    private let trackJobs: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let statusLabel = UILabel()
        statusLabel.font = .systemFont(ofSize: 12, weight: .medium)
        statusLabel.textColor = .black
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        return statusLabel
    }()
    

    private lazy var actionButton: UIButton = {
        let actionButton = UIButton(type: .system)
        actionButton.backgroundColor = .ypColorSelection5
        actionButton.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)), for: .normal)
        actionButton.tintColor = .white
        actionButton.layer.cornerRadius = 17
        actionButton.clipsToBounds = true
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        return actionButton
    }()
    
    // MARK: - Logic Properties
    private var isCompleted: Bool = false
    private var completedDaysCount: Int = 0
    private var trackerID: String?
    var selectedDate: Date?

    var onButtonTapped: (() -> Void)?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        contentView.addSubview(cardContainerView)
        cardContainerView.addSubview(trackJobs)
        cardContainerView.addSubview(trackEmoji)
        
        contentView.addSubview(statusLabel)
        contentView.addSubview(actionButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Контейнер
            cardContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -60),
            
            // Задание трекера
            trackJobs.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -12),
            trackJobs.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor, constant: -12),
            trackJobs.leadingAnchor.constraint(greaterThanOrEqualTo: trackEmoji.trailingAnchor, constant: 8),
            
            // Картинка эмоджи
            trackEmoji.topAnchor.constraint(equalTo: cardContainerView.topAnchor, constant: 12),
            trackEmoji.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 12),
            trackEmoji.widthAnchor.constraint(equalToConstant: 24),
            trackEmoji.heightAnchor.constraint(equalToConstant: 24),
            
            // Статус (счетчик дней)
            statusLabel.topAnchor.constraint(equalTo: cardContainerView.bottomAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            statusLabel.centerYAnchor.constraint(equalTo: actionButton.centerYAnchor),
            
            // Кнопка
            actionButton.topAnchor.constraint(equalTo: cardContainerView.bottomAnchor, constant: 8),
            actionButton.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -12),
            actionButton.widthAnchor.constraint(equalToConstant: 34),
            actionButton.heightAnchor.constraint(equalToConstant: 34),
        ])
    }
    
    // MARK: - Actions
    
    @objc private func buttonTapped() {
        isCompleted.toggle()
        updateButtonAppearance()
        
        if isCompleted {
            completedDaysCount += 1
            updateStatusLabel()
            if let date = selectedDate {
                saveRecord(date: date)
            }
        } else {
            if completedDaysCount > 0 {
                completedDaysCount -= 1
                updateStatusLabel()
            }
        }
        
        onButtonTapped?()
    }
    
    private func updateButtonAppearance() {
        let imageName = isCompleted ?  "plus" : "checkmark"
        actionButton.setImage(UIImage(systemName: imageName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)), for: .normal)
    }
    
    private func updateStatusLabel() {
        let suffix: String
        let lastDigit = completedDaysCount % 10
        let lastTwoDigits = completedDaysCount % 100
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
            suffix = "дней"
        } else if lastDigit == 1 {
            suffix = "день"
        } else if lastDigit >= 2 && lastDigit <= 4 {
            suffix = "дня"
        } else {
            suffix = "дней"
        }
        
        statusLabel.text = "\(completedDaysCount) \(suffix)"
    }
    
    private func saveRecord(date: Date) {
        guard let id = trackerID else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let dateString = formatter.string(from: date)
        
        let record = TrackerRecord(trackID: id, trackDate: dateString)
        print("Запись сохранена: \(record)")
    }
    
    // MARK: - Configuration
    
    func configure(id: String, jobsName: String, daysCount: Int, isDone: Bool, date: Date?) {
        self.trackerID = id
        self.trackJobs.text = jobsName
        self.completedDaysCount = daysCount
        self.isCompleted = isDone
        self.selectedDate = date
        
        // --- ЛОГИКА ПРОВЕРКИ ДАТЫ ---
        if let selectedDate = selectedDate {
            let calendar = Calendar.current
            
            // Сравниваем только год, месяц и день
            let comparison = calendar.compare(selectedDate, to: Date(), toGranularity: .day)
            
            // .orderedDescending означает, что выбранная дата позже текущей (будущее)
            if comparison == .orderedDescending {
                actionButton.isUserInteractionEnabled = false
                actionButton.alpha = 0.5 // Визуально делаем кнопку неактивной (полупрозрачной)
            } else {
                // Дата сегодня или в прошлом - кнопка активна
                actionButton.isUserInteractionEnabled = true
                actionButton.alpha = 1.0
            }
        } else {
            // Если дата не передана, по умолчанию активна
            actionButton.isUserInteractionEnabled = true
            actionButton.alpha = 1.0
        }
        // -----------------------------
        
        updateStatusLabel()
        updateButtonAppearance()
    }
}
