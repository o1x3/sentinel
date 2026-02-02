import Foundation

extension String {
    /// Pad the string on the left to reach the desired length.
    func leftPad(to length: Int, with character: Character) -> String {
        String(repeating: character, count: max(0, length - count)) + self
    }
}
