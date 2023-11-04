//
// Created by Alexey Nenastev on 27.10.23.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import SwiftUI
import OSLog

enum TagState {
  case equal
  case notEqual
  case none
}

enum TagButtonAction {
  case equal
  case notEqual

  var opposite: Self {
    switch self {
    case .equal : return .notEqual
    case .notEqual : return .equal
    }
  }

  var uiName: String {
    switch self {
    case .equal : return "Show"
    case .notEqual : return "Hide"
    }
  }

  var color: Color {
    switch self {
    case .equal :  return .accentColor
    case .notEqual :  return .black
    }
  }
}

struct TagLabel: View {
  var tagLabel: String
  var count: Int = 0
  var state: TagState
  @State private var textSize: CGSize = .zero

  private var color: Color {
    switch state {
    case .notEqual:
      return TagButtonAction.notEqual.color
    case .equal:
      return TagButtonAction.equal.color
    case .none:
      return .gray.opacity(count > 0 ? 1 : 0.5)
    }
  }

  private var showCount: Bool {
    state != .notEqual && count > 0
  }

  var body: some View {
    HStack(spacing: 4) {
        if state == .notEqual {
          Text("≠")
          Divider()
            .frame(height: 12)
        }
        Text(tagLabel)

        if state != .notEqual && count > 0 {
          Divider()
            .frame(height: 12)
          Text("\(count)")
            .fontWeight(.light)
        }
      }
    .padding(.vertical, 10)
    .padding(.horizontal, horizontalPadding)
    .foregroundColor(color)
    .overlay(
      RoundedRectangle(cornerRadius: 14)
        .stroke(color, style: StrokeStyle(lineWidth: 1, dash: dash))
    )
  }

  private var horizontalPadding: CGFloat {
    if state == .notEqual { return 12 }
    if count == 0 { return 21 }
    if count < 10 { return 12 } else if count < 100 { return 9} else { return 6 }
  }

  private var dash: [CGFloat] {
    if state == .notEqual || count > 0 {
      return []
    } else {
      return [5]
    }
  }
}

@available(iOS 15.0, *)
struct TagButton<T: Hashable>: View {
  var tagCollection: WritableKeyPath<LogFilter.Tags, Set<T>>
  var statistic: KeyPath<LogFilter.TagsStatistic, [T: Int]>
  var tag: T
  var label: (T) -> String = { "\($0)" }

  private var count: Int {
    model.filterStatistic[keyPath: statistic][tag] ?? 0
  }
  private var state: TagState {
    model.filter.tagState(tagCollection, value: tag)
  }

  @EnvironmentObject var model: LogViewModel
  @Environment(\.tagButtonAction) var action

  var body: some View {
    Button(action: {
      if state != .none {
        model.filter.remove(tagCollection, value: tag)
      } else {
        switch action {
        case .equal:
          model.filter.setEqual(tagCollection, value: tag)
        case .notEqual:
          model.filter.setNotEqual(tagCollection, value: tag)
        }
      }
    }, label: {
      TagLabel(tagLabel: label(tag),
               count: count,
               state: state)
    })
    .animation(.easeIn, value: count)
    .animation(/*@START_MENU_TOKEN@*/.easeIn/*@END_MENU_TOKEN@*/, value: state)
  }
}

@available(iOS 15.0, *)
extension TagButton where T == String {
  static func subsystem(tag: T) -> Self {
    TagButton(tagCollection: \.sybsytems,
              statistic: \.sybsytems,
              tag: tag)
  }

  static func category(tag: T) -> Self {
    TagButton(tagCollection: \.categories,
              statistic: \.categories,
              tag: tag)
  }

  static func sender(tag: T) -> Self {
    TagButton(tagCollection: \.senders,
              statistic: \.senders,
              tag: tag)
  }
}

@available(iOS 15.0, *)
extension TagButton where T == OSLogEntryLog.Level.RawValue {
  static func level(tag: T) -> Self {
    TagButton(tagCollection: \.levels,
              statistic: \.levels,
              tag: tag,
              label: { OSLogEntryLog.Level(rawValue: $0)!.description })
  }
}

struct TagButtonActionKey: EnvironmentKey {
  static let defaultValue: TagButtonAction = .equal
}

extension EnvironmentValues {
  var tagButtonAction: TagButtonAction {
    get { self[TagButtonActionKey.self] }
    set { self[TagButtonActionKey.self] = newValue }
  }
}

@available(iOS 15.0, *)
struct TagView_Previews: PreviewProvider {

  struct ButtonPreview: View {
    @StateObject var model = LogViewModel()

    var body: some View {
      VStack {
        TagButton.category(tag: "My Category1")
        TagButton.category(tag: "My Category")
          .environment(\.tagButtonAction, .notEqual)
      }
      .environmentObject(model)
    }
  }

  static var previews: some View {
    VStack {
      TagLabel(tagLabel: "asd", count: 1, state: .equal)
      TagLabel(tagLabel: "asd", count: 11, state: .equal)
      TagLabel(tagLabel: "asd", count: 111, state: .equal)
      TagLabel(tagLabel: "asd", state: .notEqual)
      TagLabel(tagLabel: "asd", state: .none)
      TagLabel(tagLabel: "asd", count: 1, state: .none)
      TagLabel(tagLabel: "asd", count: 11, state: .none)
      TagLabel(tagLabel: "asd", count: 111, state: .none)
    }

    ButtonPreview()
  }
}
