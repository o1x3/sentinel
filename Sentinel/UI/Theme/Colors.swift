import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let background = Color(.systemBackground)
    let secondaryBackground = Color(.secondarySystemBackground)
    let tertiaryBackground = Color(.tertiarySystemBackground)

    let text = Color(.label)
    let secondaryText = Color(.secondaryLabel)

    let accent = Color.blue
    let success = Color.green
    let warning = Color.orange
    let danger = Color.red

    // TOTP timer states
    let timerNormal = Color.blue
    let timerWarning = Color.orange
    let timerCritical = Color.red
}
