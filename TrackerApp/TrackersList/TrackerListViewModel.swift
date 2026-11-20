//
//  TrackersListViewModel.swift
//  TrackerApp
//
//  Created by Данил on 19/11/2026.
//

import Foundation

protocol TrackersListDelegate: AnyObject {
  func addNewTracker(tracker: Tracker, category: String)
  func changeTracker(newTracker: Tracker, category: String)
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
  
  func isAlreadyPinned(at position: ItemPosition) -> Bool {
    visibleCategories[position.section].trackers[position.item].isPinned
  }
  
  func didTapPinnedTracker(on position: ItemPosition) {
    let category = visibleCategories[position.section].title
    let oldTracker = visibleCategories[position.section].trackers[position.item]
    let updateTracker = Tracker(id: oldTracker.id, name: oldTracker.name, hexColor: oldTracker.hexColor, emoji: oldTracker.emoji, schedule: oldTracker.schedule, isPinned: !oldTracker.isPinned)
    do {
      try trackerStore.pinTracker(updateTracker)
    } catch {
      assertionFailure("Не удалось сохранить трекер: \(error)")
    }
  }
  
  func didTapEditedTracker(on position: ItemPosition, newTracker: Tracker) {
    
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
    
    let update = makeUpdate(
      old: oldVisible,
      new: newVisible
    )
    
    onUpdate?(update)
  }
  
  private func makeUpdate(old: [TrackerCategory], new: [TrackerCategory]) -> TrackersUpdate {
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
      return .reload
    }
    
    var deletedItems: [ItemPosition] = []
    var insertedItems: [ItemPosition] = []
    
    for (section, category) in old.enumerated() {
      guard let newSection = newTitles.firstIndex(of: category.title) else {
        continue
      }
      
      let newCategory = new[newSection]
      
      let newIDs = Set(newCategory.trackers.map(\.id))
      
      for (item, tracker) in category.trackers.enumerated() {
        if !newIDs.contains(tracker.id) {
          deletedItems.append(
            ItemPosition(section: section, item: item)
          )
        }
      }
    }
    
    for (section, category) in new.enumerated() {
      guard let oldSection = oldTitles.firstIndex(of: category.title) else {
        continue
      }
      
      let oldCategory = old[oldSection]
      
      let oldIDs = Set(oldCategory.trackers.map(\.id))
      
      for (item, tracker) in category.trackers.enumerated() {
        if !oldIDs.contains(tracker.id) {
          insertedItems.append(
            ItemPosition(section: section, item: item)
          )
        }
      }
    }
    
    return .batch(
      deletedSections: deletedSections,
      insertedSections: insertedSections,
      deletedItems: deletedItems,
      insertedItems: insertedItems
    )
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
  func addNewTracker(tracker: Tracker, category: String) {
    do {
      try trackerStore.addNewTracker(with: tracker, to: category)
    } catch {
      assertionFailure("Не удалось сохранить трекер: \(error)")
    }
  }
}
