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
  private let titleLabel: UILabel = .init()
  private let searchBar: UISearchBar = .init()
  private let emptyStateStackView = UIStackView()
  private let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    return collectionView
  }()
  
  // MARK: - Properties
  private var categories: [TrackerCategory] = Mock.categories
  private var completedTrackers: [TrackerRecord] = Mock.completedTrackers
  
  private var visibleCategories: [TrackerCategory] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configUI()
    
    visibleCategories = getDateCategories()
    
    if visibleCategories.isEmpty {
      showEmptyState()
    } else {
      hideEmptyState()
    }
  }
  
  // MARK: - Private Methods
  private func configNavigationBar() {
    configAddTrackerButton()
    configDateFilterPicker()
    configTitle()
    configSearchBar()
    
    if #available(iOS 26.0, *) {
      navigationItem.leftBarButtonItem?.hidesSharedBackground = true
      navigationItem.rightBarButtonItem?.hidesSharedBackground = true
    }
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
  
  private func configTitle() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.text = "Трекеры"
    titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
    titleLabel.textColor = .blackYP
    view.addSubview(titleLabel)
    
    NSLayoutConstraint.activate([
      titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
      titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
    ])
  }
  
  private func configSearchBar() {
    searchBar.translatesAutoresizingMaskIntoConstraints = false
    searchBar.placeholder = "Поиск"
    searchBar.searchBarStyle = .minimal // убирает серый фон вокруг поля
    
    view.addSubview(searchBar)
    
    NSLayoutConstraint.activate([
      searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
      searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
      searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8)
    ])
  }
  
  private func configUI() {
    view.backgroundColor = .whiteYP
    configNavigationBar()
    configCollection()
    configEmptyStateStack()
  }
  
  private func showEmptyState() {
    emptyStateStackView.isHidden = false
  }
  
  private func hideEmptyState() {
    emptyStateStackView.isHidden = true
  }
  
  private func configCollection() {
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.register(
      TrackerViewCell.self,
      forCellWithReuseIdentifier: TrackerViewCell.reuseIdentifier
    )
    
    collectionView.register(
      TrackerHeaderView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: TrackerHeaderView.reuseIdentifier
    )
    
    collectionView.backgroundColor = .whiteYP
    
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.contentInsetAdjustmentBehavior = .never
    
    view.addSubview(collectionView)
    
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 18),
      collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant:  16),
      collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
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
  private func configEmptyStateImage() {
    let imageView = UIImageView(image: UIImage(resource: .emptyState))
    imageView.translatesAutoresizingMaskIntoConstraints = false
    
    emptyStateStackView.addArrangedSubview(imageView)
    
    NSLayoutConstraint.activate([
      imageView.heightAnchor.constraint(equalToConstant: 80),
      imageView.widthAnchor.constraint(equalToConstant: 80),
    ])
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
  
  private func getDateCategories() -> [TrackerCategory] {
    var result: [TrackerCategory] = []
    
    for category in categories {
      let title = category.title
      var trackers: [Tracker] = []
      
      for tracker in category.trackers {
        let numberDay = Calendar.current.component(.weekday, from: dateFilterPicker.date)
        if let day = WeekDay(rawValue: numberDay),
           tracker.schedule.contains(day){
          trackers.append(tracker)
        }
      }
      if !trackers.isEmpty {
        result.append(TrackerCategory(title: title, trackers: trackers))
      }
    }
    return result
  }
  
  // MARK: - Actions
  @objc private func addTrackerTapped() {}
  @objc private func dateChanged() {
    visibleCategories = getDateCategories()
    collectionView.reloadData()
  }
}

// MARK: - UICollectionViewDataSource
extension TrackersListViewController: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    visibleCategories.count
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    visibleCategories[section].trackers.count
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      viewForSupplementaryElementOfKind kind: String,
                      at indexPath: IndexPath) -> UICollectionReusableView {
    guard kind == UICollectionView.elementKindSectionHeader,
          let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerHeaderView.reuseIdentifier,
            for: indexPath
          ) as? TrackerHeaderView
            else { return UICollectionReusableView() }
    
    header.configHeader(title: visibleCategories[indexPath.section].title)
    return header
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: TrackerViewCell.reuseIdentifier,
      for: indexPath
    ) as? TrackerViewCell else { return UICollectionViewCell() }
    
    let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
    
    let model = createCellModel(tracker)
    cell.delegate = self
    cell.configCell(with: model)
    return cell
  }
  
  private func createCellModel(_ tracker: Tracker) -> CellModel {
    let daysCount = completedTrackers.filter { $0.trackerId == tracker.id }.count
    return CellModel(
      name: tracker.name,
      emoji: tracker.emoji,
      count: daysCount,
      hexColor: tracker.hexColor,
      isDone: isDone(with: tracker)
    )
  }
  
  private func isDone(with tracker: Tracker) -> Bool {
    completedTrackers.contains {
      $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: dateFilterPicker.date)
    }
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersListViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    let sideInset: CGFloat = 16
    let available = collectionView.bounds.width - sideInset * 2
    return CGSize(width: floor(available / 2), height: 148)
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      referenceSizeForHeaderInSection section: Int) -> CGSize {
    getHeaderSize(for: collectionView)
  }
  
  private func getHeaderSize(for collectionView: UICollectionView) -> CGSize {
    let view = TrackerHeaderView(frame: .zero)
    view.configHeader(title: "Header")
    return view.systemLayoutSizeFitting(
      CGSize(width: collectionView.bounds.width, height: UIView.layoutFittingExpandedSize.height),
      withHorizontalFittingPriority: .required,
      verticalFittingPriority: .fittingSizeLevel)
  }
}

extension TrackersListViewController: UICollectionViewDelegate {
  
}

// MARK: - TrackerCellDelegate
extension TrackersListViewController: TrackerCellDelegate {
  func trackerCellDidTapDone(_ cell: TrackerViewCell) {
    guard let indexPath = collectionView.indexPath(for: cell) else { return }
    
    let selectedDate = dateFilterPicker.date
    let calendar = Calendar.current
    guard calendar.startOfDay(for: selectedDate) <= calendar.startOfDay(for: Date()) else { return }
    let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
    
    if let index = completedTrackers.firstIndex(where: {
      $0.trackerId == tracker.id && calendar.isDate($0.date, inSameDayAs: selectedDate)
    }) {
      completedTrackers.remove(at: index)
    } else {
      completedTrackers.append(TrackerRecord(trackerId: tracker.id, date: selectedDate))
    }
    
    collectionView.reloadItems(at: [indexPath])
  }
}
