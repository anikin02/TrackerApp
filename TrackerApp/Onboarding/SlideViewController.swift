//
//  SlideViewController.swift
//  TrackerApp
//
//  Created by Данил on 16/11/2026.
//

import UIKit

final class SlideViewController: UIViewController {
  private let titleLabel: UILabel = .init()
  private let coverImageView: UIImageView = .init()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureUI()
  }
  
  func configure(title: String, cover: UIImage) {
    titleLabel.text = title
    coverImageView.image = cover
  }
  
  private func configureUI() {
    configureCoverImageView()
    configureTitleLabel()
  }
  
  private func configureTitleLabel() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
    titleLabel.textColor = .blackYP
    titleLabel.textAlignment = .center
    titleLabel.numberOfLines = 0
    
    view.addSubview(titleLabel)
    
    NSLayoutConstraint.activate([
      titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      titleLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -270),
    ])
  }
  
  private func configureCoverImageView() {
    coverImageView.translatesAutoresizingMaskIntoConstraints = false
    coverImageView.contentMode = .scaleAspectFill
    coverImageView.clipsToBounds = true
    
    view.addSubview(coverImageView)
    
    NSLayoutConstraint.activate([
      coverImageView.topAnchor.constraint(equalTo: view.topAnchor),
      coverImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      coverImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      coverImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    ])
  }
}
