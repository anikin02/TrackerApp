//
//  TrackerViewCell.swift
//  TrackerApp
//
//  Created by Данил on 06/11/2026.
//

import UIKit

final class TrackerViewCell: UICollectionViewCell {
  static let reuseIdentifier = "TrackerViewCell"
  weak var delegate: TrackerCellDelegate?
  
  //MARK: - UI Elements
  private let bottomStack: UIStackView = .init()
  private let rootStack: UIStackView = .init()
  private let nameLabel: UILabel = .init()
  private let emojiLabel: UILabel = .init()
  private let countLabel: UILabel = .init()
  private let doneButton: UIButton = .init()
  
  //MARK: - Properties
  private var isDone: Bool = false
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configureCell(with model: TrackerCellModel) {
    nameLabel.text = model.name
    emojiLabel.text = model.emoji
    countLabel.text = model.daysCountText
    
    rootStack.backgroundColor = UIColor(hex: model.hexColor)
    
    isDone = model.isDone
    doneButton.tintColor = UIColor(hex: model.hexColor)
    doneButton.backgroundColor = .whiteYP
    
    setStateDoneButton()
  }
  
  private func configureUI() {
    configureRootStack()
    configureBottomStack()
  }
  
  private func configureRootStack() {
    rootStack.translatesAutoresizingMaskIntoConstraints = false
    rootStack.axis = .vertical
    rootStack.spacing = 8
    rootStack.alignment = .leading
    rootStack.distribution = .equalSpacing
    rootStack.layer.cornerRadius = 16
    rootStack.layer.masksToBounds = true
    rootStack.isLayoutMarginsRelativeArrangement = true
    rootStack.layoutMargins = .init(top: 12, left: 12, bottom: 12, right: 12)
    
    configureEmojiLabel()
    configureNameLabel()
    
    contentView.addSubview(rootStack)
    
    NSLayoutConstraint.activate([
      rootStack.topAnchor.constraint(equalTo: contentView.topAnchor),
      rootStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      rootStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      rootStack.heightAnchor.constraint(equalToConstant: 90)
    ])
  }
  
  private func configureEmojiLabel() {
    emojiLabel.font = .systemFont(ofSize: 14, weight: .medium)
    emojiLabel.textAlignment = .center
    emojiLabel.backgroundColor = UIColor.white.withAlphaComponent(0.3)
    emojiLabel.layer.cornerRadius = 12
    emojiLabel.layer.masksToBounds = true
    emojiLabel.translatesAutoresizingMaskIntoConstraints = false
    
    rootStack.addArrangedSubview(emojiLabel)
    
    NSLayoutConstraint.activate([
      emojiLabel.widthAnchor.constraint(equalToConstant: 24),
      emojiLabel.heightAnchor.constraint(equalToConstant: 24)
    ])
  }
  
  private func configureNameLabel() {
    nameLabel.font = .systemFont(ofSize: 12, weight: .medium)
    nameLabel.textColor = .whiteYP
    nameLabel.numberOfLines = 0
    rootStack.addArrangedSubview(nameLabel)
  }
  
  private func configureBottomStack() {
    bottomStack.translatesAutoresizingMaskIntoConstraints = false
    bottomStack.axis = .horizontal
    bottomStack.spacing = 8
    bottomStack.alignment = .leading
    bottomStack.distribution = .equalSpacing
    bottomStack.isLayoutMarginsRelativeArrangement = true
    bottomStack.layoutMargins = .init(top: 8, left: 12, bottom: 16, right: 12)
    
    configureCountLabel()
    configureDoneButton()
    
    contentView.addSubview(bottomStack)
    
    NSLayoutConstraint.activate([
      bottomStack.topAnchor.constraint(equalTo: rootStack.bottomAnchor),
      bottomStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      bottomStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      bottomStack.heightAnchor.constraint(equalToConstant: 58)
    ])
  }
  
  private func configureCountLabel() {
    countLabel.font = .systemFont(ofSize: 12, weight: .medium)
    countLabel.textColor = .blackYP
    
    bottomStack.addArrangedSubview(countLabel)
  }
  
  private func configureDoneButton() {
    doneButton.layer.cornerRadius = 17
    doneButton.layer.masksToBounds = true
    doneButton.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
    bottomStack.addArrangedSubview(doneButton)
    
    NSLayoutConstraint.activate([
      doneButton.heightAnchor.constraint(equalToConstant: 34),
      doneButton.widthAnchor.constraint(equalToConstant: 34)
    ])
  }
  
  private func setStateDoneButton() {
    let icon = UIImage(resource: isDone ? .done : .plus)
    doneButton.setImage(icon.withRenderingMode(.alwaysTemplate), for: .normal)
    doneButton.alpha = isDone ? 0.3 : 1
  }
  
  @objc private func didTapDoneButton() {
    delegate?.trackerCellDidTapDone(self)
  }
}
