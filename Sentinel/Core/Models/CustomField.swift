import Foundation

struct CustomField: Codable, Identifiable, Hashable {
    var id: UUID
    var label: String
    var encryptedValue: Data
    var type: FieldType

    enum FieldType: String, Codable {
        case text, password, pin
    }

    init(id: UUID = UUID(), label: String, encryptedValue: Data = Data(), type: FieldType = .text) {
        self.id = id
        self.label = label
        self.encryptedValue = encryptedValue
        self.type = type
    }
}
