import Foundation
import SwiftUI
import Combine

class ContentViewModel: ObservableObject {
//    @Published
    @AppStorage("isItalic")
    var isItalic: Bool = false
    
    private var subscriptions: [AnyCancellable] = []
    
    init() {
        NSLog("init")
        objectWillChange.sink { [unowned self] in
            NSLog("will change \(isItalic)")
        }.store(in: &subscriptions)
    }
}
