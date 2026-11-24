//
//  TrackersListViewModel.swift
//  TrackerApp
//
//  Created by Данил on 19/11/2026.
//

import Foundation

protocol TrackersListDelegate: AnyObject {
  func addNewTracker(tracker: Tracker, category: String)
  func updateTracker(updateTracker: Tracker, in: String)
}

enum TrackersUpdate {
  case reload
  case batch(
    deletedSections: [Int],
    insertedSections: [Int],
    deletedItems: [ItemPosition],
    insertedItems: [ItemPosition]
  )
  case reloadItems([ItemPosition])
}

final class TrackersListViewModel {
  // MARK: - Bindings
  var onUpdate: Binding<TrackersUpdate>?
  var onEmptyStateChange: Binding<Bool>?
  
  // MARK: - Properties
  var numberOfSections: Int {
    visibleCategories.count
  }
  
  // MARK: - Private Properties
  private(set) var currentDate: Date = .init()
  private(set) var isFilter: Bool = false
  private(set) var isSearch: Bool = false
  private var searchText: String = ""
  private var categories: [TrackerCategory] = []
  private var completedTrackers: [TrackerRecord] = []
  private var visibleCategories: [TrackerCategory] = []
  private let trackerCategoryStore: TrackerCategoryStoreProtocol
  private let trackerRecordStore: TrackerRecordStoreProtocol
  private let trackerStore: TrackerStoreProtocol
  
  // MARK: - Init
  init(trackerCategoryStore: TrackerCategoryStoreProtocol = TrackerCategoryStore(),
       trackerStore: TrackerStoreProtocol = TrackerStore(),
       trackerRecordStore: TrackerRecordStoreProtocol = TrackerRecordStore()) {
    self.trackerCategoryStore = trackerCategoryStore
    self.trackerStore = trackerStore
    self.trackerRecordStore = trackerRecordStore
    
    self.trackerStore.delegate = self
    self.trackerRecordStore.delegate = self
    self.trackerCategoryStore.delegate = self
  }
  
  // MARK: - Methods
  func viewDidLoad() {
    categories = trackerCategoryStore.categories
    completedTrackers = trackerRecordStore.records
    updateVisibleCategories()
    updateStatistics()
  }
  
  func searchTextDidChange(searchText: String) {
    self.searchText = searchText
    isSearch = !searchText.isEmpty
    updateVisibleCategories()
  }
  
  func currentDateDidChange(date: Date) {
    currentDate = date
    updateVisibleCategories()
  }
  
  func numberOfItems(in section: Int) -> Int {
    visibleCategories[section].trackers.count
  }
  
  func headerTitle(for section: Int) -> String {
    visibleCategories[section].title
  }
  
  func cellModel(position: ItemPosition) -> TrackerCellModel {
    let tracker = visibleCategories[position.section].trackers[position.item]
    
    let daysCount = completedTrackers.filter { $0.trackerId == tracker.id }.count
    return TrackerCellModel(
      name: tracker.name,
      emoji: tracker.emoji,
      count: daysCount,
      hexColor: tracker.hexColor,
      isDone: isDone(with: tracker),
      isPinned: tracker.isPinned
    )
  }
  
  func didTapDone(at position: ItemPosition) {
    let calendar = Calendar.current
    guard calendar.startOfDay(for: currentDate) <= calendar.startOfDay(for: Date()) else { return }
    
    let tracker = visibleCategories[position.section].trackers[position.item]
    let record = TrackerRecord(trackerId: tracker.id, date: currentDate)
    
    do {
      if isDone(with: tracker) {
        try trackerRecordStore.removeTrackerRecord(trackerRecord: record)
      } else {
        try trackerRecordStore.addNewTrackerRecord(trackerRecord: record)
      }
      completedTrackers = trackerRecordStore.records
      updateStatistics()
      let filter = FilterSavingService.shared.savedFilter
      guard filter == .showComplitedTrackers || filter == .showUncomplitedTrackers else {
        onUpdate?(.reloadItems([position]))
        return
      }
      
      let old = visibleCategories
      visibleCategories = makeVisibleCategories()
      onEmptyStateChange?(visibleCategories.isEmpty)
      makeUpdates(old: old, new: visibleCategories).forEach { onUpdate?($0) }
    } catch {
      assertionFailure("Не удалось обновить запись: \(error)")
    }
  }
  
  func getTracker(at position: ItemPosition) -> Tracker {
    visibleCategories[position.section].trackers[position.item]
  }
  
  func getCategory(at position: ItemPosition) -> String {
    let id = visibleCategories[position.section].trackers[position.item].id
    return categories.first { $0.trackers.contains { $0.id == id } }?.title ?? ""
  }
  
