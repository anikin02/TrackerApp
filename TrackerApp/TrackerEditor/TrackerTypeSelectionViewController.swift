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
    
    configureUI()
  }
  
  private func configureUI() {
    view.backgroundColor = .whiteYP
    title = NSLocalizedString("trackerTypeSelectionTitle", comment: "")
    
    configureStack()
  }
  
  private func configureStack() {
    stackButtons.translatesAutoresizingMaskIntoConstraints = false
    stackButtons.axis = .vertical
    stackButtons.spacing = 16
    
    configureCreateRegularButton()
    configureCreateUnregularButton()
    
    view.addSubview(stackButtons)
    
    NSLayoutConstraint.activate([
      stackButtons.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
      stackButtons.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      stackButtons.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
    ])
  }
  
  private func configureCreateRegularButton() {
    createRegularButton.translatesAutoresizingMaskIntoConstraints = false
    let title = NSLocalizedString("regularTrackerButtonTitle", comment: "")
    createRegularButton.setTitle(title, for: .normal)
    createRegularButton.setTitleColor(.whiteYP, for: .normal)
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
  
  private func configureCreateUnregularButton() {
    createUnregularButton.translatesAutoresizingMaskIntoConstraints = false
    let title = NSLocalizedString("unregularTrackerButtonTitle", comment: "")
    createUnregularButton.setTitle(title, for: .normal)
    createUnregularButton.setTitleColor(.whiteYP, for: .normal)
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
    let title = NSLocalizedString("regularTrackerCreationTitle", comment: "")
    showCreationView(title: title, isRegular: true)
  }
  
  @objc private func createUnregularButtonTapped() {
    let title = NSLocalizedString("unregularTrackerCreationTitle", comment: "")
    showCreationView(title: title, isRegular: false)
  }
  
  private func showCreationView(title: String, isRegular: Bool) {
    let viewModel = TrackerEditorViewModel(isRegularTracker: isRegular, titleView: title)
    viewModel.delegate = delegate
    let viewController = TrackerEditorViewController(viewModel: viewModel)
    let navController = UINavigationController(rootViewController: viewController)
    navController.modalPresentationStyle = .pageSheet
    present(navController, animated: true)
  }
}
