import SwiftUI

struct ServiceIconView: View {
    let name: String
    let size: CGFloat
    let colorOverride: String?

    static let colorMap: [String: Color] = [
        "blue": .blue, "purple": .purple, "orange": .orange, "green": .green,
        "pink": .pink, "teal": .teal, "indigo": .indigo, "mint": .mint,
    ]

    init(name: String, size: CGFloat = 40, colorOverride: String? = nil) {
        self.name = name
        self.size = size
        self.colorOverride = colorOverride
    }

    private var initial: String {
        String(name.prefix(1)).uppercased()
    }

    private var backgroundColor: Color {
        if let override = colorOverride, let color = Self.colorMap[override] {
            return color
        }
        // Deterministic color from name hash
        let hash = abs(name.hashValue)
        let colors: [Color] = [.blue, .purple, .orange, .green, .pink, .teal, .indigo, .mint]
        return colors[hash % colors.count]
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.2)
                .fill(backgroundColor.opacity(0.15))
                .frame(width: size, height: size)

            Text(initial)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(backgroundColor)
        }
    }
}
