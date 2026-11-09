//
//  UIColor.swift
//  TrackerApp
//
//  Created by Данил on 06/11/2026.
//

import UIKit

extension UIColor {
  convenience init?(hex: String, alpha: CGFloat = 1) {
    var string = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    if string.hasPrefix("#") { string.removeFirst() }
    
    guard string.count == 6, let value = Int(string, radix: 16) else { return nil }
    
    self.init(
      red: CGFloat((value >> 16) & 0xFF) / 255,
      green: CGFloat((value >> 8) & 0xFF) / 255,
      blue: CGFloat(value & 0xFF) / 255,
      alpha: alpha
    )
  }
}
