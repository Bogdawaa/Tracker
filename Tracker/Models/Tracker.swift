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
    let isPinned: Bool
    let isRegular: Bool
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

func convertScheduleStringToInt(scheduleStr: String) -> [Int] {
    var arrInt: [Int] = []
    let daysStringArr = scheduleStr.components(separatedBy: ",")
    for day in daysStringArr {
        let trimmedDay = day.trimmingCharacters(in: .whitespaces)
        switch trimmedDay {
        case "Пн":
            arrInt.append(0)
        case "Вт":
            arrInt.append(1)
        case "Ср":
            arrInt.append(2)
        case "Чт":
            arrInt.append(3)
        case "Пт":
            arrInt.append(4)
        case "Сб":
            arrInt.append(5)
        case "Вс":
            arrInt.append(6)
        default:
            continue
        }
    }
    return arrInt
}
