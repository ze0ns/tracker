//
//  SelectCategoryViewController.swift
//  Tracker
//
//  Created by Oschepkov Aleksandr on 28.03.2026.
//

import UIKit

// Протокол для возврата выбранной категории на предыдущий экран
protocol SelectCategoryViewControllerDelegate: AnyObject {
    func didSelectCategory(_ title: String)
}

final class SelectCategoryViewController: UIViewController {
    
    // MARK: - Properties
    private var viewModel: SelectCategoryViewModel!
    weak var delegate: SelectCategoryViewControllerDelegate?
    
    // Замыкание как альтернатива делегату (удобно при present)
    var onCategorySelected: ((String) -> Void)?
    
    // MARK: - UI Elements
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        tableView.backgroundColor = .white
        tableView.layer.cornerRadius = 16
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    
    init(store: TrackerStore, selectedTitle: String?) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = SelectCategoryViewModel(store: store, selectedCategoryTitle: selectedTitle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        bindViewModel()
        viewModel.fetchCategories()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(addButton)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100), // Минимальная высота
            
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func bindViewModel() {
        viewModel.delegate = self
    }
    
    // MARK: - Actions
    
    @objc private func addButtonTapped() {
        // Переход к экрану создания категории (который мы написали ранее)
        // Нам нужно передать store, чтобы новый экран мог сохранить данные
        let createCategoryVC = CategoryViewController(store: viewModel.trackerStore)
        
        // Обновляем список после закрытия экрана создания
        createCategoryVC.dismissCallback = { [weak self] in
            self?.viewModel.fetchCategories()
        }
        
        present(createCategoryVC, animated: true)
    }
}

// MARK: - UITableViewDataSource & Delegate
extension SelectCategoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = viewModel.category(at: indexPath.row)
        
        var content = cell.defaultContentConfiguration()
        content.text = category.nameTrackerCategory
        cell.contentConfiguration = content
        
        // Отображаем галочку, если это выбранная категория
        if category.nameTrackerCategory == viewModel.selectedCategoryTitle {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        cell.backgroundColor = .ypBackgroundDay // Или ваш цвет фона ячеек
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.selectCategory(at: indexPath.row)
    }
}

// MARK: - SelectCategoryViewModelDelegate
extension SelectCategoryViewController: SelectCategoryViewModelDelegate {
    
    func didUpdateCategories() {
        tableView.reloadData()
    }
    
    func didSelectCategory(_ title: String) {
        // Сообщаем предыдущему экрану о выборе
        delegate?.didSelectCategory(title)
        onCategorySelected?(title)
        
        // Закрываем экран выбора
        dismiss(animated: true)
    }
}
