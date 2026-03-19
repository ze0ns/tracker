//
//  TrackerStore.swift
//  Tracker
//
//  Created by Oschepkov Aleksandr on 18.03.2026.
//

import UIKit
import CoreData

// MARK: - TrackerStore (Слой работы с данными)

class TrackerStore {
    
    private let context: NSManagedObjectContext
    
    // Имя модели должно совпадать с именем файла .xcdatamodeld
    private let modelName = "TrackersCoreData"
    
    // Кэшированные данные для быстрого доступа
    private(set) var categories: [TrackerCategory] = []
    private(set) var completedTrackers: [TrackerRecord] = []
    
    // FetchedResultsControllers для отслеживания изменений
    private lazy var categoriesFetcher: NSFetchedResultsController<TrackerCategoryCD> = {
        let fetchRequest: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        return controller
    }()
    
    private lazy var recordsFetcher: NSFetchedResultsController<TrackerRecordCD> = {
        let fetchRequest: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        // ИСПРАВЛЕНО: "date" заменено на "trackDate"
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "trackDate", ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        return controller
    }()
    
    init() {
        // Настройка стека CoreData
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Не удалось найти модель CoreData")
        }
        
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Ошибка загрузки CoreData: \(error)")
            }
        }
        self.context = container.viewContext
        
        // Загружаем данные при инициализации
        loadData()
    }
    
    // MARK: - Public Methods
    
    /// Загружает категории и записи из базы в память
    func loadData() {
        do {
            try categoriesFetcher.performFetch()
            try recordsFetcher.performFetch()
            
            // Маппинг категорий
            if let categoryObjects = categoriesFetcher.fetchedObjects {
                self.categories = categoryObjects.compactMap { mapCategory($0) }
            }
            
            // Маппинг записей
            if let recordObjects = recordsFetcher.fetchedObjects {
                self.completedTrackers = recordObjects.compactMap { mapRecord($0) }
            }
            
        } catch {
            print("Ошибка загрузки данных: \(error)")
        }
    }
    
    /// Добавляет новый трекер в категорию
    func addTracker(_ tracker: Tracker, toCategory categoryTitle: String) {
        // Ищем категорию в контексте
        let fetchRequest: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", categoryTitle)
        
        var categoryObject: TrackerCategoryCD?
        
        do {
            let results = try context.fetch(fetchRequest)
            categoryObject = results.first
        } catch {
            print("Ошибка поиска категории: \(error)")
            return
        }
        
        // Если категории нет, создаем новую
        if categoryObject == nil {
            categoryObject = TrackerCategoryCD(context: context)
            categoryObject?.title = categoryTitle
        }
        
        // Создаем объект трекера
        let trackerObject = TrackerCD(context: context)
        trackerObject.id = tracker.id.uuidString
        trackerObject.name = tracker.name
        trackerObject.color = tracker.color
        trackerObject.emodji = tracker.emodji
        let scheduleInts = tracker.schedule.map { $0.rawValue }
        trackerObject.schedule = try? JSONEncoder().encode(scheduleInts)
        
        saveContext()
        
        // Обновляем локальный кэш
        loadData()
    }
    
    /// Переключает статус выполнения трекера
    func toggleTrackerRecord(trackerId: String, date: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        // Ищем запись
        let fetchRequest: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        // ИСПРАВЛЕНО: "trackerId" заменено на "trackID", "date" заменено на "trackDate"
        fetchRequest.predicate = NSPredicate(format: "trackID == %@ AND trackDate == %@", trackerId, startOfDay as NSDate)
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if let existingRecord = results.first {
                // Если запись есть - удаляем
                context.delete(existingRecord)
            } else {
                // Если нет - создаем
                let newRecord = TrackerRecordCD(context: context)
                newRecord.trackID = trackerId
                newRecord.trackDate = startOfDay
            }
            
            saveContext()
            loadData()
            
        } catch {
            print("Ошибка переключения записи: \(error)")
        }
    }
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Ошибка сохранения контекста: \(error)")
            }
        }
    }
    
    // MARK: - Mapping Helpers
    
    private func mapCategory(_ object: TrackerCategoryCD) -> TrackerCategory? {
        guard let title = object.title,
              let trackerSet = object.trackers as? Set<TrackerCD> else { return nil }
        
        let trackers = trackerSet.compactMap { mapTracker($0) }
        
        return TrackerCategory(nameTrackerCategory: title, arrayTracker: trackers)
    }
    
    private func mapTracker(_ object: TrackerCD) -> Tracker? {
        guard let name = object.name,
              let idString = object.id,
              let id = UUID(uuidString: idString) else { return nil }
        
        // Восстанавливаем расписание
        var schedule: [Weekday] = []
        
        if let data = object.schedule {
            do {
                let rawValues = try JSONDecoder().decode([Int].self, from: data)
                schedule = rawValues.compactMap { Weekday(rawValue: $0) }
            } catch {
                print("Ошибка декодирования расписания: \(error.localizedDescription)")
            }
        }
        
        return Tracker(
            id: id,
            name: name,
            color: object.color ?? "",
            emodji: object.emodji ?? "",
            schedule: schedule
        )
    }
    
    private func mapRecord(_ object: TrackerRecordCD) -> TrackerRecord? {
        guard let trackerId = object.trackID,
              let date = object.trackDate else { return nil }
        
        // Если ваш TrackerRecord хранит дату как String, нужно отформатировать
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let dateString = formatter.string(from: date)
        
        return TrackerRecord(trackID: trackerId, trackDate: dateString)
    }
}
