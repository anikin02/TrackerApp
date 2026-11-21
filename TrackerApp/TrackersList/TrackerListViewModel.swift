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
  
  private(set) var currentDate: Date = .init()
  private var searchText: String = ""
  private var categories: [TrackerCategory] = []
  private var completedTrackers: [TrackerRecord] = []
  private var visibleCategories: [TrackerCategory] = []
  private let trackerCategoryStore: TrackerCategoryStore = .init()
  private let trackerRecordStore: TrackerRecordStore = .init()
  private let trackerStore: TrackerStore = .init()
  
  init() {
    trackerStore.delegate = self
    trackerRecordStore.delegate = self
    trackerCategoryStore.delegate = self
  }
  
  func viewDidLoad() {
    categories = trackerCategoryStore.categories
    completedTrackers = trackerRecordStore.records
    updateVisibleCategories()
  }
  
  func searchTextDidChange(searchText: String) {
    self.searchText = searchText
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
      onUpdate?(.reloadItems([position]))
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
      let pinnedCategory = TrackerCategory(title: "Закрепленные", trackers: pinnedTrackers)
      regularCategories.insert(pinnedCategory, at: 0)
    }
    
    return regularCategories
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
  
  private func updateVisibleCategories() {
    visibleCategories = filterBySearch(makeCategoriesForCurrentDate(), query: searchText)
    
    onUpdate?(.reload)
    onEmptyStateChange?(visibleCategories.isEmpty)
  }
}

// MARK: - TrackerStoreDelegate
extension TrackersListViewModel: TrackerStoreDelegate {
  func trackerStoreDidUpdate() {
    let oldVisible = visibleCategories
    
    categories = trackerCategoryStore.categories
    
    let newVisible = filterBySearch(
      makeCategoriesForCurrentDate(),
      query: searchText
    )
    
    visibleCategories = newVisible
    
    onEmptyStateChange?(visibleCategories.isEmpty)
    
    let updates = makeUpdates(
      old: oldVisible,
      new: newVisible
    )
    
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
    
    let oldCommon = oldTitles.filter { newTitles.contains($0) }
    let newCommon = newTitles.filter { oldTitles.contains($0) }
    
    guard oldCommon == newCommon else {
      return [.reload]
    }
    
    var deletedItems: [ItemPosition] = []
    var insertedItems: [ItemPosition] = []
    var reloadedItems: [ItemPosition] = []
    
    for (section, category) in old.enumerated() {
      guard let newSection = newTitles.firstIndex(of: category.title) else {
        continue
      }
      
      let newTrackers = new[newSection].trackers
      let newIDs = Set(newTrackers.map(\.id))
      let oldIDs = Set(category.trackers.map(\.id))
      
      let oldCommonIDs = category.trackers.map(\.id).filter { newIDs.contains($0) }
      let newCommonIDs = newTrackers.map(\.id).filter { oldIDs.contains($0) }
      guard oldCommonIDs == newCommonIDs else {
        return [.reload]
      }
      
      for (item, tracker) in category.trackers.enumerated() {
        if let updated = newTrackers.first(where: { $0.id == tracker.id }) {
          if updated != tracker {
            reloadedItems.append(ItemPosition(section: section, item: item))
          }
        } else {
          deletedItems.append(ItemPosition(section: section, item: item))
        }
      }
    }
    
    for (section, category) in new.enumerated() {
      guard let oldSection = oldTitles.firstIndex(of: category.title) else {
        continue
      }
      let oldIDs = Set(old[oldSection].trackers.map(\.id))
      for (item, tracker) in category.trackers.enumerated() where !oldIDs.contains(tracker.id) {
        insertedItems.append(ItemPosition(section: section, item: item))
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
    // TODO: Пока не уверен, что нужно, так как не хочется перерисовывать всю коллекцию
  }
}

// MARK: - TrackerCategoryStoreDelegate
extension TrackersListViewModel: TrackerCategoryStoreDelegate {
  func trackerCategoryStoreDidUpdate() {
    // TODO: Скорее всегго понадоиться при удалении категории
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
