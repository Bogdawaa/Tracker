//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 21.12.2023.
//

import UIKit
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerCategoryStoreUpdate)
}

protocol TrackerCategoryStoreProtocol {
    func setDelegate(_ delegate: TrackerCategoryStoreDelegate)
    func fetchSingleCategoryCoreData(for category: TrackerCategory) throws -> TrackerCategoryCoreData
    func fetchCategories() throws -> [TrackerCategory]
    func addNewCategory(_ trackerCategory: TrackerCategory) throws
    func removeTracker(tracker: Tracker, category: TrackerCategory) throws
    func update(trackerCategory: TrackerCategory, with categoryName: String) throws
    func delete(trackerCategory: TrackerCategory) throws
}

struct TrackerCategoryStoreUpdate {
    let insertedIndexPaths: [IndexPath]
}

private enum TrackerCategoryStoreError: Error {
    case failedToFetchCategory
    case failedToEncodeCategory
    case failedToEncodeTrackersSet
}

final class TrackerCategoryStore: NSObject {
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()

    
    private lazy var trackerStore: TrackerStore = {
        TrackerStore(context: context)
    }()
    
    private var insertedIndexPaths: [IndexPath] = []
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.category, ascending: false)]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    private func convertToTrackerCategory(from trackerCategoryCoreDate: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let category = trackerCategoryCoreDate.category else { throw TrackerCategoryStoreError.failedToEncodeCategory }
        
        guard let trackersSet = trackerCategoryCoreDate.trackers as? Set<TrackerCoreData> else {
            throw TrackerCategoryStoreError.failedToEncodeTrackersSet
        }
        
        var trackers: [Tracker] = []
        for tracker in trackersSet {
            let fetchedTracker = try trackerStore.fetchTracker(tracker)
            trackers.append(fetchedTracker)
        }
        return TrackerCategory(category: category, trackers: trackers)
    }
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    private func fetchSingleCategory(for category: TrackerCategory) throws -> TrackerCategoryCoreData {
        let request = TrackerCategoryCoreData.fetchRequest()
        let predicate = NSPredicate(format: "%K  = %@", #keyPath(TrackerCategoryCoreData.category), category.category)
        request.predicate = predicate
        
        guard let categories = try? context.fetch(request).first else {
            throw TrackerCategoryStoreError.failedToFetchCategory
        }
        return categories
    }
    
    private func getCategories() throws -> [TrackerCategory] {
        guard let fetchedCategories = fetchedResultsController.fetchedObjects else {
            throw TrackerCategoryStoreError.failedToFetchCategory
        }
        let categories = try fetchedCategories.map { try convertToTrackerCategory(from: $0) }
        return categories
    }
    
    private func addCategory(_ trackerCategory: TrackerCategory) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.category = trackerCategory.category
        trackerCategoryCoreData.trackers = NSSet()
        try context.save()
    }
    
    private func removeTrackerFromCategory(tracker: Tracker, category: TrackerCategory) throws {
        let trackerCategoryCoreData = try? fetchSingleCategoryCoreData(for: category)
        
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.name = tracker.name
        trackerCoreData.schedule = tracker.schedule
        trackerCoreData.isPinned = tracker.isPinned
        trackerCoreData.category = trackerCategoryCoreData
        
        if let trackerCategoryCoreData = trackerCategoryCoreData {
            trackerCategoryCoreData.category = category.category
            trackerCategoryCoreData.removeFromTrackers(trackerCoreData)
        }
    }
    
    private func updateCategory(trackerCategory: TrackerCategory, with categoryName: String) throws {
        let trackerCategoryCoreData = try? fetchSingleCategoryCoreData(for: trackerCategory)
        if let trackerCategoryCoreData = trackerCategoryCoreData {
            trackerCategoryCoreData.category = categoryName
        }
        try context.save()
    }
    
    private func deleteCategory(trackerCategory: TrackerCategory) throws {
        let trackerCategoryCoreData = try? fetchSingleCategoryCoreData(for: trackerCategory)
        guard let trackerCategoryCoreData = trackerCategoryCoreData else { return }
        context.delete(trackerCategoryCoreData)
        try context.save()
    }
    
}

extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    
    func setDelegate(_ delegate: TrackerCategoryStoreDelegate) {
        self.delegate = delegate
    }
    
    func addNewCategory(_ trackerCategory: TrackerCategory) throws {
        try addCategory(trackerCategory)
    }
    
    func fetchCategories() throws -> [TrackerCategory] {
        try getCategories()
    }
    
    func fetchSingleCategoryCoreData(for category: TrackerCategory) throws -> TrackerCategoryCoreData {
        try fetchSingleCategory(for: category)
    }
    
    func removeTracker(tracker: Tracker, category: TrackerCategory) throws {
        try removeTrackerFromCategory(tracker: tracker, category: category)
    }
    
    func update(trackerCategory: TrackerCategory, with categoryName: String) throws {
        try updateCategory(trackerCategory: trackerCategory, with: categoryName)
    }
    
    func delete(trackerCategory: TrackerCategory) throws {
        try deleteCategory(trackerCategory: trackerCategory)
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths.removeAll()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(
            TrackerCategoryStoreUpdate(
                insertedIndexPaths: insertedIndexPaths
            )
        )
        insertedIndexPaths.removeAll()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexPaths.append(indexPath)
            }
        default:
            break
        }
    }
}
