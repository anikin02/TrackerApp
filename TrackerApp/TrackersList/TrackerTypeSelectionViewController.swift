//
//  TrackerTypeSelectionViewController.swift
//  TrackerApp
//
//  Created by Данил on 08/11/2026.
//

import UIKit

final class TrackerTypeSelectionViewController: UIViewController {
  weak var delegate: TrackersListDelegate?
  private let stackButtons: UIStackView = .init()
  private let createRegularButton: UIButton = .init()
  private let createUnregularButton: UIButton = .init()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configUI()
  }
  
  private func configUI() {
    view.backgroundColor = .whiteYP
    title = "Создание трекера"
    
    configStack()
  }
  
  private func configStack() {
    stackButtons.translatesAutoresizingMaskIntoConstraints = false
    stackButtons.axis = .vertical
    stackButtons.spacing = 16
    
    configCreateRegularButton()
    configCreateUnregularButton()
    
    view.addSubview(stackButtons)
    
    NSLayoutConstraint.activate([
      stackButtons.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
      stackButtons.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      stackButtons.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
    ])
  }
  
  private func configCreateRegularButton() {
    createRegularButton.translatesAutoresizingMaskIntoConstraints = false
    createRegularButton.setTitle("Привычка", for: .normal)
    createRegularButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    createRegularButton.backgroundColor = .blackYP
    createRegularButton.layer.cornerRadius = 16
    createRegularButton.layer.masksToBounds = true
    createRegularButton.addTarget(self, action: #selector(createRegularButtonTapped), for: .touchUpInside)
    
    stackButtons.addArrangedSubview(createRegularButton)
    
    NSLayoutConstraint.activate([
      createRegularButton.heightAnchor.constraint(equalToConstant: 60)
    ])
  }
  
  private func configCreateUnregularButton() {
    createUnregularButton.translatesAutoresizingMaskIntoConstraints = false
    createUnregularButton.setTitle("Нерегулярное событие", for: .normal)
    createUnregularButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    createUnregularButton.backgroundColor = .blackYP
    createUnregularButton.layer.cornerRadius = 16
    createUnregularButton.layer.masksToBounds = true
    createUnregularButton.addTarget(self, action: #selector(createUnregularButtonTapped), for: .touchUpInside)
    
    stackButtons.addArrangedSubview(createUnregularButton)
    
    NSLayoutConstraint.activate([
      createUnregularButton.heightAnchor.constraint(equalToConstant: 60)
    ])
  }
  
  @objc private func createRegularButtonTapped() {
    let viewController = NewTrackerViewController()
    viewController.delegate = delegate
    viewController.isRegularNewTracker = true
    viewController.titleView = "Новая привычка"
    let navController = UINavigationController(rootViewController: viewController)
    navController.modalPresentationStyle = .pageSheet
    present(navController, animated: true)
  }
  
  @objc private func createUnregularButtonTapped() {
    let viewController = NewTrackerViewController()
    viewController.delegate = delegate
    viewController.isRegularNewTracker = false
    viewController.titleView = "Новое нерегулярное событие"
    let navController = UINavigationController(rootViewController: viewController)
    navController.modalPresentationStyle = .pageSheet
    present(navController, animated: true)
  }
}
