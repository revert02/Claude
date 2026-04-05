import SwiftUI

extension View {
    func theaterBackground() -> some View {
        self.background(TheaterTheme.background)
    }

    func posterStyle(width: CGFloat = TheaterTheme.posterWidth, height: CGFloat = TheaterTheme.posterHeight) -> some View {
        self
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: TheaterTheme.cornerRadiusSM))
    }

    func cardStyle() -> some View {
        self
            .background(TheaterTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: TheaterTheme.cornerRadiusMD))
    }
}
