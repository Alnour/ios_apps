import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
            Text("__NAME__")
                .font(.title2.bold())
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
