//
// Created by Alexey Nenastev on 27.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import Foundation
import OSLog

@available(iOS 15.0, *)
extension LogView {

  /// Predicate for feathing entries from store
  public static var predicate: NSPredicate?


  public typealias FilterEntries = (OSLogEntryLog) -> Bool

  /// Additional filter after fetcnig from store. Not all condition can be used when filter with predicate.
  /// This additional opportunity to get wished logs
  public static var filterEntries: FilterEntries = {
    ($0.category == "" && $0.sender == "FBS") || // основной таргет приложения
    [Bundle.main.bundleIdentifier!,
     "com.appsflyer.lib",
     "com.apple.runtime-issues"].contains($0.subsystem) // разрешенные подсистемы
  }
}

public extension NSPredicate {
  static func subystemIn(_ values: [String], orNil: Bool = true) -> NSPredicate {
    NSPredicate(format: "\(orNil ? "subsystem == nil OR" : "") subsystem in $LIST")
      .withSubstitutionVariables(["LIST" : values])
  }
}
