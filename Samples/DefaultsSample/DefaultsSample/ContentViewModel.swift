import Foundation
import SwiftUI
import Combine

class ContentViewModel: ObservableObject {
    private let greetingStore: GreetingStore
    
    private let dateFormatter: DateFormatter
    
    private var subscriptions: [AnyCancellable] = []
    
    init(greetingStore: GreetingStore) {
        self.greetingStore = greetingStore
        
        self.dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
        
        greetingStore.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }.store(in: &subscriptions)
    }
    
    var greeting: String {
        get { greetingStore.greeting }
        set {
            if greetingStore.greeting == newValue { return }
            greetingStore.greeting = newValue
            greetingStore.updatedDate = Date()
        }
    }
    
    var updatedDate: String {
        guard let date = greetingStore.updatedDate else { return "" }
        return dateFormatter.string(from: date)
    }
}
