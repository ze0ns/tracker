//
//  TrackViewController.swift
//

import UIKit

protocol TrackViewControllerDelegate: AnyObject {
    func didTrackers(_ trackers: [Tracker])
}

class TrackViewController: UIViewController, NewHabitViewControllerDelegate {
    
    // MARK: - Public Properties
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    
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
    
    private lazy var dymmy: UIImageView = {
        let dymmy = UIImageView()
        dymmy.contentMode = .scaleAspectFit
        dymmy.image = UIImage(resource: .dymmy)
        dymmy.translatesAutoresizingMaskIntoConstraints = false
        return dymmy
    }()
    
    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ru_RU")
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
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
        return categories.compactMap { category in
            let filteredTrackers = category.arrayTracker.filter { tracker in
                return tracker.schedule.contains(requiredDay)
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
        updatePlaceholderVisibility()
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(datePicker)
        view.addSubview(nameFunction)
        view.addSubview(collectionView)
        view.addSubview(addTrack)
        view.addSubview(dymmy)
        
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
            addTrack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            addTrack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            addTrack.heightAnchor.constraint(equalToConstant: 42),
            addTrack.widthAnchor.constraint(equalToConstant: 42),
            
            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            nameFunction.topAnchor.constraint(equalTo: addTrack.bottomAnchor, constant: 1),
            nameFunction.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            collectionView.topAnchor.constraint(equalTo: nameFunction.bottomAnchor, constant: 20),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            dymmy.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            dymmy.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            dymmy.heightAnchor.constraint(equalToConstant: 80),
            dymmy.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func updatePlaceholderVisibility() {
        dymmy.isHidden = !visibleCategories.isEmpty
    }
    
    // MARK: - Actions
    @objc func dateChanged() {
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    @objc func tapAddTrack() {
        let createVC = CreateTrackerViewController()
        
        createVC.onTrackerCreated = { [weak self] tracker, category in
            self?.didCreateHabit(tracker, category: category)
        }
        
        let navController = UINavigationController(rootViewController: createVC)
        navController.modalPresentationStyle = .automatic
        self.present(navController, animated: true)
    }
    
    // MARK: - NewHabitViewControllerDelegate Implementation
    func didCreateHabit(_ habit: Tracker, category: String) {
        if let index = categories.firstIndex(where: { $0.nameTrackerCategory == category }) {
            var existingCategory = categories[index]
            var newTrackers = existingCategory.arrayTracker
            newTrackers.append(habit)
            categories[index] = TrackerCategory(nameTrackerCategory: existingCategory.nameTrackerCategory, arrayTracker: newTrackers)
        } else {
            let newCategory = TrackerCategory(nameTrackerCategory: category, arrayTracker: [habit])
            categories.append(newCategory)
        }
        
        collectionView.reloadData()
        updatePlaceholderVisibility()
        print("Трекер '\(habit.name)' добавлен в категорию '\(category)'")
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
        
        cell.configure(
            id: tracker.id.uuidString,
            jobsName: tracker.name,
            daysCount: 0,
            isDone: false,
            date: datePicker.date
        )
        
        cell.onButtonTapped = {
            print("Нажата кнопка в ячейке: \(tracker.name)")
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
