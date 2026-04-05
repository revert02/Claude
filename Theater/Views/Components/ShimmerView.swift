import SwiftUI

struct ShimmerView: View {
    @State private var isAnimating = false

    var body: some View {
        LinearGradient(
            colors: [
                TheaterTheme.surfaceLight.opacity(0.4),
                TheaterTheme.surfaceLight.opacity(0.8),
                TheaterTheme.surfaceLight.opacity(0.4),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .offset(x: isAnimating ? 200 : -200)
        .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: isAnimating)
        .onAppear { isAnimating = true }
        .clipped()
    }
}

struct ShimmerPosterCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: TheaterTheme.spacingXS) {
            ShimmerView()
                .posterStyle()

            ShimmerView()
                .frame(width: TheaterTheme.posterWidth, height: 12)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }
}

struct ShimmerCategoryRow: View {
    var body: some View {
        VStack(alignment: .leading, spacing: TheaterTheme.spacingSM) {
            ShimmerView()
                .frame(width: 150, height: 20)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .padding(.horizontal, TheaterTheme.spacingMD)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: TheaterTheme.spacingSM) {
                    ForEach(0..<5, id: \.self) { _ in
                        ShimmerPosterCard()
                    }
                }
                .padding(.horizontal, TheaterTheme.spacingMD)
            }
        }
    }
}
