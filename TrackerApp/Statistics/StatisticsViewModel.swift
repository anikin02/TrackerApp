//
//  StatisticsViewModel.swift
//  TrackerApp
//
//  Created by Данил on 23/11/2026.
//


final class StatisticsViewModel {
  // MARK: - Bindings
  var onEmptyStateChange: Binding<Bool>?
  
  // MARK: - Properties
  var numberOfRows: Int {
    StatisticsOption.sortedByRawValue.count
  }
  
  // MARK: - Private Properties
  private let service: StatisticService = .shared
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
          return "Трекеров завершено"
        case .bestRange:
          return "Лучший период"
        case .countBestDays:
          return "Идеальные дни"
        case .averageComplitedTrackers:
          return "Среднее значение"
      }
    }
    
    static var sortedByRawValue: [StatisticsOption] {
      allCases.sorted { $0.rawValue < $1.rawValue }
    }
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
    statistics[.countComplitedTrackers] = service.countComplitedTrackers
    statistics[.averageComplitedTrackers] = service.averageComplitedTrackers
    
    
    onEmptyStateChange?(statistics[.countComplitedTrackers] == 0)
  }
}
