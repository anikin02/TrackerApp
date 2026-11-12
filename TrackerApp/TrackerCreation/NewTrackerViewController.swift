//
//  NewTrackerViewController.swift
//  TrackerApp
//
//  Created by Данил on 06/11/2026.
//

import UIKit

final class NewTrackerViewController: UIViewController {
  // MARK: - Internal Properties
  weak var delegate: TrackersListDelegate?
  var isRegularNewTracker = true
  var titleView: String = "Новая привычка"
  
  // MARK: - UI Elements
  private let scrollView: UIScrollView = .init()
  private let contentView:UIView = .init()
  private let titleField: UITextField = .init()
  private let errorLabel: UILabel = .init()
  private let titleStack: UIStackView = .init()
  private let optionsTable: UITableView = .init()
  private let emojiColorColletion: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    return collectionView
  }()
  private var emojiColorColletionHeightConstraint: NSLayoutConstraint?
  private let createButton: UIButton = .init()
  private let cancelButton: UIButton = .init()
  private let stackButtons: UIStackView = .init()
  
  // MARK: - Private Properties
  private enum Option {
    case category
    case schedule
    
    var title: String {
      switch self {
        case .category:
          return "Категория"
        case .schedule:
          return "Расписание"
      }
    }
  }
  
  private enum emojiColorSection: Int, CaseIterable {
    case emoji = 0
    case color = 1
    
    var title: String {
      switch self {
        case .emoji:
          return "Emoji"
        case .color:
          return "Цвет"
      }
    }
    
    var items: [String] {
      switch self {
        case .emoji:
          return Emojis.allCases.map(\.rawValue)
        case .color:
          return HexColorSection.allCases.map(\.rawValue)
      }
    }
  }
  
  private var options: [Option] = []
  private let maxLengthTitle = 38
  private var selectedSchedule: Set<WeekDay> = []
  private var selectedCategory: String?
  private var selectedEmojiIndexPath: IndexPath?
  private var selectedColorIndexPath: IndexPath?
  private let columnsCount: CGFloat = 6

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureTrackerType()
    
    configureUI()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    let height = calculateEmojiColorCollectionHeight(for: emojiColorColletion.bounds.width)
    if emojiColorColletionHeightConstraint?.constant != height {
      emojiColorColletionHeightConstraint?.constant = height
    }
  }
  
  private func configureTrackerType() {
    if isRegularNewTracker {
      options = [.category, .schedule]
    } else {
      options = [.category]
      selectedSchedule = Set(WeekDay.allCases)
    }
  }
  
  private func configureUI() {
    view.backgroundColor = .whiteYP
    title = titleView
    
    configureLayout()
    configureTitleField()
    configureOptionsTable()
    configureEmojiColorColletion()
    configureStackButtons()
  }
  
  private func configureLayout() {
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    contentView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scrollView)
    
    contentView.addSubview(titleStack)
    contentView.addSubview(optionsTable)
    contentView.addSubview(emojiColorColletion)
    contentView.addSubview(stackButtons)
    scrollView.addSubview(contentView)
    
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
      contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
      contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
      contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
    ])
  }
  
  private func configureTitleField() {
    titleField.translatesAutoresizingMaskIntoConstraints = false
    titleField.backgroundColor = .backgroundYP
    titleField.layer.cornerRadius = 16
    titleField.layer.masksToBounds = true
    titleField.font = .systemFont(ofSize: 17, weight: .regular)
    titleField.textColor = .blackYP
    titleField.attributedPlaceholder = NSAttributedString(
      string: "Введите название трекера",
      attributes: [.foregroundColor: UIColor.grayYP]
    )
    titleField.clearButtonMode = .whileEditing
    titleField.returnKeyType = .done
    titleField.delegate = self
    
    titleField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
    titleField.leftViewMode = .always
    
    titleField.addTarget(self, action: #selector(titleChanged), for: .editingChanged)
    
    errorLabel.text = "Ограничение \(maxLengthTitle) символов"
    errorLabel.font = .systemFont(ofSize: 17, weight: .regular)
    errorLabel.textColor = .redYP
    errorLabel.textAlignment = .center
    errorLabel.isHidden = true
    
    titleStack.translatesAutoresizingMaskIntoConstraints = false
    titleStack.axis = .vertical
    titleStack.spacing = 8
    titleStack.addArrangedSubview(titleField)
    titleStack.addArrangedSubview(errorLabel)
    
    NSLayoutConstraint.activate([
      titleStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
      titleStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      titleStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      titleField.heightAnchor.constraint(equalToConstant: 75)
    ])
  }
  
  private func configureOptionsTable() {
    optionsTable.translatesAutoresizingMaskIntoConstraints = false
    optionsTable.dataSource = self
    optionsTable.delegate = self
    
    optionsTable.backgroundColor = .backgroundYP
    optionsTable.layer.cornerRadius = 16
    optionsTable.layer.masksToBounds = true
    optionsTable.isScrollEnabled = false
    optionsTable.rowHeight = 75
    optionsTable.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    
    NSLayoutConstraint.activate([
      optionsTable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      optionsTable.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      optionsTable.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 24),
      optionsTable.heightAnchor.constraint(equalToConstant: 75 * CGFloat(options.count))
    ])
  }
  
  private func configureEmojiColorColletion() {
    emojiColorColletion.translatesAutoresizingMaskIntoConstraints = false
    emojiColorColletion.register(
      EmojiCell.self,
      forCellWithReuseIdentifier: EmojiCell.reuseIdentifier
    )
    emojiColorColletion.register(
      ColorCell.self,
      forCellWithReuseIdentifier: ColorCell.reuseIdentifier
    )
    emojiColorColletion.register(
      HeaderView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: HeaderView.reuseIdentifier
    )
    emojiColorColletion.backgroundColor = .whiteYP
    emojiColorColletion.delegate = self
    emojiColorColletion.dataSource = self
    emojiColorColletion.contentInsetAdjustmentBehavior = .never
    emojiColorColletion.isScrollEnabled = false
    
    let heightConstraint = emojiColorColletion.heightAnchor.constraint(equalToConstant: 0)
    emojiColorColletionHeightConstraint = heightConstraint
    
    NSLayoutConstraint.activate([
      emojiColorColletion.topAnchor.constraint(equalTo: optionsTable.bottomAnchor, constant: 16),
      emojiColorColletion.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:  16),
      emojiColorColletion.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      heightConstraint
    ])
  }
  
  private func configureCreateButton() {
    createButton.setTitle("Создать", for: .normal)
    createButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    createButton.setTitleColor(.whiteYP, for: .normal)
    createButton.layer.cornerRadius = 16
    createButton.layer.masksToBounds = true
    
    createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
    disableCreateButton()
  }
  
  private func configureCancelButton() {
    cancelButton.setTitle("Отменить", for: .normal)
    cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    cancelButton.setTitleColor(.redYP, for: .normal)
    cancelButton.backgroundColor = .clear
    
    cancelButton.layer.cornerRadius = 16
    cancelButton.layer.masksToBounds = true
    cancelButton.layer.borderWidth = 1
    cancelButton.layer.borderColor = UIColor.redYP.cgColor
    
    cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
  }
  
  private func configureStackButtons() {
    configureCancelButton()
    configureCreateButton()
    
    stackButtons.translatesAutoresizingMaskIntoConstraints = false
    stackButtons.axis = .horizontal
    stackButtons.spacing = 8
    stackButtons.distribution = .fillEqually
    
    stackButtons.addArrangedSubview(cancelButton)
    stackButtons.addArrangedSubview(createButton)
    
    NSLayoutConstraint.activate([
      stackButtons.topAnchor.constraint(equalTo: emojiColorColletion.bottomAnchor, constant: 40),
      stackButtons.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      stackButtons.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
      stackButtons.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      stackButtons.heightAnchor.constraint(equalToConstant: 60)
    ])
  }
  
  // MARK: - Actions
  @objc private func createButtonTapped() {
    guard let selectedCategory,
          let name = titleField.text,
          let selectedEmojiIndexPath,
          let selectedColorIndexPath else { return }
    
    guard let colorSection = emojiColorSection(rawValue: selectedColorIndexPath.section) else {
      return
    }
    
    guard let emojiSection = emojiColorSection(rawValue: selectedEmojiIndexPath.section) else {
      return
    }
    
    let emoji = emojiSection.items[selectedEmojiIndexPath.item]
    let color = colorSection.items[selectedColorIndexPath.item]
    
    let tracker = Tracker(id: UUID(),
                          name: name,
                          hexColor: color,
                          emoji: emoji,
                          schedule: selectedSchedule,
                          isRegular: isRegularNewTracker)
    
    delegate?.addNewTracker(tracker: tracker, category: selectedCategory)
    
    view.window?.rootViewController?.dismiss(animated: true)
  }
  
  @objc private func cancelButtonTapped() {
    dismiss(animated: true)
  }
  
  @objc private func titleChanged() {
    let text = (titleField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    
    if !text.isEmpty {
      updateCreateButtonState()
    } else {
      disableCreateButton()
    }
  }
  
  // MARK: - Private methods
  private func setError(visible: Bool) {
    guard errorLabel.isHidden == visible else { return }
    UIView.animate(withDuration: 0.2) {
      self.errorLabel.isHidden = !visible
      self.view.layoutIfNeeded()
    }
  }
  
  private func enableCreateButton() {
    createButton.backgroundColor = .blackYP
    createButton.isEnabled = true
  }
  
  private func disableCreateButton() {
    createButton.backgroundColor = .grayYP
    createButton.isEnabled = false
  }
  
  private func updateCreateButtonState() {
    let title = (titleField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    
    guard selectedCategory != nil,
          selectedEmojiIndexPath != nil,
          selectedColorIndexPath != nil,
          !selectedSchedule.isEmpty,
          !title.isEmpty else {
      disableCreateButton()
      return
    }
    
    enableCreateButton()
  }
  
  private func calculateEmojiColorCollectionHeight(for width: CGFloat) -> CGFloat {
    guard width > 0 else { return 0 }

    let cellSide = floor(width / columnsCount)
    let headerHeight = getHeaderSize(for: emojiColorColletion).height

    return emojiColorSection.allCases.reduce(0) { total, section in
      let rows = ceil(CGFloat(section.items.count) / columnsCount)
      return total + headerHeight + rows * cellSide
    }
  }
}

// MARK: - UITextFieldDelegate
extension NewTrackerViewController: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let current = textField.text ?? ""
    guard let swiftRange = Range(range, in: current) else { return false }
    let updated = current.replacingCharacters(in: swiftRange, with: string)
    
    if updated.count > maxLengthTitle {
      setError(visible: true)
      return false
    }
    setError(visible: false)
    return true
  }
  
  func textFieldShouldClear(_ textField: UITextField) -> Bool {
    setError(visible: false)
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}

