import SwiftUI

struct ServiceIconView: View {
    let name: String
    let size: CGFloat

    init(name: String, size: CGFloat = 40) {
        self.name = name
        self.size = size
    }

    private var initial: String {
        String(name.prefix(1)).uppercased()
    }

    private var backgroundColor: Color {
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
