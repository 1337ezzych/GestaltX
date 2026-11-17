import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Application") {
                    LabeledContent("Name", value: "GestaltX")
                    LabeledContent("Version", value: "0.2 UI prototype")
                    LabeledContent("Platform", value: "SwiftUI")
                }
                Section("Scope and safety") {
                    Text("GestaltX edits only plist documents explicitly selected by the user. It does not read or write protected MobileGestalt system files, escape the app sandbox, or change iOS system configuration.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
