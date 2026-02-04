import UIKit
import UniformTypeIdentifiers

enum ClipboardService {
    private static var defaultSeconds: Int {
        let value = UserDefaults.standard.integer(forKey: "clipboardClearSeconds")
        // UserDefaults returns 0 for unset keys; treat that as "use default 30s"
        return UserDefaults.standard.object(forKey: "clipboardClearSeconds") != nil ? value : 30
    }

    static func copy(_ value: String) {
        let seconds = defaultSeconds
        if seconds > 0 {
            UIPasteboard.general.setItems(
                [[UTType.plainText.identifier: value]],
                options: [.expirationDate: Date().addingTimeInterval(Double(seconds))]
            )
        } else {
            UIPasteboard.general.string = value
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}
