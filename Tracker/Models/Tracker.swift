//
//  Tracker.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 30.11.2023.
//

import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: String
}

struct TrackerCategory {
    let category: String
    let trackers: [Tracker]
}

struct TrackerRecord {
    let id: UUID
    let date: Date
}

enum WeekDay: String, CaseIterable, Codable {
    case Monday = "Пн"
    case Tuesday = "Вт"
    case Wednesday = "Ср"
    case Thursday = "Чт"
    case Friday = "Пт"
    case Saturday = "Сб"
    case Sunday = "Вс"
    
    init?(id: Int) {
        switch id {
        case 0: self = .Monday
        case 1: self = .Tuesday
        case 2: self = .Wednesday
        case 3: self = .Thursday
        case 4: self = .Friday
        case 5: self = .Saturday
        case 6: self = .Sunday
        default: return nil
        }
    }
}
