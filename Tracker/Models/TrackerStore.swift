//
//  TrackerStore.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 21.12.2023.
//

import UIKit
import CoreData

protocol TrackerStoreProtocol {
    func addNewTracker(_ tracker: Tracker, category: TrackerCategoryCoreData) throws
}

class TrackerStore: TrackerStoreProtocol {
    
    static let shared = TrackerStore()
    
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    
    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addNewTracker(_ tracker: Tracker, category: TrackerCategoryCoreData) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        updateExistingTracker(trackerCoreData, with: tracker, category: category)
        try context.save()
    }
    
    func updateExistingTracker(_ trackerCoreData: TrackerCoreData, with tracker: Tracker, category: TrackerCategoryCoreData) {
        trackerCoreData.id = tracker.id
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.name = tracker.name
        trackerCoreData.schedule = tracker.schedule as NSObject
        trackerCoreData.category = category
    }
    
    func fetchTrackers() -> [TrackerCoreData] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerCoreData")
        let trackers = try? context.fetch(request) as? [TrackerCoreData]
        return trackers ?? []
    }
    
    func fetchTrackersByCategory(trackerCategory: TrackerCategoryCoreData) -> [TrackerCoreData] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerCoreData")
        request.predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(TrackerCoreData.category.category), trackerCategory.category ?? "")
        let trackers = try? context.fetch(request) as? [TrackerCoreData]
        return trackers ?? []
    }
}
