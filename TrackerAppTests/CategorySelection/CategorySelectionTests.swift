//
//  CategorySelectionTests.swift
//  TrackerApp
//
//  Created by Данил on 25/11/2026.
//

import XCTest
import SnapshotTesting
@testable import TrackerApp

final class CategorySelectionTests: XCTestCase {
  // MARK: - Empty State
  func testEmptyCategories() {
    let viewModel = makeViewModel()
    let vc = CategorySelectionViewController(viewModel: viewModel)
    
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
  }
  
  // MARK: - Categories
  func testSelectedCategory() {
    let viewModel = makeViewModel(
      categories: [
        TrackerCategory(title: "Health", trackers: []),
        TrackerCategory(title: "Study", trackers: []),
        TrackerCategory(title: "Work", trackers: [])
      ],
      selectedTitle: "Study"
    )
    
    let vc = CategorySelectionViewController(viewModel: viewModel)
    
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
  }
  
  private func makeViewModel(categories: [TrackerCategory] = [], selectedTitle: String? = nil) -> CategorySelectionViewModel {
    let store = TrackerCategoryStoreSpy()
    store.setCategories(categories: categories)
    
    return CategorySelectionViewModel(selectedTitle: selectedTitle, store: store)
  }
}
