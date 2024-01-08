//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 21.12.2023.
//

import UIKit
import CoreData

class TrackerRecordStore {
    
    static let shared = TrackerRecordStore()

    private let context: NSManagedObjectContext
    
    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addNewRecord(_ trackerRecord: TrackerRecord) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        updateExistingRecord(trackerRecordCoreData, with: trackerRecord)
        try context.save()
    }
    
    func updateExistingRecord(_ trackerRecordCoreData: TrackerRecordCoreData, with trackerRecord: TrackerRecord) {
        trackerRecordCoreData.id = trackerRecord.id
        trackerRecordCoreData.date = trackerRecord.date
    }
    
    func fetchRecords() -> [TrackerRecordCoreData] {
        let request = NSFetchRequest<TrackerRecordCoreData> (entityName: "TrackerRecordCoreData")
        let records = try? context.fetch(request)
        return records ?? []
    }
    
    func deleteRecord(_ trackerRecordCoreData: TrackerRecordCoreData) {
        context.delete(trackerRecordCoreData)
    }
}
