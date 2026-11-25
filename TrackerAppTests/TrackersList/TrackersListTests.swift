//
//  TrackersListTests.swift
//  TrackerAppTests
//
//  Created by Данил on 24/11/2026.
//

import XCTest
import SnapshotTesting
@testable import TrackerApp

final class TrackersListTests: XCTestCase {
  // MARK: - Empty State
  func testEmptyTrackers() {
    let viewModel = makeViewModel()
    let vc = TrackersListViewController(viewModel: viewModel)
    
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
  }
  
  func testEmptySearchTrackers() {
    let viewModel = makeViewModel()
    let vc = TrackersListViewController(viewModel: viewModel)
    viewModel.searchTextDidChange(searchText: "search text")
    
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
  }
  
  // MARK: - Categories
  func testOneCategoryWithTrackers() {
    let trackers = [
      makeTracker(name: "Walking", emoji: "🚶"),
      makeTracker(name: "Reading", emoji: "📚"),
      makeTracker(name: "Training", emoji: "💪")
    ]
    
    let viewModel = makeViewModel(categories: [
      TrackerCategory(title: "Habit", trackers: trackers)
    ])
    
    let vc = TrackersListViewController(viewModel: viewModel)
    
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
  }
  
  func testSeveralCategoriesWithTrackers() {
    let viewModel = makeViewModel(categories: [
      TrackerCategory(title: "Health", trackers: [
        makeTracker(name: "Walking", emoji: "🚶"),
        makeTracker(name: "Water", emoji: "💧")
      ]),
      TrackerCategory(title: "Study", trackers: [
        makeTracker(name: "Reading", emoji: "📚"),
        makeTracker(name: "English", emoji: "🇬🇧")
      ]),
      TrackerCategory(title: "Work", trackers: [
        makeTracker(name: "Task", emoji: "💻")
      ])
    ])
    
    let vc = TrackersListViewController(viewModel: viewModel)
    
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
  }
  
  // MARK: - Trackers
  func testPinnedTracker() {
    let viewModel = makeViewModel(categories: [
      TrackerCategory(title: "Habits", trackers: [
        makeTracker(name: "Walking", emoji: "🚶", isPinned: true),
        makeTracker(name: "Reading", emoji: "📚")
      ])
    ])
    
    let vc = TrackersListViewController(viewModel: viewModel)
    
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
  }
  
  func testCompletedTracker() {
    let tracker = makeTracker(name: "Walking", emoji: "🚶")
    
    let viewModel = makeViewModel(
      categories: [
        TrackerCategory(title: "Habits", trackers: [tracker])
      ],
      records: [
        TrackerRecord(trackerId: tracker.id, date: Date())
      ]
    )
    
    let vc = TrackersListViewController(viewModel: viewModel)
    
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
  }
  
  func testSearchWithResults() {
    let viewModel = makeViewModel(categories: [
      TrackerCategory(title: "Habits", trackers: [
        makeTracker(name: "Walking", emoji: "🚶"),
        makeTracker(name: "Reading", emoji: "📚"),
        makeTracker(name: "Cleaning", emoji: "🧹")
      ])
    ])
    
    let vc = TrackersListViewController(viewModel: viewModel)
    
    viewModel.searchTextDidChange(searchText: "Walk")
    
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
  }
  
  private func makeViewModel(categories: [TrackerCategory] = [], records: [TrackerRecord] = []) -> TrackersListViewModel {
    let categoryStore = TrackerCategoryStoreSpy()
    categoryStore.setCategories(categories: categories)
    
    let recordStore = TrackerRecordStoreSpy()
    recordStore.setRecords(records: records)
    
    return TrackersListViewModel(
      trackerCategoryStore: categoryStore,
      trackerStore: TrackerStoreSpy(),
      trackerRecordStore: recordStore
    )
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
      hexColor: "#FF6B6B",
      emoji: emoji,
      schedule: schedule,
      isRegular: isRegular,
      isPinned: isPinned
    )
  }
}
