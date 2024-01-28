//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 22.01.2024.
//

import Foundation

protocol HabitVCDelegate: AnyObject {
    func getSelectedCategory(category: TrackerCategory?)
}

final class CategoriesViewModel {
    
    weak var habitVCDelegate: HabitVCDelegate?
    
    @Observable
    private(set) var categories: [TrackerCategory] = []
    
    @Observable
    private(set) var isCategoriesEmpty: Bool = true
    
    private let trackerCategoryStore: TrackerCategoryStoreProtocol
    private var selectedCategory: TrackerCategory?
    
    convenience init() {
        let trackerCategoryStore = TrackerCategoryStore()
        self.init(trackerCategoryStore: trackerCategoryStore)
    }
    
    init(trackerCategoryStore: TrackerCategoryStore) {
        self.trackerCategoryStore = trackerCategoryStore
        trackerCategoryStore.delegate = self
        getCategories()
    }
    
    func getCategories(){
        categories = try! trackerCategoryStore.fetchCategories()
        isCategoriesEmpty = categories.isEmpty
    }
    
    func numberOfRowsInSection() -> Int {
        return categories.count
    }
    
    func setSelectedCategory(categoryIndex: IndexPath) {
        selectedCategory = categories[categoryIndex.row]
        habitVCDelegate?.getSelectedCategory(category: selectedCategory)
    }
}

extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func didUpdate(_ update: TrackerCategoryStoreUpdate) {
        getCategories()
    }
}
