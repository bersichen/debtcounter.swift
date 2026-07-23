//
//  Debt_CounterApp.swift
//  Debt_Counter
//
//  Created by Michael Nikitochkin on 23.12.25.
//

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
