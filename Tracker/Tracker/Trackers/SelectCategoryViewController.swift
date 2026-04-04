//
//  SelectCategoryViewController.swift
//  Tracker
//
//  Created by Oschepkov Aleksandr on 28.03.2026.
//

import UIKit

protocol SelectCategoryViewControllerDelegate: AnyObject {
    func didSelectCategory(_ title: String)
}

final class SelectCategoryViewController: UIViewController {
    
    // MARK: - Properties
    private var viewModel: SelectCategoryViewModel!
    weak var delegate: SelectCategoryViewControllerDelegate?
    var onCategorySelected: ((String) -> Void)?
    
    // MARK: - UI Elements
    // 1. Убираем переменную Int и создаем NSLayoutConstraint
    private var tableViewHeightConstraint: NSLayoutConstraint!
    private let cellHeight: CGFloat = 75 // Высота одной ячейки
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
   
    private lazy var dymmy: UIImageView = {
        let dymmy = UIImageView()
        dymmy.contentMode = .scaleAspectFit
        dymmy.image = UIImage(resource: .dymmy)
        dymmy.translatesAutoresizingMaskIntoConstraints = false
        return dymmy
    }()
    
    private lazy var dymmyLabel: UILabel = {
        let dymmyLabel = UILabel()
        dymmyLabel.text = "Привычки и события можно объединить по смыслу"
        dymmyLabel.font = .systemFont(ofSize: 12, weight: .medium)
        dymmyLabel.translatesAutoresizingMaskIntoConstraints = false
        return dymmyLabel
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        tableView.backgroundColor = .ypBackgroundDay // Лучше использовать ваш цвет фона
        tableView.layer.cornerRadius = 16
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = cellHeight
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        tableView.isScrollEnabled = false // Отключаем скролл, так как таблица маленькая
        return tableView
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .ypBlackDay
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
        updateTableViewHeight() // Сразу обновляем высоту
    }
    
    //MARK: - Visible Categories
    private func HideDymmy() {
        // Логика инверсии: если категории ЕСТЬ -> скрываем заглушку, показываем таблицу
        let isEmpty = viewModel.categories.isEmpty
        dymmy.isHidden = !isEmpty
        dymmyLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(addButton)
        view.addSubview(dymmy)
        view.addSubview(dymmyLabel)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupConstraints() {
        // 2. Инициализируем констрейнт и активируем его
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: cellHeight)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableViewHeightConstraint, // Добавляем констрейнт высоты
            
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            
            dymmy.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dymmy.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            dymmy.heightAnchor.constraint(equalToConstant: 80),
            dymmy.widthAnchor.constraint(equalToConstant: 80),
            
            dymmyLabel.topAnchor.constraint(equalTo: dymmy.bottomAnchor, constant: 8),
            dymmyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    private func bindViewModel() {
        viewModel.delegate = self
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        let createCategoryVC = CreateCategoryViewController(store: viewModel.trackerStore)
        createCategoryVC.dismissCallback = { [weak self] in
            self?.viewModel.fetchCategories()
        }
        present(createCategoryVC, animated: true)
    }
    
    // MARK: - Height Update Logic
    private func updateTableViewHeight() {
        let count = viewModel.numberOfRows()
        // 3. Меняем свойство .constant у констрейнта
        tableViewHeightConstraint.constant = CGFloat(count) * cellHeight
        HideDymmy()
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
        
        if category.nameTrackerCategory == viewModel.selectedCategoryTitle {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        cell.backgroundColor = .ypBackgroundDay
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
        // 4. При обновлении данных пересчитываем высоту
        updateTableViewHeight()
        tableView.reloadData()
    }
    
    func didSelectCategory(_ title: String) {
        delegate?.didSelectCategory(title)
        onCategorySelected?(title)
        dismiss(animated: true)
    }
}
