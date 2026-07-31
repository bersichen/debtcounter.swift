import SwiftUI
import SwiftData

@main
struct DebtCounterApp: App {
  var body: some Scene {
    WindowGroup {
      SwiftUIView()
        .modelContainer(for: Payment.self)
    }
  }
}