  func isAlreadyPinned(at position: ItemPosition) -> Bool {
    visibleCategories[position.section].trackers[position.item].isPinned
  }
  
  func didTapPinnedTracker(on position: ItemPosition) {
    let oldTracker = visibleCategories[position.section].trackers[position.item]
    let updateTracker = Tracker(id: oldTracker.id, name: oldTracker.name, hexColor: oldTracker.hexColor, emoji: oldTracker.emoji, schedule: oldTracker.schedule, isPinned: !oldTracker.isPinned)
    do {
      try trackerStore.pinTracker(updateTracker)
    } catch {
      assertionFailure("Не удалось сохранить трекер: \(error)")
    }
  }
  
  func didTapDeletedTracker(at position: ItemPosition) {
    do {
      try trackerStore.deleteTracker(id: visibleCategories[position.section].trackers[position.item].id)
    } catch {
      assertionFailure("Не удалось сохранить трекер: \(error)")
    }
  }
  
  // MARK: - Private Methods
  private func isDone(with tracker: Tracker) -> Bool {
    completedTrackers.contains {
      $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
    }
  }
  
  private func makeCategoriesForCurrentDate() -> [TrackerCategory] {
    var pinnedTrackers: [Tracker] = []
    var regularCategories: [TrackerCategory] = []
    
    let numberDay = Calendar.current.component(.weekday, from: currentDate)
    guard let currentDay = WeekDay(rawValue: numberDay) else { return [] }
    
    for category in categories {
      var unpinnedTrackers: [Tracker] = []
      
      for tracker in category.trackers {
        guard tracker.schedule.contains(currentDay) else { continue }
        if !tracker.isRegular && isDoneOnAnotherDay(tracker) { continue }
        
        if tracker.isPinned {
          pinnedTrackers.append(tracker)
        } else {
          unpinnedTrackers.append(tracker)
        }
      }
      
      if !unpinnedTrackers.isEmpty {
        regularCategories.append(
          TrackerCategory(title: category.title, trackers: unpinnedTrackers)
        )
      }
    }
    
    if !pinnedTrackers.isEmpty {
      let pinnedCategoryTitle = NSLocalizedString("pinnedCategoryTitle", comment: "")
      let pinnedCategory = TrackerCategory(title: pinnedCategoryTitle, trackers: pinnedTrackers)
      regularCategories.insert(pinnedCategory, at: 0)
    }
    
    return regularCategories
  }
  
  private func isDoneOnAnotherDay(_ tracker: Tracker) -> Bool {
    completedTrackers.contains {
      $0.trackerId == tracker.id && !Calendar.current.isDate($0.date, inSameDayAs: currentDate)
    }
  }
  
  private func makeComplitedTrackers(categories: [TrackerCategory]) -> [TrackerCategory] {
    return categories.compactMap { category in
      let trackers = category.trackers.filter { isDone(with: $0) }
      
      guard !trackers.isEmpty else { return nil }
      
      return TrackerCategory(
        title: category.title,
        trackers: trackers
      )
    }
  }
  
  private func makeUncomplitedTrackers(categories: [TrackerCategory]) -> [TrackerCategory] {
    return categories.compactMap { category in
      let trackers = category.trackers.filter { !isDone(with: $0) }
      
      guard !trackers.isEmpty else { return nil }
      
      return TrackerCategory(
        title: category.title,
        trackers: trackers
      )
    }
  }
  
  private func filterBySearch(_ categories: [TrackerCategory], query: String) -> [TrackerCategory] {
    let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !query.isEmpty else { return categories }
    
    return categories.compactMap { category in
      if category.title.localizedCaseInsensitiveContains(query) {
        return category
      }
      
      let trackers = category.trackers.filter {
        $0.name.localizedCaseInsensitiveContains(query)
      }
      return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
    }
  }
  
  private func makeVisibleCategories() -> [TrackerCategory] {
    var result = filterBySearch(makeCategoriesForCurrentDate(), query: searchText)
    let optionFilter = FilterSavingService.shared.savedFilter
    if optionFilter == .showComplitedTrackers {
      result = makeComplitedTrackers(categories: result)
    } else if optionFilter == .showUncomplitedTrackers {
      result = makeUncomplitedTrackers(categories: result)
    }
    return result
  }
  
  private func updateVisibleCategories() {
    visibleCategories = makeVisibleCategories()
    onUpdate?(.reload)
    onEmptyStateChange?(visibleCategories.isEmpty)
  }
  
