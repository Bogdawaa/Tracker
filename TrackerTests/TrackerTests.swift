//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Bogdan Fartdinov on 10.03.2024.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    func testViewController() throws {
        let vc = TrackerViewController()
//        vc.view.backgroundColor = .ypRed
        
        assertSnapshot(matching: vc, as: .image)
    }
}
