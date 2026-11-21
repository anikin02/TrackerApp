//
//  FilterViewModel.swift
//  TrackerApp
//
//  Created by Данил on 21/11/2026.
//

protocol FilteredDelegate {
  func filterTrackers(filterOption: FilterOption)
}

final class FilterViewModel {
  // MARK: - Properties
  let delegate: FilteredDelegate
  var reloadRows: Binding<[Int]>?
  var numberOfRows: Int {
    filterOptions.count
  }
  
  // MARK: - Private Properties
  private let filterOptions: [FilterOption] = FilterOption.sortedByRawValue
  private var selectedFilterOption: FilterOption?
  private let service: FilterSavingService = FilterSavingService.shared
  
  // MARK: - Init
  init(delegate: FilteredDelegate) {
    self.delegate = delegate
    let savedFilter = service.savedFilter
    if savedFilter == .showAllTrackers || savedFilter == .showTodayTrackers {
      self.selectedFilterOption = nil
    } else {
      self.selectedFilterOption = savedFilter
    }
  }
  
  // MARK: - Methods
  func makeCellModel(for index: Int) -> FilterCellModel {
    FilterCellModel(title: filterOptions[index].title,
                    isSelected: selectedFilterOption == filterOptions[index])
  }
  
  func isLastRow(at index: Int) -> Bool {
    index == filterOptions.count - 1
  }
  
  // MARK: - Actions
  func didSelectRow(at index: Int) {
    let filterOption = filterOptions[index]
    guard filterOption != selectedFilterOption else { return }
    
    var rows = [index]
    if let oldIndex = filterOptions.firstIndex(where: { $0 == selectedFilterOption }) {
      rows.append(oldIndex)
    }
    selectedFilterOption = filterOption
    service.savedFilter = filterOption
    reloadRows?(rows)
    delegate.filterTrackers(filterOption: filterOption)
  }
}
