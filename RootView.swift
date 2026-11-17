import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case gestalt = "MobileGestalt"
    case backups = "Backups"
    case settings = "Settings"
    var id: String { rawValue }
    var icon: String {
        switch self {
        case .home: return "square.grid.2x2.fill"
        case .gestalt: return "slider.horizontal.3"
        case .backups: return "archivebox.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct RootView: View {
    @State private var selection: AppTab = .home
    @EnvironmentObject private var store: GestaltStore

    var body: some View {
        TabView(selection: $selection) {
            DashboardView(selection: $selection)
                .tabItem { Label("Home", systemImage: "square.grid.2x2.fill") }
                .tag(AppTab.home)
            GestaltEditorView()
                .tabItem { Label("Gestalt", systemImage: "slider.horizontal.3") }
                .tag(AppTab.gestalt)
            BackupsView()
                .tabItem { Label("Backups", systemImage: "archivebox.fill") }
                .tag(AppTab.backups)
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(AppTab.settings)
        }
        .tint(.cyan)
        .alert("GestaltX", isPresented: Binding(
            get: { store.message != nil },
            set: { if !$0 { store.message = nil } }
        )) {
            Button("OK") { store.message = nil }
        } message: {
            Text(store.message ?? "")
        }
    }
}

struct DashboardView: View {
    @Binding var selection: AppTab
    @EnvironmentObject private var store: GestaltStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("GESTALTX").font(.caption.weight(.bold)).tracking(2).foregroundStyle(.cyan)
                        Text("Command Center").font(.largeTitle.bold())
                        Text("Local configuration workspace").foregroundStyle(.secondary)
                    }
                    HStack(spacing: 12) {
                        StatCard(title: "PLIST", value: store.isLoaded ? "Loaded" : "Empty", icon: "doc.text")
                        StatCard(title: "ENTRIES", value: store.isLoaded ? "\(store.values.count)" : "—", icon: "list.bullet")
                    }
                    Text("Modules").font(.title2.bold())
                    ModuleCard(title: "MobileGestalt Editor", subtitle: "Inspect and edit an imported plist", icon: "slider.horizontal.3") {
                        selection = .gestalt
                    }
                    ModuleCard(title: "Backups", subtitle: "Create and browse local snapshots", icon: "archivebox") {
                        selection = .backups
                    }
                    ModuleCard(title: "Settings", subtitle: "App information and limitations", icon: "gearshape") {
                        selection = .settings
                    }
                    Text("This app only works with files you choose in the Files picker. It does not access protected iOS system files.")
                        .font(.footnote).foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
                .padding()
            }
            .background(Color(uiColor: .systemBackground))
            .navigationBarHidden(true)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon).foregroundStyle(.cyan)
            Text(title).font(.caption.bold()).foregroundStyle(.secondary)
            Text(value).font(.title3.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

struct ModuleCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon).font(.title2).foregroundStyle(.cyan)
                    .frame(width: 44, height: 44)
                    .background(.cyan.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.headline).foregroundStyle(.primary)
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.tertiary)
            }
            .padding()
            .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
