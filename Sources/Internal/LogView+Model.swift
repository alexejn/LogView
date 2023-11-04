//
//  LogsViewModel.swift
//  fbsDebugView
//
//  Created by Alexey Nenastev on 27.10.23..
//  Copyright © 2023 Data Driven Lab. All rights reserved.
//

import Foundation
import SwiftUI
import OSLog
import Combine
import os

private let logger = Logger(subsystem: "com.logview", category: "logger")

final class LogViewModel: ObservableObject {

  private var logs: [OSLogEntryLog] = [] {
    didSet {
      var stat = LogFilter.TagsStatistic()
      filtered = filter.filter(entries: logs, statistic: &stat)
      filterStatistic = stat
    }
  }

  var logsIsEmpty: Bool {
    logs.isEmpty
  }

  @Published var filtered: [OSLogEntryLog] = []
  @Published var filterStatistic = LogFilter.TagsStatistic()
  @Published var isLoading: Bool = false

  private var lastDate: Date?
  @Published var filter: LogFilter = .empty {
    didSet {
      var stat = LogFilter.TagsStatistic()
      filtered = filter.filter(entries: logs, statistic: &stat)
      filterStatistic = stat
    }
  }

  public static var predicate: NSPredicate? = NSPredicate.subystemIn([Bundle.main.bundleIdentifier!,
                                                                      "com.appsflyer.lib",
                                                                      "com.apple.runtime-issues"])
  public typealias FilterEntries = (OSLogEntryLog) -> Bool

  public static var filterEntries: FilterEntries = {
    ($0.category == "" && $0.sender == "FBS") || // основной таргет приложения
    [Bundle.main.bundleIdentifier!,
     "com.appsflyer.lib",
     "com.apple.runtime-issues"].contains($0.subsystem) // разрешенные подсистемы
  }

  private let store = try? OSLogStore(scope: .currentProcessIdentifier)

  init() {
    load()
  }

  private func fetchLogs() {
    guard let store = store else { return }

    var position: OSLogPosition?
    if let lastDate = lastDate {
      let ti = lastDate.timeIntervalSinceNow
      position = store.position(timeIntervalSinceEnd: ti)
    }

    do {

      let entries = try store.getEntries(at: position, matching: Self.predicate)

      let filteredEntries = entries.compactMap { entry -> OSLogEntryLog? in
        guard let log = entry as? OSLogEntryLog, 
                log.date.timeIntervalSince1970 > (lastDate?.timeIntervalSince1970 ?? 0 ),
                Self.filterEntries(log) else { return nil }
        return log
      }

      for log in filteredEntries {
        LogFilter.all.categories.insert(log.category)
        LogFilter.all.sybsytems.insert(log.subsystem)
        LogFilter.all.levels.insert(log.level.rawValue)
        LogFilter.all.senders.insert(log.sender)
      }

      Task { @MainActor in
        self.logs.append(contentsOf: filteredEntries)
        self.isLoading = false
        self.lastDate = self.logs.last?.date
      }
    } catch {
      logger.error("Can't fetch entries: \(error)")
    }
  }

  func load() {
    isLoading = true
    DispatchQueue.global(qos: .userInteractive).async { [weak self] in
      self?.fetchLogs()
    }
  }
}

extension Date {
  var logTimeString: String {
    formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute().second().secondFraction(.fractional(3)))
  }
}

extension Sequence {
  func uniqueMap<K: Hashable>(_ kp: KeyPath<Element, K>) -> Set<K> {
    let mapped = map { $0[keyPath: kp]}
    return Set(mapped)
  }
}

extension Sequence {
  func uniqueMap(_ kp: KeyPath<Element, String>) -> Set<String> {
    let mapped = map { $0[keyPath: kp] }
    return Set(mapped.filter { $0 != "" })
  }
}

extension OSLogEntryLog.Level {
  var description: String {
    switch self {
    case .debug: return "debug"
    case .info: return "info"
    case .notice: return "notice"
    case .error: return "error"
    case .fault: return "fault"
    default: return ""
    }
  }

  var color: Color {
    switch self {
    case .debug: return .gray
    case .info: return .blue
    case .notice: return .blue
    case .error: return .red
    case .fault: return .black
    default: return .gray
    }
  }
}
