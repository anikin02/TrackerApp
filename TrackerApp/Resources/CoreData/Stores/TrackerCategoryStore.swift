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

protocol TrackerCategoryStoreProtocol: AnyObject {
  var delegate: TrackerCategoryStoreDelegate? { get set }
  var categories: [TrackerCategory] { get }
  
  func addNewCategory(with category: TrackerCategory) throws
  func updateCategory(oldTitle: String, newTitle: String) throws
  func deleteCategory(title: String) throws
  func fetchCategory(title: String) throws -> TrackerCategoryCoreData?
}

final class TrackerCategoryStore: NSObject, TrackerCategoryStoreProtocol {
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
  
  func updateCategory(oldTitle: String, newTitle: String) throws {
    guard let object = try fetchCategory(title: oldTitle) else {
      return
    }

    object.title = newTitle

    try context.save()
  }

  func deleteCategory(title: String) throws {
    guard let object = try fetchCategory(title: title) else {
      return
    }
    
    context.delete(object)
    try context.save()
  }
  
  func fetchCategory(title: String) throws -> TrackerCategoryCoreData? {
    let request = TrackerCategoryCoreData.fetchRequest()
    request.predicate = NSPredicate(format: "title == %@", title)
    request.fetchLimit = 1
    return try context.fetch(request).first
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
