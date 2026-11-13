//
//  TrackerCategoryStore.swift
//  TrackerApp
//
//  Created by Данил on 12/11/2026.
//

import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
  func trackerCategoryStoreDidUpdate()
}

final class TrackerCategoryStore: NSObject {
  weak var delegate: TrackerCategoryStoreDelegate?
  var categories: [TrackerCategory] {
    (fetchedResultsController.fetchedObjects ?? []).compactMap(getTrackerCategoryModel)
  }
  private let context: NSManagedObjectContext
  private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
    let request = TrackerCategoryCoreData.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
    
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
      assertionFailure("Не удалось загрузить категории: \(error)")
    }
    return controller
  }()
  
  init(context: NSManagedObjectContext) {
    self.context = context
    super.init()
  }
  
  convenience override init() {
    self.init(context: CoreDataStack.shared.viewContext)
  }
  
  func addNewCategory(with category: TrackerCategory) throws {
    let object = TrackerCategoryCoreData(context: context)
    object.title = category.title
    
    try context.save()
  }
  
  private func getTrackerCategoryModel(object: TrackerCategoryCoreData) -> TrackerCategory? {
    guard let title = object.title else { return nil }
    let trackers = (object.trackers as? Set<TrackerCoreData> ?? [])
      .compactMap { TrackerStore.getTrackerModel(from: $0) }
        .sorted { $0.name < $1.name }
    return TrackerCategory(title: title, trackers: trackers)
  }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    delegate?.trackerCategoryStoreDidUpdate()
  }
}
