import SwiftUI

@main
struct DefaultsSampleApp: App {
    private let settings: SettingsAccess = {
        // Migrate data if needed
        return PreferencesAccess(preferences: .standard)
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ContentViewModel(settings: settings))
                .environment(\.appSettings, settings)
        }
    }
}
