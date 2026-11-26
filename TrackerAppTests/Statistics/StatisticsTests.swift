//
//  StatisticsTests.swift
//  TrackerApp
//
//  Created by Данил on 24/11/2026.
//

import XCTest
import SnapshotTesting
@testable import TrackerApp

final class StatisticsTests: XCTestCase {
  // MARK: - Empty State
  func testEmptyStatistics() {
    let viewModel = makeViewModel(countComplitedTrackers: 0, bestRange: 0, countBestDays: 0, averageComplitedTrackers: 0)
    let vc = StatisticsViewController(viewModel: viewModel)
    
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
  }
  
  // MARK: - Statistics
  func testStatistics() {
    let viewModel = makeViewModel(countComplitedTrackers: 1, bestRange: 1, countBestDays: 1, averageComplitedTrackers: 1)
    let vc = StatisticsViewController(viewModel: viewModel)
    
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
  }
  
  private func makeViewModel(countComplitedTrackers: Int,
                             bestRange: Int,
                             countBestDays: Int,
                             averageComplitedTrackers: Int) -> StatisticsViewModel {
    let service = StatisticsServiceSpy(countComplitedTrackers: countComplitedTrackers,
                                       bestRange: bestRange,
                                       countBestDays: countBestDays,
                                       averageComplitedTrackers: averageComplitedTrackers)
    return StatisticsViewModel(service: service)
  }
}
