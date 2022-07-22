import SwiftUI

@main
struct DefaultsSampleApp: App {
    @NSApplicationDelegateAdaptor
    private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ContentViewModel())
                .frame(minWidth: 200, idealWidth: 200, maxWidth: .infinity,
                       minHeight: 150, idealHeight: 150, maxHeight: .infinity)
        }
    }
}
