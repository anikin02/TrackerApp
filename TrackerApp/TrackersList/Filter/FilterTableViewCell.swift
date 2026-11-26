//
//  FilterTableViewCell.swift
//  TrackerApp
//
//  Created by Данил on 21/11/2026.
//

import UIKit

final class FilterTableViewCell: UITableViewCell {
  static let reuseIdentifier = "FilterCell"
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .default, reuseIdentifier: reuseIdentifier)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configureCell(with model: FilterCellModel) {
    textLabel?.text = model.title
    accessoryType = model.isSelected ? .checkmark : .none
  }
  
  private func configureUI() {
    textLabel?.font = .systemFont(ofSize: 17)
    textLabel?.textColor = .blackYP
    backgroundColor = .clear
    selectionStyle = .none
    tintColor = .blueYP
  }
}
