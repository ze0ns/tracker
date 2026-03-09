//
//  ViewController.swift
//  Tracker
//
//  Created by Oschepkov Aleksandr on 07.03.2026.
//

import UIKit

class TrackViewController: UIViewController {
//MARK: Mock Data
    private let items = [
           ("Поставить расписание", "0 дней"),
           ("Настроить дежурства", "2 дня")
       ]
    
    //MARK: Private
    private lazy var addTrack: UIButton = {
        let addTrack = UIButton()
        addTrack.setImage(UIImage(resource: .addTracker), for: .normal)
        addTrack.contentMode = .scaleAspectFit
        addTrack.accessibilityIdentifier = "addTracker"
        return addTrack
    }()
    private lazy var nameFunction: UILabel = {
        let nameFunction = UILabel()
        nameFunction.text = "Трекеры"
        nameFunction.font = .systemFont(ofSize: 34)
        return nameFunction
    }()
    private lazy var dymmy: UIImageView = {
        let dymmy = UIImageView()
        dymmy.contentMode = .scaleAspectFit
        dymmy.image = UIImage(resource: .dymmy)
        dymmy.translatesAutoresizingMaskIntoConstraints = false
        return dymmy
    }()
    let datePicker = UIDatePicker()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    var trackRecord: TrackerRecord?
    var trackCategory: TrackerCategory?
    var track: Tracker?
    
//MARK: Configure Action
    @objc func tapAddTrack() {
        let secondVC = CreateTrackerViewController()
        let navController = UINavigationController(rootViewController: secondVC)
        navController.modalPresentationStyle = .automatic
        self.present(navController, animated: true)
    }
    @objc func tapTrackRecord() {
        guard let trackRecord else { return }
        completedTrackers.append(trackRecord)
    }
    
//MARK: Configure LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        configureAppearance()

        dymmy.isHidden = true
    }
//MARK: Configure constrian
    
    private func setupViews() {
        addTrack.translatesAutoresizingMaskIntoConstraints = false
        dymmy.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        nameFunction.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
       
        view.addSubview(datePicker)
        view.addSubview(nameFunction)
        view.addSubview(dymmy)
        view.addSubview(collectionView)
        view.addSubview(addTrack)
    }
    private func configureAppearance() {
        addTrack.addTarget(self, action: #selector(tapAddTrack), for: .touchUpInside)
        
        collectionView.backgroundColor = .white // Фон коллекции
        collectionView.register(TrackerHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerHeader.identifier)
        collectionView.register(TrackCell.self, forCellWithReuseIdentifier: TrackCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Настройка Layout (отступы)
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 16
            layout.sectionInset = .init(top: 20, left: 16, bottom: 20, right: 16)
            // Размер ячейки (ширина экрана минус отступы, высота фиксированная)
            let width = (UIScreen.main.bounds.width - 32) / 2
            layout.itemSize = CGSize(width: width, height: 150)
        }
        
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            addTrack.topAnchor.constraint(equalTo: view.topAnchor, constant: 45),
            addTrack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            addTrack.heightAnchor.constraint(equalToConstant: 42),
            addTrack.widthAnchor.constraint(equalToConstant: 42),
            
            datePicker.topAnchor.constraint(equalTo: view.topAnchor, constant: 49),
            datePicker.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            
            nameFunction.topAnchor.constraint(equalTo: addTrack.bottomAnchor),
            nameFunction.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            

            collectionView.topAnchor.constraint(equalTo: nameFunction.topAnchor, constant: 45),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -45),
            
            dymmy.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dymmy.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            dymmy.heightAnchor.constraint(equalToConstant: 80),
            dymmy.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    
}
// MARK: - DataSource
extension TrackViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackCell.identifier, for: indexPath) as? TrackCell else {
            return UICollectionViewCell()
        }
        
        let item = items[indexPath.row]
        
        // Передаем данные в ячейку, включая выбранную дату
        // item.2 - это строка "0 дней" из вашего массива, но лучше передавать Int
        // Для примера передаем текущую дату datePicker
        cell.configure(
            id: UUID().uuidString, // Здесь должен быть реальный ID трекера
            jobsName: item.0,
            daysCount: 0, // Начальное количество дней
            isDone: false, // Начальное состояние
            date: datePicker.date // Важный момент: передаем дату из пикера
        )
        
        cell.onButtonTapped = {
            print("Нажата кнопка в ячейке: \(item.0)")
            // Здесь можно обновить массив completedTrackers
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerHeader.identifier, for: indexPath) as? TrackerHeader else {
                return UICollectionReusableView()
            }
            header.configure(title: "Домашний уют")
            return header
        }
        return UICollectionReusableView()
    }
}

// MARK: - DelegateFlowLayout
extension TrackViewController: UICollectionViewDelegateFlowLayout {
    // Размер Header
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
    
    // Размер Ячейки (расчет для 2 столбцов)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Отступ между ячейками
        let spacing: CGFloat = 9
        // Доступная ширина (ширина коллекции минус отступ)
        let availableWidth = collectionView.bounds.width - spacing
        // Ширина одной ячейки
        let width = availableWidth / 2
        
        return CGSize(width: width, height: 150)
    }
    
    // Отступы секции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 16, right: 0)
    }
    
    // Минимальный интервал между ячейками (по горизонтали)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    // Минимальный интервал между строками (по вертикали)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}