// MARK: - UITableViewDelegate
extension NewTrackerViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch options[indexPath.row] {
      case .category:
        let categoryVC = CategorySelectionViewController()
        categoryVC.configureView(with: delegate?.categories ?? [])
        categoryVC.categorySelected = { [weak self] category in
          guard let self else { return }
          self.selectedCategory = category
          self.optionsTable.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .none)
          self.updateCreateButtonState()
        }
        let nav = UINavigationController(rootViewController: categoryVC)
        present(nav, animated: true)
      case .schedule:
        let scheduleVC = ScheduleSelectionViewController(selectedDays: selectedSchedule)
        scheduleVC.onDone = { [weak self] days in
          guard let self else { return }
          self.selectedSchedule = days
          self.optionsTable.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .none)
          self.updateCreateButtonState()
        }
        let nav = UINavigationController(rootViewController: scheduleVC)
        present(nav, animated: true)
    }
  }
}

// MARK: - UITableViewDataSource
extension NewTrackerViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    options.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell")
    ?? UITableViewCell(style: .subtitle, reuseIdentifier: "OptionCell")
    cell.textLabel?.text = options[indexPath.row].title
    cell.textLabel?.font = .systemFont(ofSize: 17)
    cell.textLabel?.textColor = .blackYP
    cell.backgroundColor = .clear
    cell.accessoryType = .disclosureIndicator
    cell.selectionStyle = .none
    cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
    cell.detailTextLabel?.textColor = .grayYP
    
    switch options[indexPath.row] {
      case .category:
        cell.detailTextLabel?.text = selectedCategory
      case .schedule:
        cell.detailTextLabel?.text = selectedSchedule.isEmpty
        ? nil
        : WeekDay.scheduleDescription(for: selectedSchedule)
    }
    
    if indexPath.row == options.count - 1 {
      cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: .greatestFiniteMagnitude)
    } else {
      cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    return cell
  }
}

