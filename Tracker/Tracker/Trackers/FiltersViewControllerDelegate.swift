//
//  FiltersViewControllerDelegate.swift
//  Tracker
//
//  Created by Oschepkov Aleksandr on 12.04.2026.
//


import UIKit

protocol FiltersViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filter: TrackerFilter)
}

final class FiltersViewController: UIViewController {
    
    // MARK: - Properties
    private var selectedFilter: TrackerFilter
    private let filters: [(type: TrackerFilter, title: String, visible: Bool)] = [
        (.all, "Все трекеры", false),
        (.today, "Трекеры на сегодня", false),
        (.completed, "Завершенные", true),
        (.uncompleted, "Незавершенные", true)
    ]
    
    weak var delegate: FiltersViewControllerDelegate?
    
    // MARK: - UI Elements
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Фильтры"
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.rowHeight = 75
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Init
    init(selectedFilter: TrackerFilter) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        setupConstraints()
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .ypWhiteDay
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        
    }
    private func setupTableView(){
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant:240)
        ])
    }
}

// MARK: - UITableViewDataSource
extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        let filterItem = filters[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = filterItem.title
        content.textProperties.font = .systemFont(ofSize: 17)
        content.textProperties.color = .ypBlackDay
        
        cell.contentConfiguration = content
        cell.backgroundColor = .ypBackgroundDay
        cell.selectionStyle = .none
        
        
        if (filterItem.type == selectedFilter) && filterItem.visible {
            cell.accessoryType = .checkmark
            cell.tintColor = .ypBlue
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filterItem = filters[indexPath.row]
        selectedFilter = filterItem.type
        delegate?.didSelectFilter(filterItem.type)
        dismiss(animated: true)
    }
}
