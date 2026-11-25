//
//  TrackerRecordStoreSpy.swift
//  TrackerApp
//
//  Created by Данил on 24/11/2026.
//

@testable import TrackerApp
import Foundation

final class TrackerRecordStoreSpy: NSObject, TrackerRecordStoreProtocol {
  weak var delegate: TrackerRecordStoreDelegate?
  var records: [TrackerRecord] = []
  
  func setRecords(records: [TrackerRecord]) {
    self.records = records
  }
  
  func addNewTrackerRecord(trackerRecord: TrackerRecord) throws {
  }
  
  func removeTrackerRecord(trackerRecord: TrackerRecord) throws {
    
  }
}
