//
//  TrackersListViewModel.swift
//  TrackerApp
//
//  Created by Данил on 19/11/2026.
//

import Foundation

protocol TrackersListDelegate: AnyObject {
  func addNewTracker(tracker: Tracker, category: String)
}

enum TrackersUpdate {
  case reload
  case insert(sections: [Int], items: [ItemPosition])
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
      isDone: isDone(with: tracker)
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
  
  private func isDone(with tracker: Tracker) -> Bool {
    completedTrackers.contains {
      $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
    }
  }
  
  private func getDateCategories() -> [TrackerCategory] {
    var result: [TrackerCategory] = []
    
    for category in categories {
      let title = category.title
      var trackers: [Tracker] = []
      
      for tracker in category.trackers {
        let numberDay = Calendar.current.component(.weekday, from: currentDate)
        if let day = WeekDay(rawValue: numberDay),
           tracker.schedule.contains(day){
          trackers.append(tracker)
        }
      }
      if !trackers.isEmpty {
        result.append(TrackerCategory(title: title, trackers: trackers))
      }
    }
    return result
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
    visibleCategories = filterBySearch(getDateCategories(), query: searchText)
    onUpdate?(.reload)
    onEmptyStateChange?(visibleCategories.isEmpty)
  }
}

// MARK: - TrackerStoreDelegate
extension TrackersListViewModel: TrackerStoreDelegate {
  func trackerStoreDidUpdate() {
    let oldVisible = visibleCategories
    
    categories = trackerCategoryStore.categories
    let newVisible = filterBySearch(getDateCategories(), query: searchText)
    visibleCategories = newVisible
    onEmptyStateChange?(visibleCategories.isEmpty)
    
    var insertedSections: [Int] = []
    var insertedItems: [ItemPosition] = []
    
    for (section, category) in visibleCategories.enumerated() {
      if let old = oldVisible.first(where: { $0.title == category.title }) {
        let oldIds = Set(old.trackers.map(\.id))
        for (item, tracker) in category.trackers.enumerated() where !oldIds.contains(tracker.id) {
          insertedItems.append(ItemPosition(section: section, item: item))
        }
      } else {
        insertedSections.append(section)
      }
    }
    
    let oldCount = oldVisible.reduce(0) { $0 + $1.trackers.count }
    let newCount = visibleCategories.reduce(0) { $0 + $1.trackers.count }
    let insertedInNewSections = insertedSections.reduce(0) { $0 + visibleCategories[$1].trackers.count }
    let isPureInsert = oldVisible.count + insertedSections.count == visibleCategories.count
    && oldCount + insertedItems.count + insertedInNewSections == newCount
    
    guard isPureInsert else {
      onUpdate?(.reload)
      return
    }
    guard !insertedSections.isEmpty || !insertedItems.isEmpty else { return }
    onUpdate?(.insert(sections: insertedSections, items: insertedItems))
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
