//
//  StatisticsServiceSpy.swift
//  TrackerApp
//
//  Created by Данил on 25/11/2026.
//

@testable import TrackerApp
import Foundation

final class StatisticsServiceSpy: StatisticServiceProtocol {
  var countComplitedTrackers: Int
  var bestRange: Int
  var countBestDays: Int
  var averageComplitedTrackers: Int
  
  init(countComplitedTrackers: Int, bestRange: Int, countBestDays: Int, averageComplitedTrackers: Int) {
    self.countComplitedTrackers = countComplitedTrackers
    self.bestRange = bestRange
    self.countBestDays = countBestDays
    self.averageComplitedTrackers = averageComplitedTrackers
  }
  
  func update(trackers: [TrackerApp.Tracker], records: [TrackerApp.TrackerRecord]) {}
}
