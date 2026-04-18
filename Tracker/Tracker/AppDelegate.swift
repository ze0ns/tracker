//
//  AppDelegate.swift
//  Tracker
//
//  Created by Oschepkov Aleksandr on 07.03.2026.
//

import UIKit
import CoreData
import AppMetricaCore


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if let configuration = AppMetricaConfiguration(apiKey: "dfc1aff6-6ef8-44e9-9cd6-87b684efa739") {
             AppMetrica.activate(with: configuration)
         }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    // MARK: - Metrics Events (Open / Close)
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppMetrica.reportEvent(name: "Open", parameters: nil, onFailure: { error in
            print("Ошибка отправки метрики Open: \(error.localizedDescription)")
        })
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        AppMetrica.reportEvent(name: "Close", parameters: nil, onFailure: { error in
            print("Ошибка отправки метрики Close: \(error.localizedDescription)")
        })
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackersCoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

