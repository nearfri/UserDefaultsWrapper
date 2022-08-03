import SwiftUI

@main
struct DefaultsSampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ContentViewModel())
                .environment(\.appSettings, PreferencesAccess(preferences: .standard))
        }
    }
}
