//
//  StatisticsViewModel.swift
//  TrackerApp
//
//  Created by Данил on 23/11/2026.
//

import Foundation

final class StatisticsViewModel {
  // MARK: - Bindings
  var onEmptyStateChange: Binding<Bool>?
  
  // MARK: - Properties
  var numberOfRows: Int {
    StatisticsOption.sortedByRawValue.count
  }
  
  // MARK: - Private Properties
  private let service: StatisticServiceProtocol
  private var statistics: [StatisticsOption : Int] = [
    .bestRange : 0,
    .countBestDays : 0,
    .countComplitedTrackers : 0,
    .averageComplitedTrackers : 0
  ]
  
  enum StatisticsOption: Int, CaseIterable {
    case bestRange = 0
    case countBestDays = 1
    case countComplitedTrackers = 2
    case averageComplitedTrackers = 3
    
    var title: String {
      switch self {
        case .countComplitedTrackers:
          return NSLocalizedString("completedTrackersStatTitle", comment: "")
        case .bestRange:
          return NSLocalizedString("bestPeriodStatTitle", comment: "")
        case .countBestDays:
          return NSLocalizedString("perfectDaysStatTitle", comment: "")
        case .averageComplitedTrackers:
          return NSLocalizedString("averageValueStatTitle", comment: "")
      }
    }
    
    static var sortedByRawValue: [StatisticsOption] {
      allCases.sorted { $0.rawValue < $1.rawValue }
    }
  }
  
  init(service: StatisticServiceProtocol = StatisticService.shared) {
    self.service = service
  }
  
  func viewWillAppear() {
    updateStatistics()
  }
  
  func makeModel(at index: Int) -> StatisticsCellModel {
    let option = StatisticsOption.sortedByRawValue[index]
    return StatisticsCellModel(title: option.title,
                               amount: statistics[option] ?? 0)
  }
  
  private func updateStatistics() {
    statistics[.bestRange] = service.bestRange
    statistics[.countBestDays] = service.countBestDays
    statistics[.countComplitedTrackers] = service.countCompletedTrackers
    statistics[.averageComplitedTrackers] = service.averageComplitedTrackers
    
    
    onEmptyStateChange?(statistics[.countComplitedTrackers] == 0)
  }
}
