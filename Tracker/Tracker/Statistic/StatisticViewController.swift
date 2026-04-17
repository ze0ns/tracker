//
//  ViewController.swift
//  Tracker
//
//  Created by Oschepkov Aleksandr on 07.03.2026.
//
//
//  StatisticViewController.swift
//  Tracker
//
//  Created by Oschepkov Aleksandr on 14.04.2026.
//

import UIKit

// MARK: - Statistic Cell Model
struct StatisticItem {
    let title: String
    let value: Int
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

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        updateStatistics()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Обновляем данные при появлении экрана
        trackerStore.loadData()
        updateStatistics()
    }

    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .backgroundColorDay
        view.addSubview(titleLabel)
        view.addSubview(tableView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func updateStatistics() {
        // 1. Трекеров завершено (общее количество записей)
        let completedCount = trackerStore.completedTrackers.count
        
        // 2. Идеальные дни (дни, когда выполнены все запланированные трекеры)
        // Логика: считаем уникальные дни, берем трекеры на этот день, сравниваем с выполненными
        var perfectDays = 0
        let calendar = Calendar.current
        
        // Группируем выполненные трекеры по датам
        let completedDates = Set(trackerStore.completedTrackers.map { $0.trackDate })
        
        for date in completedDates {
            // Определяем день недели для даты
            let weekday = calendar.component(.weekday, from: DateFormatter().date(from: date) ?? Date())
            let requiredIndex = (weekday + 5) % 7 + 1
            guard let day = Weekday(rawValue: requiredIndex) else { continue }
            
            // Все трекеры, которые должны были быть в этот день
            var scheduledCount = 0
            var doneCount = 0
            
            for category in trackerStore.categories {
                for tracker in category.arrayTracker {
                    if tracker.schedule.contains(day) {
                        scheduledCount += 1
                        // Проверяем, выполнен ли он
                        if trackerStore.completedTrackers.contains(where: { $0.trackID == tracker.id.uuidString && $0.trackDate == date }) {
                            doneCount += 1
                        }
                    }
                }
            }
            
            // Если в этот день что-то было запланировано и всё выполнено
            if scheduledCount > 0 && scheduledCount == doneCount {
                perfectDays += 1
            }
        }
        
        // Формируем массив данных
        // Примечание: "Лучший период" и "Среднее значение" требуют дополнительной логики, оставим заглушки или простую логику
        items = [
            StatisticItem(title: "Лучший период", value: 0), // Требует сложной логики хранения истории
            StatisticItem(title: "Идеальные дни", value: perfectDays),
            StatisticItem(title: "Трекеров завершено", value: completedCount),
            StatisticItem(title: "Среднее значение", value: 0) // Можно вычислить как completedCount / кол-во дней
        ]
        
        tableView.reloadData()
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

// MARK: - StatisticCell
final class StatisticCell: UITableViewCell {
    
    static let identifier = "StatisticCell"
    
    // MARK: - UI Elements
    private let containerCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypBackgroundDay
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerCardView)
        containerCardView.addSubview(valueLabel)
        containerCardView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            containerCardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            valueLabel.topAnchor.constraint(equalTo: containerCardView.topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: containerCardView.leadingAnchor, constant: 12),
            
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 1),
            titleLabel.leadingAnchor.constraint(equalTo: containerCardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerCardView.trailingAnchor, constant: -12)
        ])
    }
    
    func configure(title: String, value: Int) {
        titleLabel.text = title
        valueLabel.text = "\(value)"
    }
}
