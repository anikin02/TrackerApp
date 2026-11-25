//
//  StatisticService.swift
//  TrackerApp
//
//  Created by Данил on 21/11/2026.
//

import Foundation

protocol StatisticServiceProtocol {
  var countComplitedTrackers: Int {get set}
  var bestRange: Int {get set}
  var countBestDays: Int {get set}
  var averageComplitedTrackers: Int {get set}
  func update(trackers: [Tracker], records: [TrackerRecord])
}

final class StatisticService: StatisticServiceProtocol {
  static let shared = StatisticService()
  
  private let defaults = UserDefaults.standard
  private enum Key {
    static let countComplitedTrackers = "countComplitedTrackers"
    static let bestRange = "bestRange"
    static let countBestDays = "countBestDays"
    static let averageComplitedTrackers = "averageComplitedTrackers"
  }
  
  private init() {}
  
  var countComplitedTrackers: Int {
    get {
      defaults.integer(forKey: Key.countComplitedTrackers)
    }
    set {
      defaults.set(newValue, forKey: Key.countComplitedTrackers)
    }
  }
  
  var bestRange: Int {
    get {
      defaults.integer(forKey: Key.bestRange)
    }
    set {
      defaults.set(newValue, forKey: Key.bestRange)
    }
  }
  
  var countBestDays: Int {
    get {
      defaults.integer(forKey: Key.countBestDays)
    }
    set {
      defaults.set(newValue, forKey: Key.countBestDays)
    }
  }
  
  var averageComplitedTrackers: Int {
    get {
      defaults.integer(forKey: Key.averageComplitedTrackers)
    }
    set {
      defaults.set(newValue, forKey: Key.averageComplitedTrackers)
    }
  }
  
  func update(trackers: [Tracker], records: [TrackerRecord]) {
    let calendar = Calendar.current
    countComplitedTrackers = records.count

    guard !records.isEmpty else {
      bestRange = 0
      countBestDays = 0
      averageComplitedTrackers = 0
      return
    }

    var doneByDay: [Date: Set<UUID>] = [:]
    for record in records {
      let day = calendar.startOfDay(for: record.date)
      doneByDay[day, default: []].insert(record.trackerId)
    }

    let regularTrackers = trackers.filter(\.isRegular)

    let doneIDs = Set(records.map(\.trackerId))
    let pendingIrregularIDs = Set(
      trackers.filter { !$0.isRegular && !doneIDs.contains($0.id) }.map(\.id)
    )

    let today = calendar.startOfDay(for: Date())
    guard let firstDay = doneByDay.keys.min() else { return }

    var day = firstDay
    var totalDays = 0
    var perfectDays = 0
    var bestStreak = 0
    var currentStreak = 0

    while day <= today {
      totalDays += 1
      let done = doneByDay[day] ?? []

      var scheduled: Set<UUID> = pendingIrregularIDs
      if let weekday = WeekDay(rawValue: calendar.component(.weekday, from: day)) {
        for tracker in regularTrackers where tracker.schedule.contains(weekday) {
          scheduled.insert(tracker.id)
        }
      }

      if !(scheduled.isEmpty && done.isEmpty) {
        if scheduled.isSubset(of: done) {
          perfectDays += 1
          currentStreak += 1
          bestStreak = max(bestStreak, currentStreak)
        } else if day != today {
          currentStreak = 0
        }
      }

      guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
      day = next
    }

    bestRange = bestStreak
    countBestDays = perfectDays
    averageComplitedTrackers = Int((Double(records.count) / Double(totalDays)).rounded())
  }
}
