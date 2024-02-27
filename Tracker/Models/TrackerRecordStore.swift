//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 21.12.2023.
//

import UIKit
import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerCategoryStoreUpdate)
}

protocol TrackerRecordStoreProtocol {
    func fetchRecords() throws -> [TrackerRecord]
    func addNewRecord(with id: UUID, by date: Date) throws
    func deleteRecord(_ trackerRecordCoreData: TrackerRecordCoreData) throws
    func fetchTrackerRecordCoreData(for trackerID: UUID, by date: Date) throws -> TrackerRecordCoreData?
}

private enum TrackerRecordStoreError: Error {
    case failedToFetchTracker
}

class TrackerRecordStore: NSObject {
    
    private let context: NSManagedObjectContext
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    private func fetchTrackerCoreData(for trackerID: UUID) throws -> TrackerCoreData? {
        let request = TrackerCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        let predicate = NSPredicate(format: "%K = %@", (\TrackerCoreData.id)._kvcKeyPathString!, trackerID as CVarArg)
        request.predicate = predicate
        return try context.fetch(request).first
    }
    
    func fetchTrackerRecordCoreData(for trackerID: UUID, by date: Date) throws -> TrackerRecordCoreData? {
        let request = TrackerRecordCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        let predicate = NSPredicate(format: "%K = %@ AND %K = %@",
                                    (\TrackerRecordCoreData.id)._kvcKeyPathString!, trackerID as CVarArg,
                                    #keyPath(TrackerRecordCoreData.date), date as CVarArg
        )
        request.predicate = predicate
        return try context.fetch(request).first
    }
    
    private func delete(trackerRecordCoreData: TrackerRecordCoreData) throws {
        context.delete(trackerRecordCoreData)
        try context.save()
    }
}

extension TrackerRecordStore: TrackerRecordStoreProtocol {
    
    func fetchRecords() throws -> [TrackerRecord] {
        let request = TrackerRecordCoreData.fetchRequest()
        let recordsCD = try context.fetch(request)
        let records = recordsCD.compactMap { record -> TrackerRecord? in
            guard let id = record.id, let date = record.date else { return nil }
            return TrackerRecord(id: id, date: date)
        }
        return records
    }
    
    func addNewRecord(with id: UUID, by date: Date) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context) 
        trackerRecordCoreData.id = id
        trackerRecordCoreData.date = date
        try context.save()
    }
    
    func deleteRecord(_ trackerRecordCoreData: TrackerRecordCoreData) throws {
        try delete(trackerRecordCoreData: trackerRecordCoreData)
    }
}
