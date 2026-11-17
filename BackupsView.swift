import SwiftUI

struct BackupsView: View {
    @EnvironmentObject private var store: GestaltStore
    @State private var backups: [URL] = []

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        do { try store.saveBackup(); refresh() }
                        catch { store.message = error.localizedDescription }
                    } label: {
                        Label("Create snapshot of current plist", systemImage: "plus.circle.fill")
                    }
                    .disabled(!store.isLoaded)
                }
                Section("Local snapshots") {
                    if backups.isEmpty {
                        Text("No backups yet").foregroundStyle(.secondary)
                    }
                    ForEach(backups, id: \.self) { url in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(url.lastPathComponent)
                            Text("Stored inside GestaltX app documents")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Backups")
            .onAppear(perform: refresh)
        }
    }
    private func refresh() { backups = store.backupURLs() }
}
