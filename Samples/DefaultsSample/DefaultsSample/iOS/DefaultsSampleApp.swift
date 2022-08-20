import SwiftUI

@main
struct DefaultsSampleApp: App {
    private let settings: SettingsAccess = PreferencesAccess(preferences: .standard)
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ContentViewModel(settings: settings))
                .environment(\.appSettings, settings)
        }
    }
}
