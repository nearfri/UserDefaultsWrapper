import SwiftUI

struct ContentView: View {
    @State private var isBold: Bool = false
    @State private var isItalic: Bool = false
    @State private var isUnderline: Bool = false
    @State private var isStrikethrough: Bool = false
    
#if os(iOS)
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass: UserInterfaceSizeClass?
#endif
    
    var body: some View {
        VStack {
            Text("Hello World")
                .ifTrue(isBold, then: { $0.bold() })
                .ifTrue(isItalic, then: { $0.italic() })
                .underline(isUnderline)
                .strikethrough(isStrikethrough)
            
            textStyleControl
        }
    }
    
    @ViewBuilder
    private var textStyleControl: some View {
        HStack {
            ForEach(textStyles, id: \.title) { style in
                Toggle(isOn: style.isOn) {
                    Label(style.title, systemImage: style.imageName)
                }
            }
        }
        .toggleStyle(.button)
        .labelStyle(.iconOnly)
        .padding(4)
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(.secondary, lineWidth: 1))
    }
    
    private var textStyles: [TextStyleData] {
        return [
            TextStyleData(
                isOn: $isBold,
                title: "Bold",
                imageName: "bold"),
            TextStyleData(
                isOn: $isItalic,
                title: "Italic",
                imageName: "italic"),
            TextStyleData(
                isOn: $isUnderline,
                title: "Underline",
                imageName: "underline"),
            TextStyleData(
                isOn: $isStrikethrough,
                title: "Strikethrough",
                imageName: "strikethrough"),
        ]
    }
}

private struct TextStyleData {
    var isOn: Binding<Bool>
    var title: String
    var imageName: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
