//
//  AnaliticService.swift
//  TrackerApp
//
//  Created by Данил on 25/11/2026.
//

import AppMetricaCore

enum AnalyticsScreenName: String {
  case trackersList = "trackers-list"
  case filter = "filter"
  case trackerEditor = "tracker-editor"
  case categoryEditor = "category-editor"
  case categorySelection = "category-selection"
  case categorySchedule = "schedule-selection"
  case statistics = "statistics"
  case onboarding = "onboarding"
}

enum AnalyticsEvent: String {
  case open = "open"
  case close = "close"
  case click = "click"
}

enum AnalyticsItem: String {
  case addTrack = "add_track"
  case track = "track"
  case filter = "filter"
  case edit = "edit"
  case delete = "delete"
}

final class AnaliticService {
  static let shared: AnaliticService = .init()
  
  private init() {}
  
  func activateAnaliticService() {
    if let configuration = AppMetricaConfiguration(apiKey: "3b5b5162-6a3a-45a7-a962-7ca7e40bd936") {
      AppMetrica.activate(with: configuration)
    }
  }
  
  func sendReport(event: AnalyticsEvent, screen: AnalyticsScreenName, item: AnalyticsItem? = nil) {
    var parameters: [String: Any] = ["event": event.rawValue, "screen": screen.rawValue]
    if let item {
      parameters["item"] = item.rawValue
    }
    AppMetrica.reportEvent(name: event.rawValue, parameters: parameters, onFailure: nil)
  }
}
