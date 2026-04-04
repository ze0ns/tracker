//
//  TrackViewController.swift
//

import UIKit

protocol TrackViewControllerDelegate: AnyObject {
    func didTrackers(_ trackers: [Tracker])
}

class TrackViewController: UIViewController, NewHabitViewControllerDelegate {
    
    // MARK: - Properties
    private let trackerStore = TrackerStore()
    private var searchText: String = "" // Добавлено для хранения текста поиска
    
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
    
    private var visibleCategories: [TrackerCategory] {
        let calendar = Calendar.current
        let calendarWeekday = calendar.component(.weekday, from: datePicker.date)
        let requiredWeekdayIndex = (calendarWeekday + 5) % 7 + 1
        
        guard let requiredDay = Weekday(rawValue: requiredWeekdayIndex) else {
            return []
        }

        return trackerStore.categories.compactMap { category in
            // Фильтруем трекеры по дню
            let trackersForDay = category.arrayTracker.filter { tracker in
                return tracker.schedule.contains(requiredDay)
            }
            
            // Если есть текст поиска, фильтруем еще и по названию
            let filteredTrackers: [Tracker]
            if searchText.isEmpty {
                filteredTrackers = trackersForDay
            } else {
                filteredTrackers = trackersForDay.filter { tracker in
                    return tracker.name.lowercased().contains(searchText.lowercased())
                }
            }
            
            if !filteredTrackers.isEmpty {
                return TrackerCategory(nameTrackerCategory: category.nameTrackerCategory, arrayTracker: filteredTrackers)
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
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            dymmy.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            dymmy.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            dymmy.heightAnchor.constraint(equalToConstant: 80),
            dymmy.widthAnchor.constraint(equalToConstant: 80),
            
            dymmyLabel.topAnchor.constraint(equalTo: dymmy.bottomAnchor, constant: 8),
            dymmyLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
        ])
    }
    
    private func updatePlaceholderVisibility() {
        dymmy.isHidden = !visibleCategories.isEmpty
        dymmyLabel.isHidden = !visibleCategories.isEmpty
    }
    
    // MARK: - Actions
    @objc func dateChanged() {
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
        // Сохраняем через Store
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
        
        // Форматируем дату для сравнения
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let dateString = dateFormatter.string(from: currentDate)
        
        // Проверяем выполнение через Store
        let isDone = trackerStore.completedTrackers.contains { record in
            record.trackID == tracker.id.uuidString && record.trackDate == dateString
        }
        
        // Считаем дни
        let daysCount = trackerStore.completedTrackers.filter { $0.trackID == tracker.id.uuidString }.count
        
        cell.configure(
            id: tracker.id.uuidString,
            jobsName: tracker.name,
            daysCount: daysCount,
            isDone: isDone,
            date: currentDate
        )
        
        cell.onButtonTapped = { [weak self] in
            guard let self = self else { return }
            
            // Переключаем запись в CoreData
            self.trackerStore.toggleTrackerRecord(trackerId: tracker.id.uuidString, date: currentDate)
            
            // Обновляем ячейку
            self.collectionView.reloadItems(at: [indexPath])
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
