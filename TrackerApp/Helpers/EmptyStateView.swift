//
//  EmptyStateView.swift
//  TrackerApp
//
//  Created by Данил on 10/11/2026.
//

import UIKit

final class EmptyStateView: UIView {
  private let label: UILabel = .init()
  private let imageView: UIImageView = .init()
  private let emptyStateStackView: UIStackView = .init()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureEmptyStateStack()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func config(with text: String, image: UIImage = UIImage(resource: .emptyState)) {
    label.text = text
    imageView.image = image
  }
  
  private func configureEmptyStateLabel() {
    label.textColor = .blackYP
    label.textAlignment = .center
    label.font = .systemFont(ofSize: 12, weight: .medium)
    
    emptyStateStackView.addArrangedSubview(label)
  }
  
  private func configureEmptyStateImage() {
    imageView.translatesAutoresizingMaskIntoConstraints = false
    
    emptyStateStackView.addArrangedSubview(imageView)
    
    NSLayoutConstraint.activate([
      imageView.heightAnchor.constraint(equalToConstant: 80),
      imageView.widthAnchor.constraint(equalToConstant: 80),
    ])
  }
  
  private func configureEmptyStateStack() {
    emptyStateStackView.translatesAutoresizingMaskIntoConstraints = false
    emptyStateStackView.axis = .vertical
    emptyStateStackView.alignment = .center
    emptyStateStackView.spacing = 8
    
    configureEmptyStateImage()
    configureEmptyStateLabel()
    addSubview(emptyStateStackView)
    
    NSLayoutConstraint.activate([
      emptyStateStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
      emptyStateStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      emptyStateStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
    ])
  }
}
