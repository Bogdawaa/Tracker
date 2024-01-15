////
////  ScheduleDayValueTransformer.swift
////  Tracker
////
////  Created by Bogdan Fartdinov on 24.12.2023.
////
//
//import Foundation
//
//@objc final class ScheduleDayValueTransformer: ValueTransformer {
//    override class func transformedValueClass() -> AnyClass { NSData.self }
//    override class func allowsReverseTransformation() -> Bool { true }
//
//    override func transformedValue(_ value: Any?) -> Any? {
//        guard let schedule = value as? [WeekDay: Bool] else { return nil }
//        return try? JSONEncoder().encode(schedule)
//    }
//
//    override func reverseTransformedValue(_ value: Any?) -> Any? {
//        guard let data = value as? NSData else { return nil }
//        return try? JSONDecoder().decode([WeekDay: Bool].self, from: data as Data)
//    }
//
//    static func register() {
//        ValueTransformer.setValueTransformer(
//            ScheduleDayValueTransformer(),
//            forName: NSValueTransformerName(rawValue: String(describing: ScheduleDayValueTransformer.self)))
//    }
//}
