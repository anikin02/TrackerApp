//
//  TrackerStore.swift
//  TrackerApp
//
//  Created by Данил on 12/11/2026.
//

import CoreData

protocol TrackerStoreDelegate: AnyObject {
  func trackerStoreDidUpdate()
}

final class TrackerStore: NSObject {
  weak var delegate: TrackerStoreDelegate?
  
  private let context: NSManagedObjectContext
  private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
    let request = TrackerCoreData.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    let controller = NSFetchedResultsController(
      fetchRequest: request,
      managedObjectContext: context,
      sectionNameKeyPath: nil,
      cacheName: nil
    )
    controller.delegate = self
    do {
      try controller.performFetch()
    } catch {
      assertionFailure("Не удалось загрузить трекеры: \(error)")
    }
    return controller
  }()
  
  init(context: NSManagedObjectContext) {
    self.context = context
    super.init()
    _ = fetchedResultsController
  }
  
  convenience override init() {
    self.init(context: CoreDataStack.shared.viewContext)
  }
  
  func addNewTracker(with tracker: Tracker, to categoryTitle: String) throws {
    let object = TrackerCoreData(context: context)
    object.id = tracker.id
    object.name = tracker.name
    object.emoji = tracker.emoji
    object.hexColor = tracker.hexColor
    object.isRegular = tracker.isRegular
    object.schedule = try? JSONEncoder().encode(tracker.schedule)
    object.category = try fetchCategory(title: categoryTitle)
    
    try context.save()
  }
  
  private func fetchCategory(title: String) throws -> TrackerCategoryCoreData? {
    let request = TrackerCategoryCoreData.fetchRequest()
    request.predicate = NSPredicate(format: "title == %@", title)
    request.fetchLimit = 1
    return try context.fetch(request).first
  }
  
  static func getTrackerModel(from object: TrackerCoreData) -> Tracker? {
    guard let id = object.id,
          let name = object.name,
          let emoji = object.emoji,
          let hexColor = object.hexColor else { return nil }
    let schedule = (object.schedule.flatMap { try? JSONDecoder().decode(Set<WeekDay>.self, from: $0) }) ?? []
    return Tracker(id: id,
                   name: name,
                   hexColor: hexColor,
                   emoji: emoji,
                   schedule: schedule,
                   isRegular: object.isRegular)
  }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    delegate?.trackerStoreDidUpdate()
  }
}
