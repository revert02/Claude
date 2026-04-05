import SwiftUI

struct RatingBadgeView: View {
    let score: Double
    let label: String
    var maxScore: Double = 10.0

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(TheaterTheme.surfaceLight, lineWidth: 3)
                    .frame(width: 50, height: 50)

                Circle()
                    .trim(from: 0, to: score / maxScore)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))

                Text(String(format: "%.1f", score))
                    .font(TheaterTheme.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(TheaterTheme.textPrimary)
            }

            Text(label)
                .font(TheaterTheme.smallCaption)
                .foregroundStyle(TheaterTheme.textSecondary)
        }
    }

    private var scoreColor: Color {
        let normalized = score / maxScore
        if normalized >= 0.75 { return .green }
        if normalized >= 0.5 { return .orange }
        return .red
    }
}

struct RTScoreBadge: View {
    let score: Int
    let type: String // "critic" or "audience"

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: type == "critic" ? "leaf.fill" : "hand.thumbsup.fill")
                    .foregroundStyle(score >= 60 ? .red : TheaterTheme.textSecondary)
                Text("\(score)%")
                    .font(TheaterTheme.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(TheaterTheme.textPrimary)
            }

            Text(type == "critic" ? "Tomatometer" : "Audience")
                .font(TheaterTheme.smallCaption)
                .foregroundStyle(TheaterTheme.textSecondary)
        }
    }
}
