import SwiftUI

struct StrengthMeterView: View {
    let strength: PasswordStrength

    private var color: Color {
        switch strength {
        case .weak: Color.theme.danger
        case .fair: Color.theme.warning
        case .good: Color.theme.accent
        case .strong: Color.theme.success
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                ForEach(0..<4, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(index <= strength.rawValue ? color : color.opacity(0.2))
                        .frame(height: 4)
                }
            }

            Text(strength.label)
                .font(.caption2)
                .foregroundStyle(color)
        }
    }
}
