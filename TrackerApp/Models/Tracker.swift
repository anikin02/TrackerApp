//
//  Tracker.swift
//  TrackerApp
//
//  Created by Данил on 05/11/2026.
//

import Foundation

struct Tracker {
  let id: UUID
  let name: String
  let hexColor: String
  let emoji: String
  let schedule: Set<WeekDay>
  let isRegular: Bool
  
  init(id: UUID, name: String, hexColor: String, emoji: String, schedule: Set<WeekDay>, isRegular: Bool = true) {
    self.id = id
    self.name = name
    self.hexColor = hexColor
    self.emoji = emoji
    self.schedule = schedule
    self.isRegular = isRegular
  }
}

enum WeekDay: Int, CaseIterable {
  case sunday = 1
  case monday = 2
  case tuesday = 3
  case wednesday = 4
  case thursday = 5
  case friday = 6
  case saturday = 7
}
