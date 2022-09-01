import Foundation
import SwiftUI
import Combine

class ContentViewModel: ObservableObject {
    private let settings: Settings
    
    private var subscriptions: [AnyCancellable] = []
    
    init(settings: Settings) {
        self.settings = settings
        
        settings.objectWillChange.sink { [objectWillChange] in
            objectWillChange.send()
        }.store(in: &subscriptions)
    }
    
    var greeting: String {
        get { settings.greeting }
        set { settings.greeting = newValue }
    }
}
