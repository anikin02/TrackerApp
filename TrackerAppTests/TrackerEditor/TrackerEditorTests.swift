//
//  TrackerEditorTests.swift
//  TrackerApp
//
//  Created by Данил on 25/11/2026.
//

import XCTest
import SnapshotTesting
@testable import TrackerApp

final class TrackerEditorTests: XCTestCase {
  // MARK: - New Tracker
  func testNewRegularTracker() {
    let viewModel = TrackerEditorViewModel(titleView: "New habit")
    let vc = TrackerEditorViewController(viewModel: viewModel)
    
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
  }
  
  func testNewUnregularTracker() {
    let viewModel = TrackerEditorViewModel(isRegularTracker: false, titleView: "New event")
    let vc = TrackerEditorViewController(viewModel: viewModel)
    
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
  }
  
  // MARK: - Edit Tracker
  func testEditTracker() {
    let tracker = makeTracker(
      name: "Walking",
      emoji: "🙂",
      schedule: [.monday, .wednesday, .friday]
    )
    
    let viewModel = TrackerEditorViewModel(
      titleView: "Edit habit",
      oldTracker: tracker,
      oldCategory: "Health"
    )
    
    let vc = TrackerEditorViewController(viewModel: viewModel)

    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
  }
  
  
  
  private func makeTracker(
    name: String,
    emoji: String,
    isRegular: Bool = true,
    isPinned: Bool = false,
    schedule: Set<WeekDay> = Set(WeekDay.allCases)
  ) -> Tracker {
    Tracker(
      id: UUID(),
      name: name,
      hexColor: HexColorSection.color1.rawValue,
      emoji: emoji,
      schedule: schedule,
      isRegular: isRegular,
      isPinned: isPinned
    )
  }
}
