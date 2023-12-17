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
    
//    var trackers: [Tracker] = [Tracker(
//        id: UUID(),
//        name: "Название",
//        color: .ypRed,
//        emoji: "🙂",
//        schedule: [WeekDay.Friday: true]
//        ),
//        Tracker(
//            id: UUID(),
//            name: "Название2",
//            color: .ypRed,
//            emoji: "🙂",
//            schedule: [WeekDay.Friday: true]
//            )
//    ]

//    var categories: [TrackerCategory] = [TrackerCategory]()
    var categories: [TrackerCategory] = [TrackerCategory(
        category: "Важное",
        trackers: []
    )]

    var completedTrackers: [TrackerRecord] = [TrackerRecord]()
    
}
