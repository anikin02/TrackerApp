//
//  TrackerEditorViewModel.swift
//  TrackerApp
//
//  Created by Данил on 18/11/2026.
//

import Foundation

struct OptionCellModel {
  let title: String
  let detail: String?
}

enum EmojiColorItem {
  case emoji(String, isSelected: Bool)
  case color(hex: String, isSelected: Bool)
}

enum NewTrackerRoute {
  case category(selected: String?)
  case schedule(selected: Set<WeekDay>)
}

final class TrackerEditorViewModel {
  // MARK: - Bindings
  var onCreateButtonStateChange: Binding<Bool>?
  var onTitleErrorChange: Binding<Bool>?
  var onOptionUpdate: Binding<Int>?
  var onItemsUpdate: Binding<[ItemPosition]>?
  var onRoute: Binding<NewTrackerRoute>?
  var onTrackerCreated: Binding<Void>?
  
  // MARK: - Properties
  weak var delegate: TrackersListDelegate?
  let titleView: String
  let errorText: String
  let columnsCount: CGFloat = 6
  var numberOfOptions: Int { options.count }
  var numberOfSections: Int { EmojiColorSection.allCases.count }
  
  // MARK: Private Properties
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
  private enum EmojiColorSection: Int, CaseIterable {
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
  private let isRegularNewTracker: Bool
  private var options: [Option] = []
  private let maxLengthTitle = 38
  private var selectedSchedule: Set<WeekDay> = []
  private var selectedCategory: String?
  private var selectedEmojiIndex: Int?
  private var selectedColorIndex: Int?
  private var textTitle: String?
  
  // MARK: - Init
  init(isRegularNewTracker: Bool = true, titleView: String) {
    self.isRegularNewTracker = isRegularNewTracker
    self.titleView = titleView
    errorText = "Ограничение \(maxLengthTitle) символов"
    configureTrackerType()
  }
  
  func headerTitle(for section: Int) -> String {
    EmojiColorSection(rawValue: section)?.title ?? ""
  }
  
  func titleDidChange(_ text: String) {
    textTitle = text.trimmingCharacters(in: .whitespacesAndNewlines)
    updateCreateButtonState()
  }
  
  func canChangeTitle(to newText: String) -> Bool {
    let isAllowed = newText.count <= maxLengthTitle
    onTitleErrorChange?(!isAllowed)
    return isAllowed
  }
  
  func titleDidClear() {
    onTitleErrorChange?(false)
    titleDidChange("")
  }
  
  func didTappedCreateButton() {
    guard let selectedCategory,
          let textTitle, !textTitle.isEmpty,
          let selectedEmojiIndex,
          let selectedColorIndex else { return }
    
    let emoji = EmojiColorSection.emoji.items[selectedEmojiIndex]
    let color = EmojiColorSection.color.items[selectedColorIndex]
    
    let tracker = Tracker(id: UUID(),
                          name: textTitle,
                          hexColor: color,
                          emoji: emoji,
                          schedule: selectedSchedule,
                          isRegular: isRegularNewTracker)
    
    delegate?.addNewTracker(tracker: tracker, category: selectedCategory)
    onTrackerCreated?(())
  }
  
  func numberOfItems(in section: Int) -> Int {
    EmojiColorSection(rawValue: section)?.items.count ?? 0
  }
  
  func optionCellModel(at index: Int) -> OptionCellModel {
    let option = options[index]
    switch option {
      case .category:
        return OptionCellModel(title: option.title, detail: selectedCategory)
      case .schedule:
        let detail = selectedSchedule.isEmpty ? nil : WeekDay.scheduleDescription(for: selectedSchedule)
        return OptionCellModel(title: option.title, detail: detail)
    }
  }
  
  func isLastOption(at index: Int) -> Bool {
    index == options.count - 1
  }
  
  func didSelectOption(at index: Int) {
    switch options[index] {
      case .category: onRoute?(.category(selected: selectedCategory))
      case .schedule: onRoute?(.schedule(selected: selectedSchedule))
    }
  }
  
  func didSelectCategory(_ category: String) {
    selectedCategory = category
    notifyOptionUpdate(.category)
    updateCreateButtonState()
  }
  
  func didSelectSchedule(_ days: Set<WeekDay>) {
    selectedSchedule = days
    notifyOptionUpdate(.schedule)
    updateCreateButtonState()
  }
  
  func item(at position: ItemPosition) -> EmojiColorItem? {
    guard let section = EmojiColorSection(rawValue: position.section),
          section.items.indices.contains(position.item) else { return nil }
    let value = section.items[position.item]
    switch section {
      case .emoji: return .emoji(value, isSelected: position.item == selectedEmojiIndex)
      case .color: return .color(hex: value, isSelected: position.item == selectedColorIndex)
    }
  }
  
  func didSelectItem(at position: ItemPosition) {
    guard let section = EmojiColorSection(rawValue: position.section) else { return }
    let old: Int?
    
    switch section {
      case .emoji:
        guard selectedEmojiIndex != position.item else { return }
        old = selectedEmojiIndex
        selectedEmojiIndex = position.item
      case .color:
        guard selectedColorIndex != position.item else { return }
        old = selectedColorIndex
        selectedColorIndex = position.item
    }
    
    var changed = [position]
    if let old { changed.append(ItemPosition(section: position.section, item: old)) }
    onItemsUpdate?(changed)
    updateCreateButtonState()
  }
  
  private func configureTrackerType() {
    if isRegularNewTracker {
      options = [.category, .schedule]
    } else {
      options = [.category]
      selectedSchedule = Set(WeekDay.allCases)
    }
  }
  
  private func updateCreateButtonState() {
    guard selectedCategory != nil,
          selectedEmojiIndex != nil,
          selectedColorIndex != nil,
          !selectedSchedule.isEmpty,
          let textTitle, !textTitle.isEmpty else {
      onCreateButtonStateChange?(false)
      return
    }
    
    onCreateButtonStateChange?(true)
  }
  
  private func notifyOptionUpdate(_ option: Option) {
    guard let index = options.firstIndex(of: option) else { return }
    onOptionUpdate?(index)
  }
}
