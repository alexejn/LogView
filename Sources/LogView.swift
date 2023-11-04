//
// Created by Alexey Nenastev on 27.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import Foundation
import SwiftUI
import OSLog
import os

private extension View {
  func sheetDefaultSettings() -> some View {
    if #available(iOS 16.0, *) {
      return presentationDetents([.large])
    } else { return self }
  }
}

@available(iOS 15.0, *)
public struct LogView: View {

  @StateObject private var model = LogViewModel()
  @State private var filterPresented = false
  @State private var selected: OSLogEntryLog?

  private func grouped(index: Int, items: [OSLogEntryLog]) -> Bool {
    let entry = items[index]
    var grouped = false
    if index > 0 && index < items.count - 1  {
      let prev = items[index+1]
      grouped = entry.subsystem == prev.subsystem &&
      entry.sender == prev.sender &&
      entry.category == prev.category
    }
    return grouped
  }

  public init() {}
  
  public var body: some View {
    Group {
      if model.isLoading && model.logsIsEmpty {
        ProgressView()
      } else {
        ScrollView {
          LazyVStack(alignment: .leading) {
            let items = model.filteredAndSearched
            ForEach(items.indices.reversed(), id: \.self) { index in
              LogViewItem(log: items[index],
                          grouped: grouped(index: index, items: items),
                          onTap: { selected = $0 })

            }
          }
        }
        .refreshable {
          model.load()
        }
      }
    }
    .sheet(item: $selected) { log in
      LogViewDetail(log: log)
        .environmentObject(model)
    }
    .sheet(isPresented: $filterPresented, content: {
      FilterView()
        .environmentObject(model)
        .sheetDefaultSettings()
    })
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          filterPresented.toggle()
        } label: {
          Image(systemName: model.filter != .empty ? "tag.fill" : "tag")
        }
      }

      ToolbarItem(placement: .navigationBarLeading) {
        Button {
          model.clear()
        } label: {
          Image(systemName: "trash")
        }
      }

      ToolbarItem(placement: .navigationBarLeading) {
        Text("\(model.filteredAndSearched.count)")
          .fontWeight(.ultraLight)
      }

      ToolbarItem(placement: .navigationBarTrailing) {
        ReloadButton(isLoading: $model.isLoading, reload: model.load)
      }
    }
    .environmentObject(model)
    .searchable(text: $model.searchText, placement: .sidebar)
    .navigationBarTitleDisplayMode(.inline)
  }
}

fileprivate extension View {
  func isReversed(_ value: Bool) -> some View {
    rotationEffect(value ? .radians(.pi) : .zero)
      .scaleEffect(x: value ? -1 : 1, y: 1, anchor: .center)
  }
}

@available(iOS 15.0, *)
extension OSLogEntryLog: Identifiable {
  public var id: String {
    self.description
  }
}

@available(iOS 15.0, *)
struct LogsView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      LogView()
    }
  }
}

