//
//  NewHabitViewController.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 09.03.2026.
//

import UIKit

protocol NewHabitViewControllerDelegate: AnyObject {
    func didCreateHabit(_ habit: Tracker, category: String)
}

final class NewHabitViewController: UIViewController {

    // MARK: - Delegate
    weak var delegate: NewHabitViewControllerDelegate?
    var onTrackerCreated: ((Tracker, String) -> Void)?
    
    // MARK: - Private Properties
    private let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    private let colors: [UIColor] = [.ypColorSelection1, .ypColorSelection2, .ypColorSelection3, .ypColorSelection4, .ypColorSelection5, .ypColorSelection6,
                                     .ypColorSelection7, .ypColorSelection8, .ypColorSelection9, .ypColorSelection10, .ypColorSelection11, .ypColorSelection12,
                                     .ypColorSelection13, .ypColorSelection14, .ypColorSelection15, .ypColorSelection16, .ypColorSelection17, .ypColorSelection18
    ]
    
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    
    private var selectedCategory: String = "Важное"
    private var selectedSchedule: [Weekday] = []
    private var selectedDaysCount: Int = 0
    
    
    // MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = .ypBackgroundDay
        textField.layer.cornerRadius = 16
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.text = "Emoji"
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 52, height: 52)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let colorLabel: UILabel = {
        let label = UILabel()
        label.text = "Цвет"
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 52, height: 52)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupTableView()
        setupCollections()
        setupActions()
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(nameTextField)
        contentView.addSubview(tableView)
        contentView.addSubview(emojiLabel)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorLabel)
        contentView.addSubview(colorCollectionView)
        
        view.addSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(createButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -20),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: contentView.topAnchor),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            emojiLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 24),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 24),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 204),
            colorCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    private func setupCollections() {
        // Настройка Emoji Collection
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        emojiCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "EmojiCell")
        
        // Настройка Color Collection
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ColorCell")
    }
    
    private func setupTableView() {
        tableView.register(SettingCell.self, forCellReuseIdentifier: "SettingCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        // Добавляем жест для скрытия клавиатуры по тапу
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func updateCreateButtonState() {
        let isNameFilled = nameTextField.text?.isEmpty == false
        let isScheduleSelected = !selectedSchedule.isEmpty
        
        let isFormValid = isNameFilled && isScheduleSelected
        
        createButton.isEnabled = isFormValid
        createButton.backgroundColor = isFormValid ? .black : .ypGray
    }
    
    // MARK: - Actions
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty else { return }
        let category = selectedCategory
        
        // Получаем выбранные значения или значения по умолчанию
        let emoji = selectedEmoji ?? "🙂"
        let color = selectedColor ?? .ypColorSelection1
        
        // ВАЖНО: Проверьте инициализатор структуры Tracker.
        // Если параметр 'color' принимает String, вам нужно преобразовать UIColor в строку.
        // Если параметр 'color' принимает UIColor, передавайте 'color' напрямую.
        
        // Пример, если нужен String (вам придется добавить логику получения имени цвета, если она есть):
        // let colorName = ...
        
        // Пример, если принимает UIColor:
        let tracker = Tracker(
            name: name,
            color: "ColorSelected", // Здесь должна быть ваша логика сохранения цвета
            emodji: emoji,
            schedule: selectedSchedule
        )
        
        delegate?.didCreateHabit(tracker, category: category)
        onTrackerCreated?(tracker, category)
        presentingViewController?.dismiss(animated: true)
    }
    
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    private func showCategoryScreen() {
        let categoryVC = CategoryViewController()
        categoryVC.delegate = self
        categoryVC.modalPresentationStyle = .pageSheet
        present(categoryVC, animated: true)
        print("CategoryViewController показан")
    }
    
    private func showScheduleScreen() {
        let scheduleVC = ScheduleViewController()
        scheduleVC.delegate = self
        scheduleVC.selectedDays = selectedSchedule
        scheduleVC.modalPresentationStyle = .pageSheet
        present(scheduleVC, animated: true)
        print("ScheduleViewController показан")
    }
}

// MARK: - UITableViewDataSource
extension NewHabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as? SettingCell else {
            return UITableViewCell()
        }
        
        if indexPath.row == 0 {
            cell.configure(title: "Категория", value: selectedCategory)
        } else {
            let scheduleText = selectedSchedule.map { $0.fullName }.joined(separator: ", ")
            cell.configure(title: "Расписание", value: scheduleText)
        }
        
        
        cell.backgroundColor = .ypBackgroundDay
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NewHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            showCategoryScreen()
        } else {
            showScheduleScreen()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - CategoryViewControllerDelegate
extension NewHabitViewController: CategoryViewControllerDelegate {
    func didSelectCategory(_ category: String) {
        selectedCategory = category
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        updateCreateButtonState()
    }
}

// MARK: - ScheduleViewControllerDelegate
extension NewHabitViewController: ScheduleViewControllerDelegate {
    func didSelectSchedule(_ schedule: [Weekday]) {
        selectedSchedule = schedule
        tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        updateCreateButtonState()
    }
}

// MARK: - UITextFieldDelegate
extension NewHabitViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
// MARK: - UICollectionViewDataSource
extension NewHabitViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return emojis.count
        } else {
            return colors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        
        if collectionView == emojiCollectionView {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath)
            
            // Очищаем ячейку перед переиспользованием
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            cell.layer.borderWidth = 0
            cell.backgroundColor = .clear
            
            let label = UILabel()
            label.text = emojis[indexPath.item]
            label.font = .systemFont(ofSize: 32)
            label.textAlignment = .center
            label.frame = cell.contentView.bounds
            cell.contentView.addSubview(label)
            
            // ЛОГИКА ВЫДЕЛЕНИЯ ЭМОДЗИ
            if emojis[indexPath.item] == selectedEmoji {
                cell.backgroundColor = .ypBackgroundDay // Серый фон при выборе
                cell.layer.cornerRadius = 16
            }
            
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath)
            
            let color = colors[indexPath.item]
            cell.backgroundColor = color
            cell.layer.cornerRadius = 8
            cell.layer.masksToBounds = true
            
            // ЛОГИКА ВЫДЕЛЕНИЯ ЦВЕТА
            if color == selectedColor {
                cell.layer.borderWidth = 3
                cell.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor // Белая полупрозрачная рамка
            } else {
                cell.layer.borderWidth = 0
            }
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension NewHabitViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if collectionView == emojiCollectionView {
            selectedEmoji = emojis[indexPath.item]
            print("Выбран эмодзи: \(selectedEmoji ?? "")")
        } else {
            selectedColor = colors[indexPath.item]
            print("Выбран цвет: \(selectedColor ?? .black)")
        }
        
        // Обновляем коллекцию, чтобы показать/скрыть выделение (если нужно)
        collectionView.reloadData()
    }
}
// MARK: - SwiftUI for working canvas
import SwiftUI
struct CreateHabitPreview: PreviewProvider {
    static var previews: some View {
        VCProvider<NewHabitViewController>.previews
    }
}
