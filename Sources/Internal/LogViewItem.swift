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
  @EnvironmentObject var model: LogViewModel

  var body: some View {
    let color = log.level.color.opacity(0.2)
    VStack(alignment: .leading, spacing: 0) {
      if grouped {
        Text(log.date.logTimeString)
          .fontWeight(.ultraLight)
          .font(.footnote.monospaced())
          .foregroundColor(log.level.color)
      } else {
        HStack(alignment: .center, spacing: 20) {
          Text(log.date.logTimeString)
            .font(.footnote.monospaced())
            .padding(.vertical, 4)
            .frame(height: 24)
            .background(color.padding(.horizontal, -10))
          Text(log.category)
            .fontWeight(.medium)
            .padding(.vertical, 4)
            .frame(height: 24)
            .background(color.padding(.horizontal, -9))
          HStack {
            Spacer()
            Text(log.subsystem)
              .fontWeight(.light)
              .lineLimit(1)
              .padding(.vertical, 4)
          }
          .frame(height: 24)
          .background(color.padding(.horizontal, -10))
        }
        .font(.footnote)
      }

      Spacer()
        .frame(height: 6)

      Button {
        onTap(log)
      } label: {
          Text(text)
            .tint(Color.red)
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

  var text: AttributedString {
    if #available(iOS 16.0, *) {
      if !model.searchText.isEmpty,
         let attr = try? AttributedString(markdown: log.composedMessage.replacing(model.searchText, with: "[\(model.searchText)](\(model.searchText))"))  {
        return attr
      } else {
        return AttributedString(log.composedMessage)
      }
    } else {
      return AttributedString(log.composedMessage)
    }
  }
}

public extension View {
  func frameSize() -> some View {
    modifier(FrameSize())
  }

  var asAnyView: AnyView {
    AnyView(self)
  }
}

private struct FrameSize: ViewModifier {
  static let color: Color = .blue

  func body(content: Content) -> some View {
    content
      .overlay(GeometryReader(content: overlay(for:)))
  }

  func overlay(for geometry: GeometryProxy) -> some View {
    ZStack(
      alignment: Alignment(horizontal: .trailing, vertical: .top)
    ) {
      Rectangle()
        .strokeBorder(
          style: StrokeStyle(lineWidth: 1, dash: [5])
        )
        .foregroundColor(FrameSize.color)
      Text("\(Int(geometry.size.width))x\(Int(geometry.size.height))")
        .font(.caption2)
        .foregroundColor(FrameSize.color)
        .padding(2)
    }
  }
}
