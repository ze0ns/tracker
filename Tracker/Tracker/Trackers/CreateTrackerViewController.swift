
//
//  CreateTrackerViewController.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 09.03.2026.
//

import UIKit

protocol CreateTrackerViewControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, category: String)
}

final class CreateTrackerViewController: UIViewController {
    
    // MARK: - Delegate
    weak var delegate: CreateTrackerViewControllerDelegate?
    
    // Замыкание для передачи данных
    var onTrackerCreated: ((Tracker, String) -> Void)?
    
    weak var trackerStore: TrackerStore?
    
    // 2. Создаем кастомный инициализатор
    init(trackerStore: TrackerStore) {
        self.trackerStore = trackerStore
        super.init(nibName: nil, bundle: nil)
    }
    
    // Обязательный инициализатор для storyboard/xib (если используется)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Создание трекера"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let habitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Привычка", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let irregularEventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Нерегулярное событие", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupActions()
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        view.addSubview(habitButton)
        view.addSubview(irregularEventButton)
        
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 78),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            
            habitButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 281),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            
            irregularEventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            irregularEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            irregularEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60),
            
        ])
    }
    
    private func setupActions() {
        habitButton.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        irregularEventButton.addTarget(self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
    }
    
    
    
    // MARK: - Actions
    @objc private func habitButtonTapped() {
        guard let store = trackerStore else { return }
        let newHabitVC = NewHabitViewController(trackerStore: store)
        
        // ПЕРЕДАЕМ ЗАМЫКАНИЕ ДАЛЬШЕ
        newHabitVC.onTrackerCreated = { [weak self] tracker, category in
            self?.onTrackerCreated?(tracker, category)
            self?.dismiss(animated: true) // Закрываем всю цепочку модальных окон
        }
        let navController = UINavigationController(rootViewController: newHabitVC)
        navController.modalPresentationStyle = .automatic
        self.present(navController, animated: true)
    }
    
    @objc private func irregularEventButtonTapped() {
        let secondVC = IrregularHabitViewController()
        let navController = UINavigationController(rootViewController: secondVC)
        navController.modalPresentationStyle = .automatic
        self.present(navController, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension CreateTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: SwiftUI - for working canvas
import SwiftUI
struct CreateTrackerPreview: PreviewProvider {
    static var previews: some View {
        VCProvider<CreateTrackerViewController>.previews
    }
}