// MARK: - UICollectionViewDelegate
extension NewTrackerViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let section = emojiColorSection(rawValue: indexPath.section) else { return }
    
    switch section {
      case .emoji:
        guard selectedEmojiIndexPath != indexPath else { return }
        let old = selectedEmojiIndexPath
        selectedEmojiIndexPath = indexPath
        collectionView.reloadItems(at: [indexPath, old].compactMap { $0 })
      case .color:
        guard selectedColorIndexPath != indexPath else { return }
        let old = selectedColorIndexPath
        selectedColorIndexPath = indexPath
        collectionView.reloadItems(at: [indexPath, old].compactMap { $0 })
    }
    updateCreateButtonState()
  }
}

// MARK: - UICollectionViewDataSource
extension NewTrackerViewController: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    emojiColorSection.allCases.count
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    emojiColorSection(rawValue: section)?.items.count ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    guard kind == UICollectionView.elementKindSectionHeader,
          let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: HeaderView.reuseIdentifier,
            for: indexPath
          ) as? HeaderView
            else { return UICollectionReusableView() }
    
    header.configureHeader(title: emojiColorSection(rawValue: indexPath.section)?.title ?? "")
    return header
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let section = emojiColorSection(rawValue: indexPath.section) else {
      return UICollectionViewCell()
    }
    let item = section.items[indexPath.item]
    
    switch section {
      case .emoji:
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: EmojiCell.reuseIdentifier, for: indexPath
        ) as? EmojiCell else { return UICollectionViewCell() }
        cell.configureCell(with: item, isSelected: indexPath == selectedEmojiIndexPath)
        return cell
        
      case .color:
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: ColorCell.reuseIdentifier, for: indexPath
        ) as? ColorCell else { return UICollectionViewCell() }
        cell.configureCell(with: UIColor(hex: item) ?? .blackYP, isSelected: indexPath == selectedColorIndexPath)
        return cell
    }
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension NewTrackerViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    let available = collectionView.bounds.width
    return CGSize(width: floor(available / 6), height: floor(available / 6))
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      referenceSizeForHeaderInSection section: Int) -> CGSize {
    getHeaderSize(for: collectionView)
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    0
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    0
  }
  
  private func getHeaderSize(for collectionView: UICollectionView) -> CGSize {
    let view = HeaderView(frame: .zero)
    view.configureHeader(title: "Header")
    return view.systemLayoutSizeFitting(
      CGSize(width: collectionView.bounds.width, height: UIView.layoutFittingExpandedSize.height),
      withHorizontalFittingPriority: .required,
      verticalFittingPriority: .fittingSizeLevel)
  }
}
