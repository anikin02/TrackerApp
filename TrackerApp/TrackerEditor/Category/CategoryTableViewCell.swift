//
//  CategoryTableViewCell.swift
//  TrackerApp
//
//  Created by Данил on 17/11/2026.
//

import UIKit

final class CategoryTableViewCell: UITableViewCell {
  static let reuseIdentifier = "CategoryCell"
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .default, reuseIdentifier: reuseIdentifier)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configureCell(with model: CategoryCellModel) {
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
