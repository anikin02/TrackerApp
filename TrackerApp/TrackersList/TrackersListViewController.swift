//
//  TrackersListViewController.swift
//  TrackerApp
//
//  Created by Данил on 04/11/2026.
//

import UIKit

final class TrackersListViewController: UIViewController {
  // MARK: - UI Elements
  private let dateFilterPicker: UIDatePicker = .init()
  private let searchController: UISearchController =  .init(searchResultsController: nil)
  private let emptyStateStackView = UIStackView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configNavigationBar()
    configUI()
  }
  
  // MARK: - Private Methods
  private func configNavigationBar() {
    configTitle()
    configAddTrackerButton()
    configDateFilterPicker()
    configSearchController()
    
    if #available(iOS 26.0, *) {
      navigationItem.leftBarButtonItem?.hidesSharedBackground = true
      navigationItem.rightBarButtonItem?.hidesSharedBackground = true
    }
  }
  
  private func configTitle() {
    navigationItem.title = "Трекеры"
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationController?.navigationBar.largeTitleTextAttributes = [
        .foregroundColor: UIColor.blackYP,
        .font: UIFont.systemFont(ofSize: 34, weight: .bold)
      ]
  }
  
  private func configAddTrackerButton() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .add,
      target: self,
      action: #selector(addTrackerTapped)
    )
  }
  
  private func configDateFilterPicker() {
    dateFilterPicker.datePickerMode = .date
    dateFilterPicker.preferredDatePickerStyle = .compact
    dateFilterPicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: dateFilterPicker)
  }
  
  private func configSearchController() {
    searchController.searchBar.placeholder = "Поиск"
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
  }
  
  private func configUI() {
    view.backgroundColor = .whiteYP
    configEmptyStateStack()
    showEmptyState()
  }
  
  private func showEmptyState() {
    emptyStateStackView.isHidden = false
  }
  
  private func hideEmptyState() {
    emptyStateStackView.isHidden = true
  }
  
  private func configEmptyStateImage() {
    let imageView = UIImageView(image: UIImage(resource: .emptyState))
    imageView.translatesAutoresizingMaskIntoConstraints = false
    
    emptyStateStackView.addArrangedSubview(imageView)
    
    NSLayoutConstraint.activate([
      imageView.heightAnchor.constraint(equalToConstant: 80),
      imageView.widthAnchor.constraint(equalToConstant: 80),
    ])
  }
  
  private func configEmptyStateLabel() {
    let label = UILabel()
    label.text = "Что будем отслеживать?"
    label.textColor = .blackYP
    label.textAlignment = .center
    label.font = .systemFont(ofSize: 12, weight: .medium)
    
    emptyStateStackView.addArrangedSubview(label)
  }
  
  private func configEmptyStateStack() {
    emptyStateStackView.translatesAutoresizingMaskIntoConstraints = false
    emptyStateStackView.axis = .vertical
    emptyStateStackView.alignment = .center
    emptyStateStackView.spacing = 8
    
    configEmptyStateImage()
    configEmptyStateLabel()
    view.addSubview(emptyStateStackView)
    
    NSLayoutConstraint.activate([
      emptyStateStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
      emptyStateStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
      emptyStateStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
    ])
  }
  
  // MARK: - Actions
  @objc private func addTrackerTapped() {}
  @objc private func dateChanged() {}
}
