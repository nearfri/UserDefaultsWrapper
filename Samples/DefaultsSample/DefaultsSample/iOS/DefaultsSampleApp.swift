import SwiftUI

@main
struct DefaultsSampleApp: App {
    private let settings: Settings = {
        // Migrate data if needed
        return Preferences.standard
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ContentViewModel(settings: settings))
                .environment(\.appSettings, settings)
        }
    }
}
