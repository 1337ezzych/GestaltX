import SwiftUI
import UniformTypeIdentifiers
import CoreFoundation

@MainActor
final class GestaltStore: ObservableObject {
    @Published var values: [String: Any] = [:]
    @Published var sourceName = "No plist loaded"
    @Published var isLoaded = false
    @Published var message: String?

    func importData(_ data: Data, name: String) {
        do {
            let object = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            guard let dictionary = object as? [String: Any] else {
                message = "The selected plist root must be a dictionary."
                return
            }
            values = dictionary
            sourceName = name
            isLoaded = true
            message = "Imported \(dictionary.count) root entries."
        } catch {
            message = "Could not read plist: \(error.localizedDescription)"
        }
    }

    func exportData() throws -> Data {
        let valid = PropertyListSerialization.propertyList(values, isValidFor: .xml)
        guard valid else { throw StoreError.invalidPropertyList }
        return try PropertyListSerialization.data(fromPropertyList: values, format: .xml, options: 0)
    }

    func set(_ value: Any, for key: String) { values[key] = value }
    func remove(_ key: String) { values.removeValue(forKey: key) }

    func saveBackup() throws {
        let data = try exportData()
        let folder = try Self.backupFolder()
        let safe = "GestaltX-\(Int(Date().timeIntervalSince1970)).plist"
        try data.write(to: folder.appendingPathComponent(safe), options: .atomic)
        message = "Backup saved: \(safe)"
    }

    func backupURLs() -> [URL] {
    guard let folder = try? Self.backupFolder() else {
        return []
    }

    let urls = (try? FileManager.default.contentsOfDirectory(
        at: folder,
        includingPropertiesForKeys: [.contentModificationDateKey]
    )) ?? []

    return urls.sorted {
        $0.lastPathComponent > $1.lastPathComponent
    }
}

    private static func backupFolder() throws -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folder = docs.appendingPathComponent("Backups", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }

    enum StoreError: Error { case invalidPropertyList }
}
