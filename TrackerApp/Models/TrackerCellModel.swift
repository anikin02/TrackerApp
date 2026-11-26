//
//  CellModel.swift
//  TrackerApp
//
//  Created by Данил on 07/11/2026.
//

import Foundation

struct TrackerCellModel {
  let name: String
  let emoji: String
  let count: Int
  let hexColor: String
  let isDone: Bool
  let isPinned: Bool
  
  var daysCountText: String {
    String.localizedStringWithFormat(
      NSLocalizedString("daysCount", comment: ""),
      count
    )
  }
}
