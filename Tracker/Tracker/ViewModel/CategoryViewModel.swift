//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Oschepkov Aleksandr on 25.03.2026.
//

import Foundation
protocol CategoryViewModelDelegate: AnyObject {
    func didUpdateDoneButtonState(isEnabled: Bool)
    func didCreateCategorySuccessfully()
    func didReceiveError(message: String)
}

final class CategoryViewModel {
    
    weak var delegate: CategoryViewModelDelegate?
    
    private let trackerStore: TrackerStore
    private var categoryName: String = ""
    
    // Зависимость инжектится снаружи (обычно передается существующий стор)
    init(store: TrackerStore) {
        self.trackerStore = store
    }
    
    // Вызывается при изменении текста в TextField
    func textDidChange(_ text: String) {
        categoryName = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Кнопка активна только если текст не пустой
        let isFormValid = !categoryName.isEmpty
        delegate?.didUpdateDoneButtonState(isEnabled: isFormValid)
    }
    
    // Вызывается при нажатии кнопки "Готово"
    func saveCategory() {
        guard !categoryName.isEmpty else { return }
        
        let success = trackerStore.createCategory(title: categoryName)
        
        if success {
            delegate?.didCreateCategorySuccessfully()
        } else {
            // Если стор вернул false, значит категория уже существует
            delegate?.didReceiveError(message: "Такая категория уже существует")
        }
    }
}
