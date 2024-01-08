////
////  DataProvider.swift
////  Tracker
////
////  Created by Bogdan Fartdinov on 05.01.2024.
////
//
//import Foundation
//import CoreData
//
//struct TrackerStoreUpdate {
//    let insertedIndexex: IndexSet
//    let deletedIndexes: IndexSet
//}
//
//protocol DataProviderDelegate: AnyObject {
//    func didUpdate(_ update: TrackerStoreUpdate)
//}
//
//protocol DataProviderProtocol {
//    var numberOfSections: Int { get }
//    func numberOfRowInSection(_ section: Int) -> Int
//    func object(at: IndexPath) -> Tracker?
//    func addTracker(_ tracker: Tracker) throws
//}
//
//final class DataProvider: NSObject {
//
//    enum DataProviderError: Error {
//        case failedToInitializeContext
//    }
//
//    weak var delegate: DataProviderDelegate?
//
//    private let context: NSManagedObjectContext
//    private let dataStore: TrackerStoreProtocol
//    private var insertedIndexes: IndexSet?
//    private var deletedIndexex: IndexSet?
//
//    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
//        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
//
//        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
//                                                                  managedObjectContext: context,
//                                                                  sectionNameKeyPath: nil,
//                                                                  cacheName: nil)
//        fetchedResultsController.delegate = self
//        try? fetchedResultsController.performFetch()
//        return fetchedResultsController
//    }()
//
//    init(_ dataStore: TrackerStoreProtocol, delegate: DataProviderDelegate) throws {
////        guard let context = dataStore.
//    }
//}
//
//extension DataProvider: DataProviderProtocol {
//    var numberOfSections: Int {
//        <#code#>
//    }
//
//    func numberOfRowInSection(_ section: Int) -> Int {
//        <#code#>
//    }
//
//    func object(at: IndexPath) -> Tracker? {
//        <#code#>
//    }
//    
//    func addTracker(_ tracker: Tracker) throws {
//        <#code#>
//    }
//}
//
//extension DataProvider: NSFetchedResultsControllerDelegate {
//
//}
