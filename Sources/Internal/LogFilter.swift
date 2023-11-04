//
// Created by Alexey Nenastev on 27.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import Foundation
import OSLog

@available(iOS 15.0, *)
struct LogFilter: Codable {
  struct Tags: Codable {
    var levels = Set<OSLogEntryLog.Level.RawValue>()
    var categories = Set<String>()
    var sybsytems = Set<String>()
    var senders = Set<String>()
  }

  static var all: Tags = Tags()
  var equals: Tags = Tags()
  var notEquals: Tags = Tags()

  struct TagsStatistic: Codable {
    var levels = [OSLogEntryLog.Level.RawValue: Int]()
    var categories = [String: Int]()
    var sybsytems = [String: Int]()
    var senders = [String: Int]()
  }

  private typealias Predicate = (OSLogEntryLog) -> Bool

  private func predicate<T: Equatable>(tag: KeyPath<Tags, Set<T>>, logField: KeyPath<OSLogEntryLog, T>) -> Predicate {

    let filter = equals[keyPath: tag]
    let blocked = notEquals[keyPath: tag]

    if !filter.isEmpty {
      return { filter.contains($0[keyPath: logField]) }
    } else if !blocked.isEmpty {
      return { !blocked.contains($0[keyPath: logField]) }
    } else {
      return { _ in true }
    }
  }

  func filter(entries: [OSLogEntryLog], statistic: inout TagsStatistic) -> [OSLogEntryLog] {

    let categoryPredicate = predicate(tag: \.categories, logField: \.category)
    let sybsytemsPredicate = predicate(tag: \.sybsytems, logField: \.subsystem)
    let sendersPredicate = predicate(tag: \.senders, logField: \.sender)
    let levelsPredicate = predicate(tag: \.levels, logField: \.level.rawValue)

    let logs = entries.filter { log in
      let filter =  categoryPredicate(log) &&
      sybsytemsPredicate(log) &&
      sendersPredicate(log) &&
      levelsPredicate(log)
      if filter {
        statistic.categories.plus(to: log.category)
        statistic.sybsytems.plus(to: log.subsystem)
        statistic.senders.plus(to: log.sender)
        statistic.levels.plus(to: log.level.rawValue)
      }
      return filter
    }

    return logs
  }

  static var empty = LogFilter()

  func tagState<T>(_ tagCollection: WritableKeyPath<LogFilter.Tags, Set<T>>, value: T) -> TagState {
    if notEquals[keyPath: tagCollection].contains(value) {
      return .notEqual
    } else if equals[keyPath: tagCollection].contains(value) {
      return .equal
    } else {
      return .none
    }
  }

  mutating func setEqual<T>(_ tagCollection: WritableKeyPath<LogFilter.Tags, Set<T>>, value: T) {
    equals[keyPath: tagCollection].insert(value)
    notEquals[keyPath: tagCollection].remove(value)
  }

  mutating func setNotEqual<T>(_ tagCollection: WritableKeyPath<LogFilter.Tags, Set<T>>, value: T) {
    notEquals[keyPath: tagCollection].insert(value)
    equals[keyPath: tagCollection].remove(value)
  }

  mutating func remove<T>(_ tagCollection: WritableKeyPath<LogFilter.Tags, Set<T>>, value: T) {
    notEquals[keyPath: tagCollection].remove(value)
    equals[keyPath: tagCollection].remove(value)
  }
}

@available(iOS 15.0, *)
extension OSLogEntryLog.Level {
  static var all: [OSLogEntryLog.Level] {
    [.debug, .info, .notice, .error, .fault]
  }
}

@available(iOS 15.0, *)
extension Set where Element == OSLogEntryLog.Level.RawValue {
  static var all: Set<Element> {
    Set(OSLogEntryLog.Level.all.map { $0.rawValue })
  }
}

extension Dictionary where Value == Int {
  mutating func plus(value: Int = 1, to key: Key) {
    self[key] = (self[key] ?? 0) + value
  }
}
