//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 22.01.2024.
//

import UIKit

protocol HabitVCDelegate: AnyObject {
    func getSelectedCategory(category: TrackerCategory?)
}

protocol CategoriesViewModelDelegate: AnyObject {
    func showVC(vc: UIViewController)
}

final class CategoriesViewModel {
    
    weak var delegate: CategoriesViewModelDelegate?
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
            print("categories: \(categories.count)")
            isCategoriesEmpty = categories.isEmpty
        } catch {
            //
        }
        
    }
    
    func numberOfRowsInSection() -> Int {
        return categories.count
    }
    
    func setSelectedCategory(categoryIndex: IndexPath) {
        selectedCategory = categories[categoryIndex.row]
        habitVCDelegate?.getSelectedCategory(category: selectedCategory)
    }
    
    func editCategory(_ indexPath: IndexPath) {
        let category = categories[indexPath.row]
        let editCategoryVC = EditCategoryViewController(trackerCategoryStore: trackerCategoryStore)
        editCategoryVC.setupScreen(with: category)
        delegate?.showVC(vc: editCategoryVC)
    }
    
    func deleteCategory(indexPath: IndexPath) {
        let category = categories[indexPath.row]
        try? self.trackerCategoryStore.delete(trackerCategory: category)
        getCategories()
    }
}

extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func didUpdate(_ update: TrackerCategoryStoreUpdate) {
        getCategories()
    }
}
