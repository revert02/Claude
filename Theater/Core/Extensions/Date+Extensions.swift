import Foundation

extension Date {
    var timeAgoDisplay: String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day, .hour, .minute], from: self, to: now)

        if let days = components.day, days > 0 {
            return days == 1 ? "Yesterday" : "\(days) days ago"
        }
        if let hours = components.hour, hours > 0 {
            return "\(hours)h ago"
        }
        if let minutes = components.minute, minutes > 0 {
            return "\(minutes)m ago"
        }
        return "Just now"
    }
}
