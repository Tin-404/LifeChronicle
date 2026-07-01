import SwiftUI

@main
struct LifeChronicleApp: App {
    @StateObject private var recordStore = RecordStore()
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(recordStore)

                if showSplash {
                    SplashView {
                        withAnimation(.easeInOut(duration: 0.6)) {
                            showSplash = false
                        }
                    }
                    .transition(.opacity)
                }
            }
        }
    }
}
