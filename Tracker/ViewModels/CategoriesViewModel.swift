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
    var selectedCellIndex: IndexPath?
    let trackerCategoryStore: TrackerCategoryStoreProtocol
    
    @Observable
    private(set) var categories: [TrackerCategory] = []
    
    @Observable
    private(set) var isCategoriesEmpty: Bool = true
    
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
        do {
            categories = try trackerCategoryStore.fetchCategories()
            isCategoriesEmpty = categories.isEmpty
        } catch {
            // TODO: обработать исключение
        }
        
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
