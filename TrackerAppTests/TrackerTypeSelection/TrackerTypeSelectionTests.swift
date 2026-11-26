//
//  TrackerTypeSelectionTests.swift
//  TrackerApp
//
//  Created by Данил on 25/11/2026.
//

import XCTest
import SnapshotTesting
@testable import TrackerApp

final class TrackerTypeSelectionTests: XCTestCase {
  func testTrackerTypeSelection() {
    let vc = TrackerTypeSelectionViewController()
    
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
  }
}

