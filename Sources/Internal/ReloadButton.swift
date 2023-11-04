//
//  File.swift
//  
//
//  Created by Alexey Nenastev on 4.11.23..
//

import SwiftUI

struct ReloadButton: View {

  @State private var isReloadRotating = 0.0

  @Binding var isLoading: Bool
  var reload: () -> Void

  var body: some View {
    Button(action: reload) {
      Image(systemName: "arrow.triangle.2.circlepath")
        .rotationEffect(.degrees(isReloadRotating))
    }
    .disabled(isLoading)
    .onAppear { animateIfNeed(isLoaging: isLoading) }
    .onChange(of: isLoading, perform: { value in
      print("of change \(value)")
      animateIfNeed(isLoaging: value)
    })
  }

  private func animateIfNeed(isLoaging: Bool) {
    if isLoading {
      withAnimation(.linear(duration: 3)
        .repeatForever(autoreverses: false)) {
          isReloadRotating = 360.0
        }
    } else {
      withAnimation(.linear(duration: 0)) {
        isReloadRotating = 0
      }
    }
  }
}
