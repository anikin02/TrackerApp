//
//  TrackerHeaderView.swift
//  TrackerApp
//
//  Created by Данил on 07/11/2026.
//

import UIKit

final class TrackerHeaderView: UICollectionReusableView {
  static let reuseIdentifier = "TrackerHeaderView"
  private let titleLabel: UILabel = .init()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configTitle()
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  func configHeader(title: String) {
    titleLabel.text = title
  }
  
  private func configTitle() {
    titleLabel.font = .systemFont(ofSize: 19, weight: .bold)
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    addSubview(titleLabel)
    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
      titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
      titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
      titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
    ])
  }
}
