//
//  TrackerService.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 06.12.2023.
//

import Foundation

final class TrackerService {
    
    static let shared = TrackerService()
    
    var trackers: [Tracker] = [Tracker]()
    
    var categories: [TrackerCategory] = [TrackerCategory(
        category: "Важное",
        trackers: []
    )]

    var completedTrackers: [TrackerRecord] = [TrackerRecord]()
    
}
