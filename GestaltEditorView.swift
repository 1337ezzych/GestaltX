import SwiftUI
import UniformTypeIdentifiers
import CoreFoundation

struct GestaltEditorView: View {
    @EnvironmentObject private var store: GestaltStore
    @State private var importing = false
    @State private var exporting = false
    @State private var exportDocument = PlistExportDocument(data: Data())
    @State private var search = ""
    @State private var editingKey: String?
    @State private var newKey = ""
    @State private var newValue = ""

    private var keys: [String] {
        store.values.keys.sorted().filter { search.isEmpty || $0.localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if store.isLoaded {
                    List {
                        Section {
                            HStack {
                                Label(store.sourceName, systemImage: "doc.text")
                                Spacer()
                                Text("\(store.values.count) keys").foregroundStyle(.secondary).font(.caption)
                            }
                        }
                        Section("Entries") {
                            ForEach(keys, id: \.self) { key in
                                Button {
                                    editingKey = key
                                    newKey = key
                                    newValue = Self.stringValue(store.values[key])
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(key).foregroundStyle(.primary)
                                            Text(Self.typeName(store.values[key])).font(.caption).foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Text(Self.stringValue(store.values[key])).lineLimit(1).foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .onDelete { offsets in
                                let removeKeys = offsets.map { keys[$0] }
                                removeKeys.forEach(store.remove)
                            }
                        }
                    }
                    .searchable(text: $search, prompt: "Search keys")
                } else {
                    ContentUnavailableView("No plist loaded", systemImage: "doc.badge.plus",
                        description: Text("Import a plist file from the Files app to begin."))
                }
            }
            .navigationTitle("MobileGestalt")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { importing = true } label: { Image(systemName: "folder") }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if store.isLoaded {
                        Button { addEntry() } label: { Image(systemName: "plus") }
                        Button {
                            do { exportDocument = PlistExportDocument(data: try store.exportData()); exporting = true }
                            catch { store.message = error.localizedDescription }
                        } label: { Image(systemName: "square.and.arrow.up") }
                    }
                }
            }
            .fileImporter(isPresented: $importing, allowedContentTypes: [.propertyList], allowsMultipleSelection: false) { result in
                do {
                    guard let url = try result.get().first else { return }
                    let access = url.startAccessingSecurityScopedResource()
                    defer { if access { url.stopAccessingSecurityScopedResource() } }
                    store.importData(try Data(contentsOf: url), name: url.lastPathComponent)
                } catch { store.message = error.localizedDescription }
            }
            .fileExporter(isPresented: $exporting, document: exportDocument, contentType: .propertyList, defaultFilename: "GestaltX-Export") { result in
                if case .failure(let error) = result { store.message = error.localizedDescription }
            }
            .sheet(item: Binding(
                get: { editingKey.map(EditKey.init) },
                set: { editingKey = $0?.key }
            )) { item in
                NavigationStack {
                    Form {
                        Section("Key") { Text(item.key).font(.footnote).foregroundStyle(.secondary) }
                        Section("Value") {
                            TextField("Value", text: $newValue)
                        }
                        Section {
                            Button("Save") {
                                guard let key = editingKey else { return }
                                store.set(newValue, for: key)
                                editingKey = nil
                            }
                            Button("Delete", role: .destructive) {
                                if let key = editingKey { store.remove(key) }
                                editingKey = nil
                            }
                        }
                    }
                    .navigationTitle("Edit entry")
                    .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Close") { editingKey = nil } } }
                }
            }
        }
    }

    private func addEntry() {
        let key = "NewKey\(store.values.count + 1)"
        store.set("", for: key)
        editingKey = key
        newKey = key
        newValue = ""
    }

    private static func stringValue(_ value: Any?) -> String {
        guard let value else { return "—" }
        if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() { return number.boolValue ? "true" : "false" }
        }
        return String(describing: value)
    }
    private static func typeName(_ value: Any?) -> String {
        guard let value else { return "Unknown" }
        if value is String { return "String" }
        if value is Data { return "Data" }
        if value is Date { return "Date" }
        if value is [Any] { return "Array" }
        if value is [String: Any] { return "Dictionary" }
        if let n = value as? NSNumber {
            return CFGetTypeID(n) == CFBooleanGetTypeID() ? "Boolean" : "Number"
        }
        return "Value"
    }
    private struct EditKey: Identifiable { let key: String; var id: String { key } }
}
