//
//  TrackerStore.swift
//  Project: Tracker
//  Created by Oschepkov Aleksandr on 09.03.2026.
//


import UIKit
import CoreData

// MARK: - TrackerStore (Слой работы с данными)

final class TrackerStore {
    
    private let context: NSManagedObjectContext
    
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
        
        loadData()
    }
    
    // MARK: - Public Methods
    func loadData() {
        do {
            try categoriesFetcher.performFetch()
            try recordsFetcher.performFetch()
            
            if let categoryObjects = categoriesFetcher.fetchedObjects {
                // Диагностика: сколько категорий загружено из БД?
                print("📂 Загружено категорий из Core Data: \(categoryObjects.count)")
                
                self.categories = categoryObjects.compactMap { mapCategory($0) }
                
                // Диагностика: сколько трекеров в памяти после маппинга?
                let totalTrackers = self.categories.reduce(0) { $0 + $1.arrayTracker.count }
                print("   -> Всего трекеров в памяти: \(totalTrackers)")
            }
            
            if let recordObjects = recordsFetcher.fetchedObjects {
                self.completedTrackers = recordObjects.compactMap { mapRecord($0) }
                print("📝 Загружено записей о выполнении: \(completedTrackers.count)")
            }
            
        } catch {
            print("❌ Ошибка загрузки данных: \(error)")
        }
    }
    
    func addTracker(_ tracker: Tracker, toCategory categoryTitle: String) {
        let fetchRequest: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", categoryTitle)
        
        var categoryObject: TrackerCategoryCD?
        
        do {
            let results = try context.fetch(fetchRequest)
            categoryObject = results.first
        } catch {
            print("❌ Ошибка поиска категории: \(error)")
            return
        }
        
        if categoryObject == nil {
            categoryObject = TrackerCategoryCD(context: context)
            categoryObject?.title = categoryTitle
            print("🆕 Создана новая категория: \(categoryTitle)")
        } else {
            print("☑️ Найдена существующая категория: \(categoryTitle)")
        }
        
        let trackerObject = TrackerCD(context: context)
        trackerObject.id = tracker.id.uuidString
        trackerObject.name = tracker.name
        trackerObject.color = tracker.color
        trackerObject.emodji = tracker.emodji
        
        // Сохраняем расписание
        let scheduleInts = tracker.schedule.map { $0.rawValue }
        trackerObject.schedule = try? JSONEncoder().encode(scheduleInts)
        
        trackerObject.trackercategory = categoryObject
        
        print("💾 Сохраняем трекер '\(tracker.name)' с расписанием: \(tracker.schedule.map { $0.shortName })")
        
        saveContext()
        loadData()
    }
    
    // MARK: - Delete Tracker
    func deleteTracker(_ tracker: Tracker) {
        let fetchRequest: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id.uuidString)
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if let trackerToDelete = results.first {
                // 1. Удаляем все записи о выполнении, связанные с этим трекером
                let recordsRequest: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
                recordsRequest.predicate = NSPredicate(format: "trackID == %@", tracker.id.uuidString)
                
                let recordsToDelete = try context.fetch(recordsRequest)
                for record in recordsToDelete {
                    context.delete(record)
                }
                
                // 2. Удаляем сам трекер
                context.delete(trackerToDelete)
                
                // 3. Сохраняем контекст
                saveContext()
                loadData()
                
                print("🗑 Трекер '\(tracker.name)' и его записи успешно удалены")
            } else {
                print("⚠️ Трекер с id \(tracker.id) не найден в базе данных")
            }
        } catch {
            print("❌ Ошибка удаления трекера: \(error)")
        }
    }
    func updateTracker(_ tracker: Tracker, newCategory: String) {
        let fetchRequest: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id.uuidString)
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if let trackerToUpdate = results.first {
                // Обновляем свойства трекера
                trackerToUpdate.name = tracker.name
                trackerToUpdate.color = tracker.color
                trackerToUpdate.emodji = tracker.emodji
                let scheduleInts = tracker.schedule.map { $0.rawValue }
                trackerToUpdate.schedule = try? JSONEncoder().encode(scheduleInts)
                
                let categoryRequest: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
                categoryRequest.predicate = NSPredicate(format: "title == %@", newCategory)
                let newCategoryObject = try? context.fetch(categoryRequest).first
                
                if let newCategory = newCategoryObject {
                    trackerToUpdate.trackercategory = newCategory
                }
                
                saveContext()
                loadData()
            }
        } catch {
            print("Ошибка обновления трекера: \(error)")
        }
    }
    
    func toggleTrackerRecord(trackerId: String, date: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        let fetchRequest: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackID == %@ AND trackDate == %@", trackerId, startOfDay as NSDate)
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if let existingRecord = results.first {
                context.delete(existingRecord)
            } else {
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
        guard let title = object.title else { return nil }
        
        guard let trackerSet = object.trackers as? Set<TrackerCD> else {
            print("⚠️ Категория '\(title)' не имеет связи с трекерами (trackers is nil or wrong type)")
            return nil
        }
        
        print("   -> Категория '\(title)' содержит \(trackerSet.count) трекеров в БД")
        
        let trackers = trackerSet.compactMap { mapTracker($0) }
        
        return TrackerCategory(nameTrackerCategory: title, arrayTracker: trackers)
    }
    private func mapTracker(_ object: TrackerCD) -> Tracker? {
        guard let name = object.name,
              let idString = object.id,
              let id = UUID(uuidString: idString) else { return nil }
        
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
            schedule: schedule,
            isPinned: object.isPinned
        )
    }
    
    private func mapRecord(_ object: TrackerRecordCD) -> TrackerRecord? {
        guard let trackerId = object.trackID,
              let date = object.trackDate else { return nil }
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let dateString = formatter.string(from: date)
        
        return TrackerRecord(trackID: trackerId, trackDate: dateString)
    }
    
    @discardableResult
    func createCategory(title: String) -> Bool {
        
        let fetchRequest: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.first != nil {
                print("Категория '\(title)' уже существует")
                return false
            }
            
            
            let newCategory = TrackerCategoryCD(context: context)
            newCategory.title = title
            
            saveContext()
            loadData()
            return true
            
        } catch {
            print("Ошибка создания категории: \(error)")
            return false
        }
    }
}
