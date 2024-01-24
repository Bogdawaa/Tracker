//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 22.01.2024.
//

import Foundation

final class CategoriesViewModel {
    
    @Observable
    private(set) var categories: [TrackerCategory] = []
    
    @Observable
    private(set) var isCategoriesEmpty: Bool = true
    
    private let trackerCategoryStore: TrackerCategoryStoreProtocol
    
    convenience init() {
        let trackerCategoryStore = TrackerCategoryStore()
        self.init(trackerCategoryStore: trackerCategoryStore)
    }
    
    init(trackerCategoryStore: TrackerCategoryStore) {
        self.trackerCategoryStore = trackerCategoryStore
        getCategories()
    }
    
    func getCategories(){
        categories = try! trackerCategoryStore.fetchCategories()
        isCategoriesEmpty = categories.isEmpty
    }
    
    func numberOfRowsInSection() -> Int {
        return categories.count ?? 0
    }
}
