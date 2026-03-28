//
//  SelectCategoryViewModel.swift
//  Tracker
//
//  Created by Oschepkov Aleksandr on 28.03.2026.
//

import Foundation

protocol SelectCategoryViewModelDelegate: AnyObject {
    // Обновление списка категорий
    func didUpdateCategories()
    // Сообщение о выборе категории
    func didSelectCategory(_ title: String)
}

final class SelectCategoryViewModel {
    
    weak var delegate: SelectCategoryViewModelDelegate?
    
    let trackerStore: TrackerStore
    
    // Список категорий для отображения
    private(set) var categories: [TrackerCategory] = []
    
    // Текущая выбранная категория (для отображения галочки)
    var selectedCategoryTitle: String?
    
    init(store: TrackerStore, selectedCategoryTitle: String?) {
        self.trackerStore = store
        self.selectedCategoryTitle = selectedCategoryTitle
    }
    
    // Загрузка данных
    func fetchCategories() {
        // В данном случае Store уже держит данные в памяти после loadData(),
        // но на всякий случай синхронизируем
        self.categories = trackerStore.categories
        delegate?.didUpdateCategories()
    }
    
    func numberOfRows() -> Int {
        return categories.count
    }
    
    func category(at index: Int) -> TrackerCategory {
        return categories[index]
    }
    
    // Обработка нажатия на ячейку
    func selectCategory(at index: Int) {
        let title = categories[index].nameTrackerCategory
        selectedCategoryTitle = title
        delegate?.didSelectCategory(title)
    }
}
