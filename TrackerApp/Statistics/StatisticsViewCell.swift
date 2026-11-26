//
//  StatisticsViewCell.swift
//  TrackerApp
//
//  Created by Данил on 23/11/2026.
//

import UIKit

final class StatisticsViewCell: UITableViewCell {
  
  static let reuseIdentifier = "StatisticsCell"
  
  // MARK: - UI Elements
  private let amountLabel: UILabel = .init()
  private let titleLabel: UILabel = .init()
  private let stackView: UIStackView = .init()
  private let gradientLayer: CAGradientLayer = .init()
  private let borderMask: CAShapeLayer = .init()
  
  // MARK: - Private Properties
  private let cardInsets = UIEdgeInsets(top: 0, left: 16, bottom: 12, right: 16)
  
  // MARK: - Init
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  override func layoutSubviews() {
    super.layoutSubviews()
    updateBorder()
  }
  
  // MARK: - Methods
  func configure(with model: StatisticsCellModel) {
    amountLabel.text = "\(model.amount)"
    titleLabel.text = model.title
  }
  
  // MARK: - Private Methods
  private func configureUI() {
    backgroundColor = .clear
    selectionStyle = .none
    
    configureGradientBorder()
    configureAmountLabel()
    configureTitleLabel()
    configureStackView()
  }
  
  private func configureGradientBorder() {
    gradientLayer.colors = [
      UIColor(hex: "#FD4C49")?.cgColor ?? UIColor.clear,
      UIColor(hex: "#46E69D")?.cgColor ?? UIColor.clear,
      UIColor(hex: "#007BFA")?.cgColor ?? UIColor.clear
    ]
    gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
    gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
    
    borderMask.fillColor = UIColor.clear.cgColor
    borderMask.strokeColor = UIColor.black.cgColor
    borderMask.lineWidth = 1
    gradientLayer.mask = borderMask
    
    contentView.layer.addSublayer(gradientLayer)
  }
  
  private func configureAmountLabel() {
    amountLabel.textColor = .blackYP
    amountLabel.font = .systemFont(ofSize: 34, weight: .bold)
  }
  
  private func configureTitleLabel() {
    titleLabel.textColor = .blackYP
    titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
  }
  
  private func configureStackView() {
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.distribution = .equalSpacing
    stackView.addArrangedSubview(amountLabel)
    stackView.addArrangedSubview(titleLabel)
    contentView.addSubview(stackView)
    
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: cardInsets.top + 12),
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -(cardInsets.bottom + 12)),
      stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: cardInsets.left + 12),
      stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -(cardInsets.right + 12))
    ])
  }
  
  private func updateBorder() {
    let cardRect = contentView.bounds.inset(by: cardInsets)
    
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    
    gradientLayer.frame = cardRect
    
    let pathRect = gradientLayer.bounds.insetBy(dx: 1 / 2, dy: 1 / 2)
    borderMask.path = UIBezierPath(
      roundedRect: pathRect,
      cornerRadius: 16 - 1 / 2
    ).cgPath
    
    CATransaction.commit()
  }
}
