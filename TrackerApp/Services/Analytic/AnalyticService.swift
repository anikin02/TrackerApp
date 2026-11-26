//
//  AnaliticService.swift
//  TrackerApp
//
//  Created by Данил on 25/11/2026.
//

import AppMetricaCore

enum AnalyticsScreenName: String {
  case trackersList = "trackers_list"
  case filter = "filter"
  case typeSelection = "type_selection"
  case trackerEditor = "tracker_editor"
  case categoryEditor = "category_editor"
  case categorySelection = "category_selection"
  case scheduleSelection = "schedule_selection"
  case statistics = "statistics"
  case onboarding = "onboarding"
}

enum AnalyticsEvent: String {
  case open = "open"
  case close = "close"
  case click = "click"
}

enum AnalyticsItem: String {
  case addTracker = "add_tracker"
  case track = "track"
  case filter = "filter"
  case editTracker = "edit_tacker"
  case deleteTracker = "delete_tacker"
  case pinTracker = "pin_tracker"
  
  case filterOption = "filter_option"
  
  case selectRegularTracker = "select_regular_tracker"
  case selectUnregularTracker = "select_unregular_tracker"
  
  case cancel = "cancel"
  case save = "save"
  
  case addCategory = "add_category"
  case selectCategory = "select_category"
  case deleteCategory = "delete_category"
  case editCategory = "edit_category"
}

final class AnalyticsService {
  static let shared: AnalyticsService = .init()
  
  private init() {}
  
  func activateAnalyticsService() {
    guard let key = Bundle.main.object(forInfoDictionaryKey: "AnalyticsAPIKey") as? String,
          !key.isEmpty else {
      fatalError("AnalyticsAPIKey не найден в Info.plist")
    }
    if let configuration = AppMetricaConfiguration(apiKey: key) {
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
