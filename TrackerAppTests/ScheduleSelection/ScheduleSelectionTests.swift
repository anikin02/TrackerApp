//
//  ScheduleSelectionTests.swift
//  TrackerApp
//
//  Created by Данил on 25/11/2026.
//

import XCTest
import SnapshotTesting
@testable import TrackerApp

final class ScheduleSelectionTests: XCTestCase {
  func testScheduleSelection() {
    let viewModel = ScheduleSelectionViewModel(selectedDays: [.monday, .wednesday, .friday])
    let vc = ScheduleSelectionViewController(viewModel: viewModel)
    
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
  }
}
