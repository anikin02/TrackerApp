//
//  ScheduleSelectionViewModel.swift
//  TrackerApp
//
//  Created by Данил on 18/11/2026.
//

import Foundation

final class ScheduleSelectionViewModel {
  var numberOfRows: Int { days.count }
  var onScheduleConfirmed: Binding<Set<WeekDay>>?
  
  private var selectedDays: Set<WeekDay>
  private let days = WeekDay.orderedWeek
  
  init(selectedDays: Set<WeekDay> = []) {
    self.selectedDays = selectedDays
  }
  
  func cellViewModel(at index: Int) -> ScheduleCellModel {
    let day = days[index]
    return ScheduleCellModel(title: day.title,
                             selected: selectedDays.contains(day))
  }
  
  func isLastRow(at index: Int) -> Bool {
    index == days.count - 1
  }
  
  func didToggle(at index: Int, isOn: Bool) {
    let day = days[index]
    if isOn {
      selectedDays.insert(day)
    } else {
      selectedDays.remove(day)
    }
  }
  
  func didTapDone() {
    onScheduleConfirmed?(selectedDays)
  }
}
