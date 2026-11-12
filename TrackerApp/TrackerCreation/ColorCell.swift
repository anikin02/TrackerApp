//
//  ColorCell.swift
//  TrackerApp
//
//  Created by Данил on 11/11/2026.
//

import UIKit

final class ColorCell: UICollectionViewCell {
  
  static let reuseIdentifier: String = "ColorCell"
  private let colorView = UIView()
  private let selectionRing = UIView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    configureColorView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configureCell(with color: UIColor, isSelected: Bool) {
    colorView.backgroundColor = color
    selectionRing.layer.borderColor = isSelected ? color.withAlphaComponent(0.3).cgColor : UIColor.clear.cgColor
  }
  
  private func configureColorView() {
    colorView.translatesAutoresizingMaskIntoConstraints = false
    selectionRing.translatesAutoresizingMaskIntoConstraints = false
    colorView.layer.cornerRadius = 8
    selectionRing.layer.cornerRadius = 8
    selectionRing.layer.borderWidth = 3
    contentView.addSubview(selectionRing)
    contentView.addSubview(colorView)
    
    NSLayoutConstraint.activate([
      selectionRing.topAnchor.constraint(equalTo: contentView.topAnchor),
      selectionRing.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      selectionRing.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      selectionRing.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

      colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
      colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
      colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
      colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
    ])
  }
}