  private func updateStatistics() {
    let allTrackers = categories.flatMap(\.trackers)
    StatisticService.shared.update(trackers: allTrackers, records: completedTrackers)
  }
}

// MARK: - TrackerStoreDelegate
extension TrackersListViewModel: TrackerStoreDelegate {
  func trackerStoreDidUpdate() {
    let oldVisible = visibleCategories
    categories = trackerCategoryStore.categories
    visibleCategories = makeVisibleCategories()
    let newVisible = visibleCategories
    onEmptyStateChange?(visibleCategories.isEmpty)
    let updates = makeUpdates(
      old: oldVisible,
      new: newVisible
    )
    completedTrackers = trackerRecordStore.records
    updateStatistics()
    updates.forEach { onUpdate?($0) }
  }
  
  private func makeUpdates(old: [TrackerCategory], new: [TrackerCategory]) -> [TrackersUpdate] {
    let oldTitles = old.map(\.title)
    let newTitles = new.map(\.title)

    let deletedSections = oldTitles.enumerated().compactMap { index, title in
      newTitles.contains(title) ? nil : index
    }

    let insertedSections = newTitles.enumerated().compactMap { index, title in
      oldTitles.contains(title) ? nil : index
    }

    guard oldTitles.filter(newTitles.contains) == newTitles.filter(oldTitles.contains) else {
      return [.reload]
    }

    var deletedItems: [ItemPosition] = []
    var insertedItems: [ItemPosition] = []
    var reloadedItems: [ItemPosition] = []

    for (oldSection, category) in old.enumerated() {
      guard let newSection = newTitles.firstIndex(of: category.title) else { continue }

      let newTrackers = new[newSection].trackers
      let newIDs = Set(newTrackers.map(\.id))
      let oldIDs = Set(category.trackers.map(\.id))

      guard category.trackers.map(\.id).filter(newIDs.contains)
              == newTrackers.map(\.id).filter(oldIDs.contains) else {
        return [.reload]
      }

      for (item, tracker) in category.trackers.enumerated() where !newIDs.contains(tracker.id) {
        deletedItems.append(ItemPosition(section: oldSection, item: item))
      }
    }

    for (newSection, category) in new.enumerated() {
      guard let oldSection = oldTitles.firstIndex(of: category.title) else { continue }

      var oldByID: [UUID: Tracker] = [:]
      for tracker in old[oldSection].trackers { oldByID[tracker.id] = tracker }

      for (item, tracker) in category.trackers.enumerated() {
        if let oldTracker = oldByID[tracker.id] {
          if oldTracker != tracker {
            reloadedItems.append(ItemPosition(section: newSection, item: item))
          }
        } else {
          insertedItems.append(ItemPosition(section: newSection, item: item))
        }
      }
    }

    var updates: [TrackersUpdate] = []
    if !deletedSections.isEmpty || !insertedSections.isEmpty
        || !deletedItems.isEmpty || !insertedItems.isEmpty {
      updates.append(.batch(deletedSections: deletedSections,
                            insertedSections: insertedSections,
                            deletedItems: deletedItems,
                            insertedItems: insertedItems))
    }
    if !reloadedItems.isEmpty {
      updates.append(.reloadItems(reloadedItems))
    }
    return updates
  }
}

// MARK: - TrackerRecordStoreDelegate
extension TrackersListViewModel: TrackerRecordStoreDelegate {
  func trackerRecordStoreDidUpdate() {
  }
}

// MARK: - TrackerCategoryStoreDelegate
extension TrackersListViewModel: TrackerCategoryStoreDelegate {
  func trackerCategoryStoreDidUpdate() {
  }
}

// MARK: - TrackersListDelegate
extension TrackersListViewModel: TrackersListDelegate {
  func updateTracker(updateTracker: Tracker, in category: String) {
    do {
      try trackerStore.updateTracker(updateTracker, in: category)
    } catch {
      assertionFailure("Не удалось сохранить трекер: \(error)")
    }
  }
  
  func addNewTracker(tracker: Tracker, category: String) {
    do {
      try trackerStore.addNewTracker(with: tracker, to: category)
    } catch {
      assertionFailure("Не удалось сохранить трекер: \(error)")
    }
  }
}

// MARK: - FilteredDelegate
extension TrackersListViewModel: FilteredDelegate {
  func filterTrackers(filterOption: FilterOption = .showAllTrackers) {
    switch filterOption {
      case .showAllTrackers:
        isFilter = false
      case .showTodayTrackers:
        isFilter = false
        currentDate = Date()
      case .showComplitedTrackers:
        isFilter = true
      case .showUncomplitedTrackers:
        isFilter = true
    }
    updateVisibleCategories()
  }
}
