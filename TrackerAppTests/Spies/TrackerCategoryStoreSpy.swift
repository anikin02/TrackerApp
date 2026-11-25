//
//  TrackerCategoryStoreSpy.swift
//  TrackerApp
//
//  Created by Данил on 24/11/2026.
//

@testable import TrackerApp
import Foundation


final class TrackerCategoryStoreSpy: NSObject, TrackerCategoryStoreProtocol {
  weak var delegate: TrackerCategoryStoreDelegate?
  var categories: [TrackerCategory] = []
  
  func setCategories(categories: [TrackerCategory]) {
    self.categories = categories
  }
  
  func addNewCategory(with category: TrackerCategory) throws {}
  
  func updateCategory(oldTitle: String, newTitle: String) throws {}
  
  func deleteCategory(title: String) throws {}
  
  func fetchCategory(title: String) throws -> TrackerCategoryCoreData? {
    nil
  }
}
