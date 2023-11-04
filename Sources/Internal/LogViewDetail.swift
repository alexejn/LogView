//
//  LogViewDetail.swift
//  fbsDebugView
//
//  Created by Alexey Nenastev on 2.11.23..
//  Copyright © 2023 Data Driven Lab. All rights reserved.
//

import Foundation
import SwiftUI
import OSLog
import os

struct TagButtonActionPicker: View {
  @Binding var tagButtonAction: TagButtonAction
  var body: some View {

    HStack {
      Button {
        tagButtonAction = .equal
      } label: {
        Text("Show")
      }
      .foregroundColor(TagButtonAction.equal.color)
      .padding(10)
      .overlay(
        RoundedRectangle(cornerRadius: 14)
          .stroke(TagButtonAction.equal.color, style: StrokeStyle(lineWidth: 1))
      )
      .opacity(tagButtonAction == .equal ? 1 : 0.3)

      Button {
        tagButtonAction = .notEqual
      } label: {
        Text("Hide")
      }
      .foregroundColor(TagButtonAction.notEqual.color)
      .padding(10)
      .overlay(
        RoundedRectangle(cornerRadius: 14)
          .stroke(TagButtonAction.notEqual.color, style: StrokeStyle(lineWidth: 1))
      )
      .opacity(tagButtonAction == .notEqual ? 1 : 0.3)
    }
    .animation(.easeIn, value: tagButtonAction)
    .padding(.vertical, 4)
  }
}

struct LogViewDetail: View {

  let logMessage: String
  let category: String
  let subsystem: String
  let sender: String
  let level: Int
  var shareItem: String

  @State var tagButtonAction: TagButtonAction = .equal

  @EnvironmentObject var model: LogViewModel

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(spacing: 15) {
        TagButtonActionPicker(tagButtonAction: $tagButtonAction)
        Divider()
          .frame(height: 20)
        Button {
          model.filter.remove(\.categories, value: category)
          model.filter.remove(\.senders, value: sender)
          model.filter.remove(\.levels, value: level)
          model.filter.remove(\.sybsytems, value: subsystem)
        } label: {
          Text("Clear")
        }
        .buttonStyle(.bordered)

        Spacer()

        if #available(iOS 16.0, *) {
          ShareLink(item: shareItem) {
            Image(systemName: "square.and.arrow.up")
          }
        }
      }
      .padding(.horizontal)

      VFlow(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 8) {
        TagButton.subsystem(tag: subsystem)
        TagButton.category(tag: category)
        TagButton.sender(tag: sender)
        TagButton.level(tag: level)
      }
      .padding(.horizontal)
      .environment(\.tagButtonAction, tagButtonAction)
      Divider()

      ScrollView {
        Text(logMessage)
          .lineLimit(nil)
          .multilineTextAlignment(.leading)
          .padding(.horizontal)
      }
    }
    .padding(.top)
  }
}

extension LogViewDetail {
  init(log: OSLogEntryLog) {
    self.logMessage = log.composedMessage
    self.subsystem = log.subsystem
    self.sender = log.sender
    self.category = log.category
    self.level = log.level.rawValue
    self.shareItem = "\(log.date.logTimeString)|\(log.category)|\(log.subsystem)\n\(log.composedMessage)\n\(log.sender)|\(log.level.description)"
  }
}

struct LogViewDetail_Previews: PreviewProvider {
  static var previews: some View {
    Text("aa")
      .sheet(isPresented: .constant(true), content: {
        NavigationView {
          LogViewDetail(logMessage: "Message Message Message Message Message Message",
                        category: "category",
                        subsystem: "subsystem",
                        sender: "sender",
                        level: 2,
                        shareItem: "Message"
          )
          .environmentObject(LogViewModel())
        }
      })
  }
}
