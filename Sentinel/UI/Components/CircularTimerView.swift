import SwiftUI

struct CircularTimerView: View {
    let remaining: Int
    let period: Int

    var progress: Double {
        Double(remaining) / Double(period)
    }

    var color: Color {
        switch remaining {
        case 0...5: Color.theme.timerCritical
        case 6...10: Color.theme.timerWarning
        default: Color.theme.timerNormal
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 3)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: remaining)
            Text("\(remaining)")
                .font(.caption2)
                .foregroundStyle(color)
        }
        .frame(width: 32, height: 32)
    }
}
