//
//  TrackCell.swift
//  Tracker
//
//  Created by Oschepkov Aleksandr on 09.03.2026.
//
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
    
    private let emojiContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhiteOpt30
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // ИЗМЕНЕНО: Заменили UIImageView на UILabel для вывода текста эмодзи
    private let trackEmojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12) // Размер шрифта для эмодзи
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let trackJobs: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypWhiteDay
        label.numberOfLines = 2 // Разрешаем 2 строки для длинных названий
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
        actionButton.backgroundColor = .ypWhiteDay
        actionButton.setImage(UIImage(named: "plus"), for: .normal)
        actionButton.tintColor = .ypColorSelection5
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
    
    // Храним цвет, чтобы обновлять tint кнопки
    private var currentColor: UIColor = .ypColorSelection5

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
        cardContainerView.addSubview(emojiContainer)
        
        // ИЗМЕНЕНО: Добавляем лейбл вместо imageView
        emojiContainer.addSubview(trackEmojiLabel)
        
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
            trackJobs.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 12),
            
            // Контейнер для эмоджи
            emojiContainer.topAnchor.constraint(equalTo: cardContainerView.topAnchor, constant: 12),
            emojiContainer.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 12),
            emojiContainer.widthAnchor.constraint(equalToConstant: 24),
            emojiContainer.heightAnchor.constraint(equalToConstant: 24),
            
            // ИЗМЕНЕНО: Констрейнты для лейбла эмодзи
            trackEmojiLabel.centerXAnchor.constraint(equalTo: emojiContainer.centerXAnchor),
            trackEmojiLabel.centerYAnchor.constraint(equalTo: emojiContainer.centerYAnchor),
            
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
        onButtonTapped?()
    }
    
    private func updateButtonAppearance() {
        let imageName = isCompleted ? "checkmark" : "plus"
        actionButton.setImage(UIImage(named: imageName), for: .normal)
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
    
    // MARK: - Configuration
    
    func configure(id: String, jobsName: String, daysCount: Int, isDone: Bool, date: Date, emoji: String, color: UIColor) {
        self.trackerID = id
        self.trackJobs.text = jobsName
        self.completedDaysCount = daysCount
        self.isCompleted = isDone
        self.selectedDate = date
        
        // ИЗМЕНЕНО: Устанавливаем текст эмодзи
        self.trackEmojiLabel.text = emoji
        
        // Устанавливаем цвет карточки
        self.cardContainerView.backgroundColor = color
        
        // Запоминаем цвет для кнопки
        self.currentColor = color
        
        // Обновляем цвет иконки кнопки
        actionButton.tintColor = color
        
        // --- ЛОГИКА ПРОВЕРКИ ДАТЫ ---
        if let selectedDate = selectedDate {
            let calendar = Calendar.current
            
            let comparison = calendar.compare(selectedDate, to: Date(), toGranularity: .day)
            
            if comparison == .orderedDescending {
                actionButton.isUserInteractionEnabled = false
                actionButton.alpha = 0.5
            } else {
                actionButton.isUserInteractionEnabled = true
                actionButton.alpha = 1.0
            }
        } else {
            actionButton.isUserInteractionEnabled = true
            actionButton.alpha = 1.0
        }
        // -----------------------------
        
        updateStatusLabel()
        updateButtonAppearance()
    }
}
