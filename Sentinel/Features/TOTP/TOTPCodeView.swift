import SwiftUI

struct TOTPCodeView: View {
    let code: String

    var formattedCode: String {
        let mid = code.count / 2
        let idx = code.index(code.startIndex, offsetBy: mid)
        return "\(code[..<idx]) \(code[idx...])"
    }

    var body: some View {
        Text(formattedCode)
            .font(.system(.title, design: .monospaced))
            .fontWeight(.semibold)
            .contentTransition(.numericText())
    }
}
