import SwiftUI
import MyMacro

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            MyCustomView()
            MyCustomView()
                .environment(\.myEnvironmentValue, "overridden_value")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

struct MyCustomView: View {
    @Environment(\.myEnvironmentValue) var myEnvironmentValue
    
    var body: some View {
        Text(myEnvironmentValue)
    }
}

@EnvironmentValuesProvider()
extension EnvironmentValues {
    var myEnvironmentValue: String = "default_value"
}
