//
// Created by Alexey Nenastev on 27.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import Foundation
import SwiftUI
import OSLog
import Combine
import os

private let logger = Logger(subsystem: "com.logview", category: "logger")

@available(iOS 15.0, *)
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
  @Published var searchText: String = ""

  var filteredAndSearched: [OSLogEntryLog] {
    filtered.filter { log in
      searchText.isEmpty || log.composedMessage.lowercased().contains(searchText.lowercased())
    }
  }

  private var lastDate: Date?

  @Published var filter: LogFilter = .empty {
    didSet {
      var stat = LogFilter.TagsStatistic()
      filtered = filter.filter(entries: logs, statistic: &stat)
      filterStatistic = stat
    }
  }

  private static let store = try? OSLogStore(scope: .currentProcessIdentifier)

  init() {
    load()
  }

  private func fetchLogs() {
    guard let store = LogViewModel.store else { return }

    var position: OSLogPosition?
    if let lastDate = lastDate {
      let ti = lastDate.timeIntervalSinceNow
      position = store.position(timeIntervalSinceEnd: ti)
    }

    do {

      let entries = try store.getEntries(at: position, matching: LogView.predicate)

      let filteredEntries = entries.compactMap { entry -> OSLogEntryLog? in
        guard let log = entry as? OSLogEntryLog, 
                log.date.timeIntervalSince1970 > (lastDate?.timeIntervalSince1970 ?? 0 ),
              LogView.filterEntries(log) else { return nil }
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

  func clear() {
    logs = []
  }
}

@available(iOS 15.0, *)
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

@available(iOS 15.0, *)
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
    case .notice: return .mint
    case .error: return .red
    case .fault: return .black
    default: return .gray
    }
  }
}
