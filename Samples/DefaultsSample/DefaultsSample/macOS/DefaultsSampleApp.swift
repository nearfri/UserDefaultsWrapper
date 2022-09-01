import SwiftUI

@main
struct DefaultsSampleApp: App {
    @NSApplicationDelegateAdaptor
    private var appDelegate: AppDelegate
    
    private let settings: Settings = {
        // Migrate data if needed
        return Preferences.standard
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ContentViewModel(settings: settings))
                .environment(\.appSettings, settings)
                .frame(minWidth: 200, idealWidth: 200, maxWidth: .infinity,
                       minHeight: 150, idealHeight: 150, maxHeight: .infinity)
        }
    }
}
