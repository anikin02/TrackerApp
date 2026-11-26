//
//  EmojiCell.swift
//  TrackerApp
//
//  Created by Данил on 11/11/2026.
//

import UIKit

final class EmojiCell: UICollectionViewCell {
  static let reuseIdentifier: String = "EmojiCell"
  let emojiLabel: UILabel = .init()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureEmojiLabel()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configureCell(with emoji: String, isSelected: Bool) {
    emojiLabel.text = emoji
    backgroundColor = isSelected ? .lightGrayYP: .clear
  }
  
  private func configureEmojiLabel() {
    emojiLabel.translatesAutoresizingMaskIntoConstraints = false
    emojiLabel.textAlignment = .center
    emojiLabel.font = .systemFont(ofSize: 32, weight: .bold)
    layer.cornerRadius = 16
    addSubview(emojiLabel)
    
    NSLayoutConstraint.activate([
      emojiLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
      emojiLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
  }
}
