import SwiftUI

@main
struct DefaultsSampleApp: App {
    private let settings: Preferences = .standard
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ContentViewModel(greetingStore: settings))
                .environment(\.fontSettings, settings)
        }
    }
}
