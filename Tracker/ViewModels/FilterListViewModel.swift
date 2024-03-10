//
//  FilterListViewModel.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 08.03.2024.
//

import Foundation

protocol FilterListVCDelegate: AnyObject {
    func setFilter(filter: Filters)
}

final class FilterListViewModel {

    @Observable
    var selectedFilter = Filters.All
    
    weak var delegate: FilterListVCDelegate?
    
    var selectedCellIndex: IndexPath = IndexPath(row: 0, section: 0)
    
    let filtersList = [
        "all_trackers".localized,
        "trackers_for_today".localized,
        "completed_trackers".localized,
        "uncompleted_trackers".localized
    ]
    
    func numberOfRowsInSection() -> Int {
        return filtersList.count
    }
    
    func setSelectedFilter(filterIndex: IndexPath) {
        selectedCellIndex = filterIndex
        
        switch selectedCellIndex.row {
        case 0:
            selectedFilter = Filters.All
        case 1:
            selectedFilter = Filters.Today
        case 2:
            selectedFilter = Filters.Completed
        case 3:
            selectedFilter = Filters.Uncompleted
        default:
            selectedFilter = Filters.All
        }
        delegate?.setFilter(filter: selectedFilter)
    }
}
