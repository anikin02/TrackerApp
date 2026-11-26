//
//  CategoryEditorTests.swift
//  TrackerApp
//
//  Created by Данил on 25/11/2026.
//

import XCTest
import SnapshotTesting
@testable import TrackerApp

final class CategoryEditorTests: XCTestCase {
  // MARK: - New Category
  func testNewCategory() {
    let vc = CategoryEditorViewController(titleView: "New category")
    
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
  }
  
  // MARK: - Edit Category
  func testEditCategory() {
    let vc = CategoryEditorViewController(titleView: "Edit category", oldCategoryTitle: "Health")
    
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
  }
}
