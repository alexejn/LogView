import SwiftUI

struct HFlow<Content>: View
where Content: View {
    public var body: Flow<Content>
}

extension HFlow {
    /// A view that arranges its children in a horizontal flow.
    ///
    /// This view returns a flexible preferred height to its parent layout.
    ///
    /// - Parameters:
    ///   - alignment: The guide for aligning the subviews in this flow. This
    ///     guide has the same vertical screen coordinate for every child view.
    ///   - spacing: The distance between adjacent subviews, or `nil` if you
    ///     want the flow to choose a default distance for each pair of
    ///     subviews.
    ///   - content: A view builder that creates the content of this flow.
    init(alignment: VerticalAlignment = .center,
         spacing: CGFloat? = nil,
         @ViewBuilder content: @escaping () -> Content) {
        self.body = Flow(.horizontal,
                         alignment: Alignment(horizontal: .leading, vertical: alignment),
                         spacing: spacing,
                         content: content)
    }

    /// A view that arranges its children in a horizontal flow.
    ///
    /// This view returns a flexible preferred height to its parent layout.
    ///
    /// - Parameters:
    ///   - alignment: The guide for aligning the subviews in this flow. This
    ///     guide has the same vertical screen coordinate for every child view.
    ///   - horizontalSpacing: The distance between horizontally adjacent
    ///     subviews, or `nil` if you want the flow to choose a default distance
    ///     for each pair of subviews.
    ///   - verticalSpacing: The distance between vertically adjacent
    ///     subviews, or `nil` if you want the flow to choose a default distance
    ///     for each pair of subviews.
    ///   - content: A view builder that creates the content of this flow.
    init(alignment: VerticalAlignment = .center,
         horizontalSpacing: CGFloat? = nil,
         verticalSpacing: CGFloat? = nil,
         @ViewBuilder content: @escaping () -> Content) {
        self.body = Flow(.horizontal,
                         alignment: Alignment(horizontal: .leading, vertical: alignment),
                         horizontalSpacing: horizontalSpacing,
                         verticalSpacing: verticalSpacing,
                         content: content)
    }
}
