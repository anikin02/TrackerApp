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
    case reloadRows([Int])
    case batch(deleted: [Int], inserted: [Int])
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
  
  func deleteCategory(at index: Int) {
    let categoryTitle = categories[index].title
    do {
      try store.deleteCategory(title: categoryTitle)
    } catch {
      assertionFailure("Не удалось сохранить категорию: \(error)")
    }
  }
  
  func updateCategory(oldTitle: String, newTitle: String) {
    let selectedTitle = self.selectedTitle
    do {
      try store.updateCategory(oldTitle: oldTitle, newTitle: newTitle)
    } catch {
      assertionFailure("Не удалось сохранить категорию: \(error)")
    }
    
    guard oldTitle == selectedTitle,
      let index = categories.firstIndex(where: { $0.title == newTitle }) else { return }
    didSelectRow(at: index)
  }
}

extension CategorySelectionViewModel: TrackerCategoryStoreDelegate {
  func trackerCategoryStoreDidUpdate() {
    let oldTitles = categories.map(\.title)
    let newCategories = store.categories
    let newTitles = newCategories.map(\.title)
    
    categories = newCategories
    onEmptyStateChange?(categories.isEmpty)
    
    if let selectedTitle, !newTitles.contains(selectedTitle) {
      self.selectedTitle = nil
    }
    
    guard oldTitles.filter(newTitles.contains) == newTitles.filter(oldTitles.contains) else {
      onTableUpdate?(.reload)
      return
    }
    
    let deleted = oldTitles.indices.filter { !newTitles.contains(oldTitles[$0]) }
    let inserted = newTitles.indices.filter { !oldTitles.contains(newTitles[$0]) }
    guard !deleted.isEmpty || !inserted.isEmpty else { return }
    
    var reloaded: [Int] = []
    if let oldLast = oldTitles.last,
       let index = newTitles.firstIndex(of: oldLast),
       index != newTitles.count - 1 {
      reloaded.append(index)
    }
    if let newLast = newTitles.indices.last,
       oldTitles.contains(newTitles[newLast]),
       !reloaded.contains(newLast) {
      reloaded.append(newLast)
    }
    
    onTableUpdate?(.batch(deleted: deleted, inserted: inserted))
    if !reloaded.isEmpty {
      onTableUpdate?(.reloadRows(reloaded))
    }
  }
}
