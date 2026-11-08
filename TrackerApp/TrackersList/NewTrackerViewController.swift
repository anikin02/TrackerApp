//
//  NewTrackerViewController.swift
//  TrackerApp
//
//  Created by Данил on 06/11/2026.
//

import UIKit

final class NewTrackerViewController: UIViewController {
  // MARK: - Iternal Properties
  weak var delegate: TrackersListDelegate?
  var isRegularNewTracker = true
  var titleView: String = "Новая привычка"
  
  // MARK: - UI Elements
  private let titleField: UITextField = .init()
  private let errorLabel: UILabel = .init()
  private let titleStack: UIStackView = .init()
  private let optionsTable: UITableView = .init()
  private let createButton: UIButton = .init()
  private let cancelButton: UIButton = .init()
  private let stackButtons: UIStackView = .init()
  
  // MARK: - Private Properties
  private var options: [String] = []
  private let maxLengthTitle = 38
  private var selectedSchedule: Set<WeekDay> = []
  private var selectedCategory: String?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if isRegularNewTracker {
      options = ["Категория", "Расписание"]
    } else {
      options = ["Категория"]
      selectedSchedule = Set(WeekDay.allCases)
    }
    
    configUI()
  }
  
  private func configUI() {
    view.backgroundColor = .whiteYP
    title = titleView
    
    configTitleField()
    configOptionsTable()
    configStackButtons()
  }
  
  private func configTitleField() {
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
    view.addSubview(titleStack)
    
    NSLayoutConstraint.activate([
      titleStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
      titleStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
      titleStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
      titleField.heightAnchor.constraint(equalToConstant: 75)
    ])
  }
  
  private func configOptionsTable() {
    optionsTable.translatesAutoresizingMaskIntoConstraints = false
    optionsTable.dataSource = self
    optionsTable.delegate = self
    
    optionsTable.backgroundColor = .backgroundYP
    optionsTable.layer.cornerRadius = 16
    optionsTable.layer.masksToBounds = true
    optionsTable.isScrollEnabled = false
    optionsTable.rowHeight = 75
    optionsTable.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    
    view.addSubview(optionsTable)
    NSLayoutConstraint.activate([
      optionsTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
      optionsTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
      optionsTable.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 24),
      optionsTable.heightAnchor.constraint(equalToConstant: 75 * CGFloat(options.count))
    ])
  }
  
  private func configCreateButton() {
    createButton.setTitle("Создать", for: .normal)
    createButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    createButton.setTitleColor(.whiteYP, for: .normal)
    createButton.layer.cornerRadius = 16
    createButton.layer.masksToBounds = true
    
    createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
    disableCreateButton()
  }
  
  private func configCancelButton() {
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
  
  private func configStackButtons() {
    configCancelButton()
    configCreateButton()
    
    stackButtons.translatesAutoresizingMaskIntoConstraints = false
    stackButtons.axis = .horizontal
    stackButtons.spacing = 8
    stackButtons.distribution = .fillEqually
    
    stackButtons.addArrangedSubview(cancelButton)
    stackButtons.addArrangedSubview(createButton)
    
    view.addSubview(stackButtons)
    
    NSLayoutConstraint.activate([
      stackButtons.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      stackButtons.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      stackButtons.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      stackButtons.heightAnchor.constraint(equalToConstant: 60)
    ])
  }
  
  // MARK: - Actions
  @objc private func createButtonTapped() {
    guard let selectedCategory, let name = titleField.text else { return }
    
    let tracker = Tracker(id: UUID(),
                          name: name,
                          hexColor: HexColorSection.color1.rawValue,
                          emoji: "😀",
                          schedule: selectedSchedule,
                          isRegular: isRegularNewTracker)
    
    delegate?.addNewTracker(tracker: tracker, category: selectedCategory )
    
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
          !selectedSchedule.isEmpty,
          !title.isEmpty else {
      disableCreateButton()
      return
    }
    
    enableCreateButton()
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

// MARK: - UITableViewDataSource, UITableViewDelegate
extension NewTrackerViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    options.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell")
    ?? UITableViewCell(style: .subtitle, reuseIdentifier: "OptionCell")
    cell.textLabel?.text = options[indexPath.row]
    cell.textLabel?.font = .systemFont(ofSize: 17)
    cell.textLabel?.textColor = .blackYP
    cell.backgroundColor = .clear
    cell.accessoryType = .disclosureIndicator
    cell.selectionStyle = .none
    
    if options[indexPath.row] == "Категория" {
      cell.detailTextLabel?.text = selectedCategory
    } else if options[indexPath.row] == "Расписание" {
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
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if options[indexPath.row] == "Категория" {
      selectedCategory = "Важное"
      updateCreateButtonState()
      self.optionsTable.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .none)
    } else if options[indexPath.row] == "Расписание" {
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
