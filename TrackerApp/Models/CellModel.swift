//
//  CellModel.swift
//  TrackerApp
//
//  Created by Данил on 07/11/2026.
//

struct CellModel {
  let name: String
  let emoji: String
  let count: Int
  let hexColor: String
  let isDone: Bool
  
  var stringCount: String {
    let format: String
    let mod10 = count % 10
    let mod100 = count % 100
    
    if mod100 >= 11 && mod100 <= 19 {
      format = "дней"
    } else {
      switch mod10 {
        case 1:      format = "день"
        case 2, 3, 4: format = "дня"
        default:     format = "дней"
      }
    }
    
    return "\(count) \(format)"
  }
}
