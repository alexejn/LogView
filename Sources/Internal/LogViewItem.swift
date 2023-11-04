//
// Created by Alexey Nenastev on 27.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import Foundation
import SwiftUI
import OSLog
import os

@available(iOS 15.0, *)
struct LogViewItem: View {

  let log: OSLogEntryLog
  let grouped: Bool
  var onTap: (OSLogEntryLog) -> Void


  var body: some View {
    let color = log.level.color.opacity(0.2)
    VStack(alignment: .leading, spacing: 0) {
      if grouped {
        Text(log.date.logTimeString)
          .fontWeight(.ultraLight)
          .font(.footnote.monospaced())
          .foregroundColor(log.level.color)
      } else {
        HStack(alignment: .firstTextBaseline) {
          Text(log.date.logTimeString)
            .font(.footnote.monospaced())
          Text("•")
          Text(log.category)
            .fontWeight(.medium)
          Spacer()
          Text(log.subsystem)
            .fontWeight(.ultraLight)
            .lineLimit(1)
        }
        .padding(.vertical, 4)
        .background(color
          .padding(.horizontal, -10)
        )
        .font(.footnote)
      }

      Spacer()
        .frame(height: 6)

      Button {
        onTap(log)
      } label: {
        Text(log.composedMessage)
          .font(.body)
          .foregroundColor(.primary)
          .lineLimit(10)
          .multilineTextAlignment(.leading)
          .font(.callout)
      }

      Spacer()
        .frame(height: 6)

      if !grouped {
        HStack(alignment: .firstTextBaseline) {
          Image(systemName: "building.columns")
          Text(log.sender)
          Text("•")
          Text(log.level.description)
          Spacer()
        }
        .font(.footnote)
        .opacity(0.5)
      }

      Spacer()
        .frame(height: 10)
    }
    .padding(.horizontal, 10)
    .foregroundColor(.primary)
  }
}
