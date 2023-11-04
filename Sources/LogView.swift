//
//  LogsView.swift
//  FBS
//
//  Created by Alexey Nenastev on 27.10.23..
//  Copyright © 2023 Data Driven Lab. All rights reserved.
//

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

public struct LogView: View {

  @StateObject private var model = LogViewModel()
  @State private var filterPresented = false
  @State private var selected: OSLogEntryLog?
  @AppStorage("logs.isreversed") private var isReversed: Bool = false

  private func grouped(index: Int) -> Bool {
    let entry = model.filtered[index]
    var grouped = false
    if index > 0 {
      let prev = model.filtered[index-1]
      grouped = entry.subsystem == prev.subsystem &&
      entry.sender == prev.sender &&
      entry.category == prev.category
    }
    return grouped
  }

  public var body: some View {
    Group {
      if model.isLoading && model.logsIsEmpty {
        ProgressView()
      } else {
        ScrollView {
          LazyVStack(alignment: .leading) {
            ForEach(model.filtered.indices.reversed(), id: \.self) { index in
              LogViewItem(log: model.filtered[index],
                           grouped: grouped(index: index),
                           onTap: { selected = $0 })
              .isReversed(isReversed)

            }
          }
        }
        .refreshable {
          model.load()
        }
        .isReversed(isReversed)
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
          Image(systemName: "tag")
        }
      }

      ToolbarItem(placement: .navigationBarLeading) {
        Button {
          isReversed.toggle()
        } label: {
          Image(systemName: isReversed ? "platter.filled.top.and.arrow.up.iphone" : "platter.filled.bottom.and.arrow.down.iphone")
        }
      }

      ToolbarItem(placement: .navigationBarTrailing) {
        ReloadButton(isLoading: $model.isLoading, reload: model.load)
      }
    }
    .environmentObject(model)
  }
}

fileprivate extension View {
  func isReversed(_ value: Bool) -> some View {
    rotationEffect(value ? .radians(.pi) : .zero)
      .scaleEffect(x: value ? -1 : 1, y: 1, anchor: .center)
  }
}

extension OSLogEntryLog: Identifiable {
  public var id: String {
    self.description
  }
}

struct LogsView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      LogView()
    }
  }
}
