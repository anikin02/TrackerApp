//
//  CategorySelectionViewModel.swift
//  TrackerApp
//
//  Created by Данил on 17/11/2026.
//

import Foundation

final class CategorySelectionViewModel {
  enum TableUpdate {
    case reload
    case insert(inserted: [Int], reloadRows: [Int])
    case reloadRows([Int])
  }
  
  // MARK: - Properties
  var numberOfRows: Int { categories.count }
  
  // MARK: - Bindings
  var onTableUpdate: Binding<TableUpdate>?
  var onEmptyStateChange: Binding<Bool>?
  var onCategorySelected: Binding<String>?
  
  // MARK: - Private Properties
  private let store: TrackerCategoryStore = .init()
  private var categories: [TrackerCategory] = []
  private var selectedTitle: String?
  
  init(selectedTitle: String? = nil) {
    self.selectedTitle = selectedTitle
    self.store.delegate = self
  }
  
  func viewDidLoad() {
    categories = store.categories
    onTableUpdate?(.reload)
    onEmptyStateChange?(categories.isEmpty)
  }
  
  func cellViewModel(at index: Int) -> CategoryCellModel {
    let title = categories[index].title
    return CategoryCellModel(title: title, isSelected: title == selectedTitle)
  }
  
  func isLastRow(at index: Int) -> Bool {
    index == categories.count - 1
  }
  
  // MARK: - Actions
  func didSelectRow(at index: Int) {
    let title = categories[index].title
    guard title != selectedTitle else { return }
    
    var rows = [index]
    if let oldIndex = categories.firstIndex(where: { $0.title == selectedTitle }) {
      rows.append(oldIndex)
    }
    selectedTitle = title
    onTableUpdate?(.reloadRows(rows))
    onCategorySelected?(title)
  }
  
  func addCategory(title: String) {
    do {
      try store.addNewCategory(with: TrackerCategory(title: title, trackers: []))
    } catch {
      assertionFailure("Не удалось сохранить категорию: \(error)")
    }
  }
}

extension CategorySelectionViewModel: TrackerCategoryStoreDelegate {
  func trackerCategoryStoreDidUpdate() {
    let oldTitles = categories.map(\.title)
    let newCategories = store.categories
    let newTitles = newCategories.map(\.title)
    
    let inserted = newTitles.indices.filter { !oldTitles.contains(newTitles[$0]) }
    
    categories = newCategories
    onEmptyStateChange?(categories.isEmpty)
    
    guard newTitles.count == oldTitles.count + inserted.count else {
      onTableUpdate?(.reload)
      return
    }
    
    var reloadRows: [Int] = []
    if let oldLast = oldTitles.last,
       let index = newTitles.firstIndex(of: oldLast),
       index != newTitles.count - 1 {
      reloadRows.append(index)
    }
    onTableUpdate?(.insert(inserted: inserted, reloadRows: reloadRows))
  }
}
