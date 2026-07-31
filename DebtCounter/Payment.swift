import Foundation
import SwiftData

@Model
final class Payment: Identifiable {
  var id: UUID = UUID()
  var payday: Date = Date.now
  var balance: Int = 0
  var isExamWeek: Bool = false

  init(payday: Date = .now, balance: Int, isExamWeek: Bool = false) {
    self.payday = payday
    self.balance = balance
    self.isExamWeek = isExamWeek
  }
}
