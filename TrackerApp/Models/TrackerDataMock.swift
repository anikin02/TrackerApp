//
//  TrackerDataMock.swift
//  TrackerApp
//
//  Created by Данил on 05/11/2026.
//

import Foundation

enum TrackerDataMock {
  static let water = Tracker(
    id: UUID(),
    name: "Пить воду",
    hexColor: HexColorSection.color1.rawValue,
    emoji: "☺️",
    schedule: Set(WeekDay.allCases)
  )
  static let workout = Tracker(
    id: UUID(),
    name: "Тренировка",
    hexColor: HexColorSection.color2.rawValue,
    emoji: "🐯",
    schedule: [.monday, .wednesday, .friday]
  )
  static let reading = Tracker(
    id: UUID(),
    name: "Чтение книги",
    hexColor: HexColorSection.color3.rawValue,
    emoji: "🍎",
    schedule: [.tuesday, .thursday, .saturday]
  )
  static let cleaning = Tracker(
    id: UUID(),
    name: "Убрать квартиру",
    hexColor: HexColorSection.color4.rawValue,
    emoji: "🍎",
    schedule: [.saturday]
  )
  static let cooking = Tracker(
    id: UUID(),
    name: "Приготовить еду",
    hexColor: HexColorSection.color5.rawValue,
    emoji: "🍎",
    schedule: [.sunday, .wednesday]
  )
  static let cat = Tracker(
    id: UUID(),
    name: "Кошка заслонила камеру на созвоне",
    hexColor: HexColorSection.color6.rawValue,
    emoji: "🐱",
    schedule: [.monday]
  )
  static let tickets = Tracker(
    id: UUID(),
    name: "Купить билеты",
    hexColor: HexColorSection.color7.rawValue,
    emoji: "🍕",
    schedule: Set(WeekDay.allCases),
    isRegular: false
  )
  static let categories: [TrackerCategory] = [
    TrackerCategory(title: "Здоровье", trackers: [water, workout]),
    TrackerCategory(title: "Саморазвитие", trackers: [reading]),
    TrackerCategory(title: "Радостные мелочи", trackers: [cat]),
    TrackerCategory(title: "Дела", trackers: [tickets, cleaning, cooking])
  ]
  static let completedTrackers: [TrackerRecord] = {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
    let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!

    return [
      TrackerRecord(trackerId: water.id, date: today),
      TrackerRecord(trackerId: water.id, date: yesterday),
      TrackerRecord(trackerId: water.id, date: twoDaysAgo),
      TrackerRecord(trackerId: workout.id, date: yesterday),
      TrackerRecord(trackerId: reading.id, date: twoDaysAgo)
    ]
  }()
}
