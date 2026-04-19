//
//  StatisticViewController.swift
//  Tracker
//  Project: Tracker
//  Created by Oschepkov Aleksandr on 09.03.2026.
//

import UIKit

// MARK: - Statistic Cell Model
struct StatisticItem {
    let title: String
    let value: Int
}

extension Notification.Name {
    static let trackerRecordsDidChange = Notification.Name("trackerRecordsDidChange")
}

final class StatisticViewController: UIViewController {
    
    // MARK: - Properties
    private let trackerStore = TrackerStore()
    
    private var items: [StatisticItem] = []
    
    // MARK: - UI Elements
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Статистика"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .textColorDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(StatisticCell.self, forCellReuseIdentifier: StatisticCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlackDay
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private lazy var placeholderImage: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "noActivity"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isHidden = true
        return iv
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataChange),
            name: .trackerRecordsDidChange,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackerStore.loadData()
        updateStatistics()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .backgroundColorDay
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(placeholderImage)
        view.addSubview(placeholderLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 380),
            
            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImage.heightAnchor.constraint(equalToConstant: 80),
            placeholderImage.widthAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc private func handleChange() {
        trackerStore.loadData()
        updateStatistics()
    }
    
    private func updateStatistics() {
        let completedCount = trackerStore.completedTrackers.count
        let perfectDays = calculatePerfectDays()
        
        // --- НОВАя логика ---
        let bestPeriod = calculateBestPeriod()
        let averageValue = calculateAverageValue(completedCount: completedCount)
        
        items = [
            StatisticItem(title: "Лучший период", value: bestPeriod),
            StatisticItem(title: "Идеальные дни", value: perfectDays),
            StatisticItem(title: "Трекеров завершено", value: completedCount),
            StatisticItem(title: "Среднее значение", value: averageValue)
        ]
        
        tableView.reloadData()
        
        let hasData = completedCount > 0
        tableView.isHidden = !hasData
        placeholderImage.isHidden = hasData
        placeholderLabel.isHidden = hasData
    }
    
    // MARK: - Statistics Logic
    
    private func calculatePerfectDays() -> Int {
        var perfectDaysCount = 0
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        let completedDates = Set(trackerStore.completedTrackers.map { $0.trackDate })
        
        for dateString in completedDates {
            guard let date = dateFormatter.date(from: dateString) else { continue }
            let weekdayIndex = calendar.component(.weekday, from: date)
            let requiredWeekdayRaw = (weekdayIndex + 5) % 7 + 1
            guard let requiredDay = Weekday(rawValue: requiredWeekdayRaw) else { continue }
            
            var plannedCount = 0
            var doneCount = 0
            
            for category in trackerStore.categories {
                for tracker in category.arrayTracker {
                    if tracker.schedule.contains(requiredDay) {
                        plannedCount += 1
                        let isDone = trackerStore.completedTrackers.contains { record in
                            record.trackID == tracker.id.uuidString && record.trackDate == dateString
                        }
                        if isDone { doneCount += 1 }
                    }
                }
            }
            
            if plannedCount > 0 && plannedCount == doneCount {
                perfectDaysCount += 1
            }
        }
        return perfectDaysCount
    }
    
    // Подсчет лучшего периода (максимальная серия дней подряд)
    private func calculateBestPeriod() -> Int {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        // 1. Собираем все даты, в которые были выполнения, в объекты Date и сортируем
        let completedDates = trackerStore.completedTrackers.compactMap { dateFormatter.date(from: $0.trackDate) }.sorted()
        
        guard !completedDates.isEmpty else { return 0 }
        
        var maxStreak = 1
        var currentStreak = 1
        
        // 2. Проходим по отсортированным датам
        for i in 1..<completedDates.count {
            let previousDate = completedDates[i-1]
            let currentDate = completedDates[i]
            
            // Если разница между датами ровно 1 день, увеличиваем серию
            if calendar.isDate(currentDate, inSameDayAs: previousDate) {
                // Если это тот же день (было несколько выполнений), просто пропускаем
                continue
            } else if calendar.isDate(currentDate, equalTo: previousDate, toGranularity: .day) &&
                      calendar.dateComponents([.day], from: previousDate, to: currentDate).day == 1 {
                // Если следующий день
                currentStreak += 1
            } else {
                // Если пропуск больше дня, сбрасываем серию
                currentStreak = 1
            }
            
            // Обновляем максимум
            if currentStreak > maxStreak {
                maxStreak = currentStreak
            }
        }
        
        // Если была всего одна запись, серия = 1
        return maxStreak
    }
    
    // Подсчет среднего значения (выполнено / количество активных дней)
    private func calculateAverageValue(completedCount: Int) -> Int {
        guard completedCount > 0 else { return 0 }
        
        // Считаем количество уникальных дней, в которые что-то выполняли
        let uniqueDays = Set(trackerStore.completedTrackers.map { $0.trackDate }).count
        
        guard uniqueDays > 0 else { return 0 }
        
        // Возвращаем среднее, округленное до целого
        return completedCount / uniqueDays
    }
    
    @objc private func handleDataChange() {
        updateStatistics()
    }
}

// MARK: - UITableViewDataSource & Delegate
extension StatisticViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StatisticCell.identifier, for: indexPath) as? StatisticCell else {
            return UITableViewCell()
        }
        
        let item = items[indexPath.row]
        cell.configure(title: item.title, value: item.value)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

// MARK: - GradientBorderView
final class GradientBorderView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    private let shapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        layer.addSublayer(gradientLayer)
        gradientLayer.mask = shapeLayer
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        updateGradientColors()
    }
    
    private func updateGradientColors() {
        let startColor = UIColor.ypGradientRed
        let middleColor = UIColor.ypGradientGreen
        let endColor = UIColor.ypGradientBlue
        
        gradientLayer.colors = [startColor.cgColor, middleColor.cgColor, endColor.cgColor]
        gradientLayer.locations = [0.0, 0.5, 1.0]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientColors()
        gradientLayer.frame = bounds
        
        let lineWidth: CGFloat = 1.0
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: 16)
        
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = lineWidth
    }
}

// MARK: - StatisticCell
final class StatisticCell: UITableViewCell {
    
    static let identifier = "StatisticCell"
    
    private let containerCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypBackgroundDay
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let borderView = GradientBorderView()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlackDay
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerCardView)
        containerCardView.addSubview(valueLabel)
        containerCardView.addSubview(titleLabel)
        containerCardView.addSubview(borderView)
        borderView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerCardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            valueLabel.topAnchor.constraint(equalTo: containerCardView.topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: containerCardView.leadingAnchor, constant: 12),
            
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 1),
            titleLabel.leadingAnchor.constraint(equalTo: containerCardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerCardView.trailingAnchor, constant: -12),
            
            borderView.topAnchor.constraint(equalTo: containerCardView.topAnchor),
            borderView.leadingAnchor.constraint(equalTo: containerCardView.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: containerCardView.trailingAnchor),
            borderView.bottomAnchor.constraint(equalTo: containerCardView.bottomAnchor)
        ])
    }
    
    func configure(title: String, value: Int) {
        titleLabel.text = title
        valueLabel.text = "\(value)"
    }
}
