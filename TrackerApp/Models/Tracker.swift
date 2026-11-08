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
