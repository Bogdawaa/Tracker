//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 21.12.2023.
//

import UIKit
import CoreData

class TrackerCategoryStore {
    
    static let shared = TrackerCategoryStore()
    
    private let context: NSManagedObjectContext
    
    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addNewCategory(_ trackerCategory: TrackerCategory) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        updateExistingCategory(trackerCategoryCoreData, with: trackerCategory)
        try context.save()
    }

    func updateExistingCategory(_ trackerCategoryCoreData: TrackerCategoryCoreData, with trackerCategory: TrackerCategory) {
        trackerCategoryCoreData.category = trackerCategory.category
    }
    
    func fetchCategory() -> [TrackerCategoryCoreData] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerCategoryCoreData")
        let categories = try? context.fetch(request) as? [TrackerCategoryCoreData]
        return categories ?? []
    }
    
    func fetchSingleCategory() -> TrackerCategoryCoreData {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerCategoryCoreData")
        let categories = try? context.fetch(request) as? [TrackerCategoryCoreData]
        return categories?.last ?? TrackerCategoryCoreData()
    }
}
