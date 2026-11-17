import SwiftUI

@main
struct GestaltXApp: App {
    @StateObject private var store = GestaltStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}
