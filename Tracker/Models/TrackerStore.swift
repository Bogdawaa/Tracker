//
//  TrackerStore.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 21.12.2023.
//

import UIKit
import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
}

protocol TrackerStoreProtocol {
    func setDelegate(_ delegate: TrackerStoreDelegate)
    func fetchTracker(_ trackerCoreData: TrackerCoreData) throws -> Tracker
    func addTrackerToCategory(_ tracker: Tracker, to category: TrackerCategory) throws
}

struct TrackerStoreUpdate {
    let insertedIndexPaths: [IndexPath]
    let insertedSections: IndexSet
}

private enum TrackerStoreError: Error {
    case failedToConvertTracker
}

final class TrackerStore: NSObject {
    
    weak var delegate: TrackerStoreDelegate?
    
    private let context: NSManagedObjectContext
    private var insertedIndexPaths: [IndexPath] = []
    private var insertedSections: IndexSet = []
    
    private var trackers: [Tracker] {
        guard let fetchedTrackers = self.fetchedResultsController.fetchedObjects,
              let trackers = try? fetchedTrackers.map( {
                  try self.convertTracker(from: $0)
              })
        else { return [] }
        return trackers
    }
    
    private let uiColorMarshalling = UIColorMarshalling()
    
    private lazy var trackerCategoryStore: TrackerCategoryStoreProtocol = {
        TrackerCategoryStore(context: context)
    }()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    private func convertTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackerCoreData.id,
              let name = trackerCoreData.name,
              let colorString = trackerCoreData.color,
              let emoji = trackerCoreData.emoji

        else {
            throw TrackerStoreError.failedToConvertTracker
        }
        
        let color = uiColorMarshalling.color(from: colorString)
        let schedule = trackerCoreData.schedule
        
        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule ?? ""
        )
    }
    
    private func addTracker(_ tracker: Tracker, to category: TrackerCategory) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        let trackerCategoryCoreData = try trackerCategoryStore.fetchSingleCategoryCoreData(for: category)
        
        trackerCoreData.id = tracker.id
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.name = tracker.name
        trackerCoreData.schedule = tracker.schedule
        trackerCoreData.category = trackerCategoryCoreData
        try context.save()
    }
}

extension TrackerStore: TrackerStoreProtocol {
    
    func setDelegate(_ delegate: TrackerStoreDelegate) {
        self.delegate = delegate
    }
    
    func addTrackerToCategory(_ tracker: Tracker, to category: TrackerCategory) throws {
        try addTracker(tracker, to: category)
    }
    
    func fetchTracker(_ trackerCoreData: TrackerCoreData) throws -> Tracker {
        try convertTracker(from: trackerCoreData)
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedSections.removeAll()
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
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            insertedSections.insert(sectionIndex)
        default:
            break
        }
    }
}
