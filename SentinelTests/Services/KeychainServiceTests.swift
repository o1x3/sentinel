import Testing
import Foundation
@testable import Sentinel

struct KeychainServiceTests {

    private let service = KeychainService.shared
    private let testKey = "sentinel.test.key.\(UUID().uuidString)"

    @Test func saveAndLoadCycle() throws {
        let data = Data("test-value".utf8)
        try service.save(data, forKey: testKey)

        let loaded = try service.load(forKey: testKey)
        #expect(loaded == data)

        // Cleanup
        try service.delete(forKey: testKey)
    }

    @Test func loadNonExistentKeyReturnsNil() throws {
        let loaded = try service.load(forKey: "sentinel.test.nonexistent.\(UUID().uuidString)")
        #expect(loaded == nil)
    }

    @Test func overwriteExistingKey() throws {
        let data1 = Data("first".utf8)
        let data2 = Data("second".utf8)

        try service.save(data1, forKey: testKey)
        try service.save(data2, forKey: testKey)

        let loaded = try service.load(forKey: testKey)
        #expect(loaded == data2)

        try service.delete(forKey: testKey)
    }

    @Test func deleteExistingKey() throws {
        let data = Data("to-delete".utf8)
        try service.save(data, forKey: testKey)

        try service.delete(forKey: testKey)

        let loaded = try service.load(forKey: testKey)
        #expect(loaded == nil)
    }

    @Test func deleteNonExistentKeyDoesNotThrow() throws {
        try service.delete(forKey: "sentinel.test.nonexistent.\(UUID().uuidString)")
    }
}
