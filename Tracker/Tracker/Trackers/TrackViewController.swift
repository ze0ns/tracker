//
//  TrackViewController.swift
//
//
//  Created by Oschepkov Aleksandr on 09.03.2026.
//

import UIKit

protocol TrackViewControllerDelegate: AnyObject {
    func didTrackers(_ trackers: [Tracker])
}

// MARK: - Filter Enum
enum TrackerFilter {
    case all
    case today
    case completed
    case uncompleted
}

class TrackViewController: UIViewController, NewHabitViewControllerDelegate, FiltersViewControllerDelegate {
    
    // MARK: - Properties
    private let trackerStore = TrackerStore()
    private var searchText: String = ""
    private var currentFilter: TrackerFilter = .all
    
    // MARK: - UI Elements
    
    private lazy var addTrack: UIButton = {
        let addTrack = UIButton()
        addTrack.setImage(UIImage(resource: .addTracker), for: .normal)
        addTrack.contentMode = .scaleAspectFit
        addTrack.accessibilityIdentifier = "addTracker"
        addTrack.addTarget(self, action: #selector(tapAddTrack), for: .touchUpInside)
        addTrack.translatesAutoresizingMaskIntoConstraints = false
        return addTrack
    }()
    
    private lazy var nameFunction: UILabel = {
        let nameFunction = UILabel()
        nameFunction.text = "Трекеры"
        nameFunction.font = .systemFont(ofSize: 34, weight: .bold)
        nameFunction.translatesAutoresizingMaskIntoConstraints = false
        return nameFunction
    }()
    
    // MARK: - Filter Button
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Фильтры", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(.ypWhiteDay, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Search Container
    private lazy var searchContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGreyOp12
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Поиск"
        textField.backgroundColor = .clear
        
        let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        searchIcon.tintColor = .ypGray
        searchIcon.contentMode = .center
        
        let iconContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
        searchIcon.frame = CGRect(x: 10, y: 0, width: 20, height: 20)
        iconContainerView.addSubview(searchIcon)
        
        textField.leftView = iconContainerView
        textField.leftViewMode = .always
        
        textField.textColor = .ypBlackDay
        textField.font = .systemFont(ofSize: 17)
        textField.delegate = self
        
        textField.attributedPlaceholder = NSAttributedString(
            string: "Поиск",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.ypGray]
        )
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
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
        dymmyLabel.text = "Что будем отслеживать?"
        dymmyLabel.font = .systemFont(ofSize: 12, weight: .medium)
        dymmyLabel.translatesAutoresizingMaskIntoConstraints = false
        return dymmyLabel
    }()
    
    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ru_RU")
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    // MARK: - Computed Properties
    
    private var hasTrackersForSelectedDate: Bool {
        let calendar = Calendar.current
        let filterDate = datePicker.date
        
        let calendarWeekday = calendar.component(.weekday, from: filterDate)
        let requiredWeekdayIndex = (calendarWeekday + 5) % 7 + 1
        guard let requiredDay = Weekday(rawValue: requiredWeekdayIndex) else { return false }
        
        for category in trackerStore.categories {
            let trackersForDay = category.arrayTracker.filter { tracker in
                return tracker.schedule.contains(requiredDay)
            }
            if !trackersForDay.isEmpty {
                return true
            }
        }
        return false
    }
    
    private var visibleCategories: [TrackerCategory] {
        let calendar = Calendar.current
        
        let filterDate = datePicker.date
        
        let calendarWeekday = calendar.component(.weekday, from: filterDate)
        let requiredWeekdayIndex = (calendarWeekday + 5) % 7 + 1
        guard let requiredDay = Weekday(rawValue: requiredWeekdayIndex) else { return [] }
        
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let dateString = dateFormatter.string(from: filterDate)
        
        return trackerStore.categories.compactMap { category in
            let trackersForDay = category.arrayTracker.filter { tracker in
                return tracker.schedule.contains(requiredDay)
            }
            
            var filtered = trackersForDay
            if !searchText.isEmpty {
                filtered = filtered.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            }
            
            switch currentFilter {
            case .completed:
                filtered = filtered.filter { tracker in
                    trackerStore.completedTrackers.contains { $0.trackID == tracker.id.uuidString && $0.trackDate == dateString }
                }
            case .uncompleted:
                filtered = filtered.filter { tracker in
                    !trackerStore.completedTrackers.contains { $0.trackID == tracker.id.uuidString && $0.trackDate == dateString }
                }
            case .all, .today:
                break
            }
            
            if !filtered.isEmpty {
                return TrackerCategory(nameTrackerCategory: category.nameTrackerCategory, arrayTracker: filtered)
            } else {
                return nil
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        configureAppearance()
        trackerStore.loadData()
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackerStore.loadData()
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .ypWhiteDay
        view.addSubview(datePicker)
        view.addSubview(nameFunction)
        view.addSubview(searchContainerView)
        searchContainerView.addSubview(searchTextField)
        view.addSubview(collectionView)
        view.addSubview(addTrack)
        view.addSubview(dymmy)
        view.addSubview(dymmyLabel)
        view.addSubview(filterButton)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureAppearance() {
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        collectionView.backgroundColor = .white
        collectionView.register(TrackerHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerHeader.identifier)
        collectionView.register(TrackCell.self, forCellWithReuseIdentifier: TrackCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 16
            layout.sectionInset = .init(top: 20, left: 16, bottom: 20, right: 16)
            let width = (UIScreen.main.bounds.width - 32) / 2
            layout.itemSize = CGSize(width: width, height: 150)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            addTrack.topAnchor.constraint(equalTo: view.topAnchor, constant: 57),
            addTrack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            addTrack.heightAnchor.constraint(equalToConstant: 42),
            addTrack.widthAnchor.constraint(equalToConstant: 42),
            
            datePicker.topAnchor.constraint(equalTo: view.topAnchor, constant: 57),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            datePicker.heightAnchor.constraint(equalToConstant: 34),
            
            nameFunction.topAnchor.constraint(equalTo: addTrack.bottomAnchor, constant: 1),
            nameFunction.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            searchContainerView.topAnchor.constraint(equalTo: nameFunction.bottomAnchor, constant: 7),
            searchContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchContainerView.heightAnchor.constraint(equalToConstant: 36),
            
            searchTextField.topAnchor.constraint(equalTo: searchContainerView.topAnchor),
            searchTextField.bottomAnchor.constraint(equalTo: searchContainerView.bottomAnchor),
            searchTextField.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor),
            searchTextField.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: filterButton.topAnchor, constant: -16),
            
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -56),
            filterButton.widthAnchor.constraint(equalToConstant: 200),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            
            dymmy.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            dymmy.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            dymmy.heightAnchor.constraint(equalToConstant: 80),
            dymmy.widthAnchor.constraint(equalToConstant: 80),
            
            dymmyLabel.topAnchor.constraint(equalTo: dymmy.bottomAnchor, constant: 8),
            dymmyLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
        ])
    }
    
    // MARK: - ИСПРАВЛЕННАЯ ЛОГИКА PLACEHOLDER'а
    private func updatePlaceholderVisibility() {
        let isHidden = !visibleCategories.isEmpty
        
        dymmy.isHidden = isHidden
        dymmyLabel.isHidden = isHidden
        
        // Логика изменения текста:
        // Если трекеры на этот день ЕСТЬ в базе, но visibleCategories пустой,
        // значит фильтр (или поиск) скрыл все результаты.
        if hasTrackersForSelectedDate && visibleCategories.isEmpty {
            dymmyLabel.text = "Ничего не найдено"
        } else {
            dymmyLabel.text = "Что будем отслеживать?"
        }
        
        // Скрываем кнопку фильтров, если на выбранную дату нет трекеров в базе
        filterButton.isHidden = !hasTrackersForSelectedDate
    }
    
    // MARK: - Actions
    
    @objc func dateChanged() {
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(datePicker.date)
        
        if isToday && currentFilter == .today {
            // Оставляем фильтр "Сегодня", если выбрали сегодняшний день
        } else {
            currentFilter = .all
        }
        
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    @objc func filterButtonTapped() {
        let filtersVC = FiltersViewController(selectedFilter: currentFilter)
        filtersVC.delegate = self
        present(filtersVC, animated: true)
    }
    
    // MARK: - FiltersViewControllerDelegate
    func didSelectFilter(_ filter: TrackerFilter) {
        currentFilter = filter
        
        if filter == .today {
            datePicker.date = Date()
        }
        
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    @objc func tapAddTrack() {
        let createVC = CreateTrackerViewController(trackerStore: trackerStore)
        
        createVC.onTrackerCreated = { [weak self] tracker, category in
            self?.didCreateHabit(tracker, category: category)
        }
        
        let navController = UINavigationController(rootViewController: createVC)
        navController.modalPresentationStyle = .automatic
        self.present(navController, animated: true)
    }
    
    // MARK: - NewHabitViewControllerDelegate Implementation
    func didCreateHabit(_ habit: Tracker, category: String) {
        trackerStore.addTracker(habit, toCategory: category)
        collectionView.reloadData()
        updatePlaceholderVisibility()
        print("Трекер '\(habit.name)' добавлен в категорию '\(category)' и сохранен в CoreData")
    }
}

// MARK: - DataSource
extension TrackViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].arrayTracker.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackCell.identifier, for: indexPath) as? TrackCell else {
            return UICollectionViewCell()
        }
        
        let tracker = visibleCategories[indexPath.section].arrayTracker[indexPath.row]
        let currentDate = datePicker.date
        
        let color = UIColor(hex: tracker.color) ?? .ypColorSelection1
        
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let dateString = dateFormatter.string(from: currentDate)
        
        let isDone = trackerStore.completedTrackers.contains { record in
            record.trackID == tracker.id.uuidString && record.trackDate == dateString
        }
        
        let daysCount = trackerStore.completedTrackers.filter { $0.trackID == tracker.id.uuidString }.count
        
        cell.configure(
            id: tracker.id.uuidString,
            jobsName: tracker.name,
            daysCount: daysCount,
            isDone: isDone,
            date: currentDate,
            emoji: tracker.emodji,
            color: color
        )
        
        cell.onButtonTapped = { [weak self] in
            guard let self = self else { return }
            self.trackerStore.toggleTrackerRecord(trackerId: tracker.id.uuidString, date: currentDate)
            
            switch self.currentFilter {
            case .completed, .uncompleted:
                self.collectionView.reloadData()
            default:
                self.collectionView.reloadItems(at: [indexPath])
            }
        }
        
        cell.contextMenuProvider = { [weak self] in
            guard let self = self else { return nil }
            
            let isPinned = tracker.isPinned
            
            let pinTitle = isPinned ? "Открепить" : "Закрепить"
            let pinImage = isPinned ? UIImage(systemName: "pin.slash") : UIImage(systemName: "pin")
            
            let pinAction = UIAction(title: pinTitle, image: pinImage) { _ in
                print("Нажато: \(pinTitle) для \(tracker.name)")
            }
            
            let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { _ in
                print("Нажато: Редактировать \(tracker.name)")
            }
            
            let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.deleteTracker(tracker, at: indexPath)
            }
            
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerHeader.identifier, for: indexPath) as? TrackerHeader else {
                return UICollectionReusableView()
            }
            header.configure(title: visibleCategories[indexPath.section].nameTrackerCategory)
            return header
        }
        return UICollectionReusableView()
    }
}

// MARK: - UITextFieldDelegate
extension TrackViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            searchText = updatedText
            collectionView.reloadData()
            updatePlaceholderVisibility()
        }
        return true
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 9
        let availableWidth = collectionView.bounds.width - spacing
        let width = availableWidth / 2
        return CGSize(width: width, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 16, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
}

// MARK: - Private Helper Methods
extension TrackViewController {
    private func deleteTracker(_ tracker: Tracker, at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Удалить трекер?",
            message: "Вы уверены, что хотите удалить трекер «\(tracker.name)»? Это действие нельзя отменить.",
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { _ in
            self.trackerStore.deleteTracker(tracker)
            self.trackerStore.loadData()
            self.collectionView.reloadData()
            self.updatePlaceholderVisibility()
        }
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
}
