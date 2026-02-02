import Foundation

extension Date {
    /// Relative date string (e.g. "2 days ago", "just now").
    var relativeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
