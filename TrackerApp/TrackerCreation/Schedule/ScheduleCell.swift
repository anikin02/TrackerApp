//
//  ScheduleCell.swift
//  TrackerApp
//
//  Created by Данил on 08/11/2026.
//

import UIKit

final class ScheduleCell: UITableViewCell {
  static let identifier = "ScheduleCell"
  
  private let switchControl = UISwitch()
  var onToggle: ((Bool) -> Void)?
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    backgroundColor = .clear
    selectionStyle = .none
    textLabel?.font = .systemFont(ofSize: 17)
    textLabel?.textColor = .blackYP
    
    switchControl.onTintColor = .blueYP
    switchControl.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
    accessoryView = switchControl
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  func configCell(title: String, isOn: Bool) {
    textLabel?.text = title
    switchControl.isOn = isOn
  }
  
  @objc private func switchChanged() {
    onToggle?(switchControl.isOn)
  }
}
