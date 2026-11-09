//
//  TrackersListViewController.swift
//  TrackerApp
//
//  Created by Данил on 04/11/2026.
//

import UIKit

protocol TrackersListDelegate: AnyObject {
  func addNewTracker(tracker: Tracker, category: String)
}

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
  private var currentDate: Date = Date()
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
    let icon = UIImage(resource: .navPlus).withRenderingMode(.alwaysTemplate)
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: icon,
      style: .plain,
      target: self,
      action: #selector(addTrackerTapped)
    )
    navigationItem.leftBarButtonItem?.tintColor = .blackYP
  }
  
  private func configDateFilterPicker() {
    dateFilterPicker.datePickerMode = .date
    dateFilterPicker.preferredDatePickerStyle = .compact
    dateFilterPicker.date = currentDate
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
    searchBar.searchBarStyle = .minimal
    searchBar.delegate = self
    
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
        let numberDay = Calendar.current.component(.weekday, from: currentDate)
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
  
  private func filterBySearch(_ categories: [TrackerCategory], query: String) -> [TrackerCategory] {
    let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !query.isEmpty else { return categories }

    return categories.compactMap { category in
      if category.title.localizedCaseInsensitiveContains(query) {
        return category
      }

      let trackers = category.trackers.filter {
        $0.name.localizedCaseInsensitiveContains(query)
      }
      return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
    }
  }
  
  private func updateVisibleCategories() {
    let byDate = getDateCategories()
    visibleCategories = filterBySearch(byDate, query: searchBar.text ?? "")
    collectionView.reloadData()

    if visibleCategories.isEmpty {
      showEmptyState()
    } else {
      hideEmptyState()
    }
  }
  
  // MARK: - Actions
  @objc private func addTrackerTapped() {
    let viewController = TrackerTypeSelectionViewController()
    viewController.delegate = self
    let navController = UINavigationController(rootViewController: viewController)
    navController.modalPresentationStyle = .pageSheet
    present(navController, animated: true)
  }
  
  @objc private func dateChanged() {
    currentDate = dateFilterPicker.date
    updateVisibleCategories()
  }
}

// MARK: - TrackersListDelegate
extension TrackersListViewController: TrackersListDelegate {
  func addNewTracker(tracker: Tracker, category: String) {
    if let indexCategories = categories.firstIndex(where: {$0.title == category}) {
      categories[indexCategories] = TrackerCategory(title: category,
                                                    trackers: categories[indexCategories].trackers + [tracker])
    } else {
      categories.append(TrackerCategory(title: category, trackers: [tracker]))
    }
    
    let oldVisible = visibleCategories
    let newVisible = getDateCategories()
    visibleCategories = newVisible
    
    guard let section = newVisible.firstIndex(where: { $0.title == category }),
          let item = newVisible[section].trackers.firstIndex(where: { $0.id == tracker.id })
            else { return }
    
    let sectionExisted = oldVisible.contains { $0.title == category }
    
    collectionView.performBatchUpdates {
      if sectionExisted {
        collectionView.insertItems(at: [IndexPath(item: item, section: section)])
      } else {
        collectionView.insertSections(IndexSet(integer: section))
      }
    }
    
    hideEmptyState()
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
      $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
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
    
    let calendar = Calendar.current
    guard calendar.startOfDay(for: currentDate) <= calendar.startOfDay(for: Date()) else { return }
    let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
    
    if let index = completedTrackers.firstIndex(where: {
      $0.trackerId == tracker.id && calendar.isDate($0.date, inSameDayAs: currentDate)
    }) {
      completedTrackers.remove(at: index)
    } else {
      completedTrackers.append(TrackerRecord(trackerId: tracker.id, date: currentDate))
    }
    
    collectionView.reloadItems(at: [indexPath])
  }
}

// MARK: - UISearchBarDelegate
extension TrackersListViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    updateVisibleCategories()
  }

  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
}
