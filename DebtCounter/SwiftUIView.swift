import SwiftUI
import SwiftData

struct SwiftUIView: View {
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \Payment.payday, order: .reverse) private var payments: [Payment]

  @State private var newBalance = 1334
  @State private var newPayday = Date.now
  @State private var weekOffset: Int = 0

  var nextPaymentDate: Date {
    let calendar = Calendar.current
    let sortedDates = payments.map { $0.payday }.sorted()

    let baseDate = sortedDates.first ?? .now
    let components = calendar.dateComponents([.year, .month], from: baseDate)
    let startOfFirstMonth = calendar.date(from: components) ?? baseDate

    let monthsToAdd = payments.isEmpty ? 1 : payments.count
    let baseDueDate = calendar.date(byAdding: .month, value: monthsToAdd, to: startOfFirstMonth) ?? Date.now

    return calendar.date(byAdding: .weekOfYear, value: weekOffset, to: baseDueDate) ?? baseDueDate
  }

  var body: some View {
    NavigationStack {
      List {
        Section {
          ForEach(payments) { payment in
            HStack {
              VStack(alignment: .leading, spacing: 6) {
                Text(payment.payday, format: .dateTime.day().month().year())

                if payment.isExamWeek {
                  Text("Exam Week")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.red)
                    .cornerRadius(4)
                }
              }

              Spacer()

              Text("\(payment.balance)")
            }
          }
          .onDelete(perform: deleteRow)
        } header: {
          HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
              Text("Next payment due:")
              if weekOffset == 1 {
                Text("Exam Week")
                  .font(.caption)
                  .fontWeight(.bold)
                  .foregroundColor(.white)
                  .padding(.horizontal, 6)
                  .padding(.vertical, 2)
                  .background(Color.red)
                  .cornerRadius(4)
              }
            }

            Spacer()

            HStack(spacing: 8) {
              Button(action: { weekOffset = 0 }) {
                Image(systemName: "minus.circle.fill")
                  .foregroundStyle(weekOffset == 0 ? .gray : .red)
              }
              .buttonStyle(.plain)
              .disabled(weekOffset == 0)

              Text(nextPaymentDate, format: .dateTime.day().month().year())
                .fontWeight(.bold)
                .foregroundStyle(.blue)

              Button(action: { weekOffset = 1 }) {
                Image(systemName: "plus.circle.fill")
                  .foregroundStyle(weekOffset == 1 ? .gray : .green)
              }
              .buttonStyle(.plain)
              .disabled(weekOffset == 1)
            }
          }
          .padding(.vertical, 8)
        }
      }
      .navigationTitle("Payments")
      .onChange(of: nextPaymentDate) { _, newValue in
        if newPayday > newValue {
          newPayday = newValue
        }
      }
      .safeAreaInset(edge: .bottom) {
        VStack(spacing: 16) {
          Text("New Payment")
            .font(.headline)

          HStack {
            Text("Balance:")
            TextField("Balance", value: $newBalance, format: .number)
              .textFieldStyle(.roundedBorder)
              .keyboardType(.numberPad)
          }

          DatePicker(
            "Payday:",
            selection: $newPayday,
            in: Date.distantPast...nextPaymentDate,
            displayedComponents: .date
          )
          
          Button("Save") {
            let newPayment = Payment(
              payday: newPayday,
              balance: newBalance,
              isExamWeek: weekOffset == 1
            )
            modelContext.insert(newPayment)

            newBalance -= 42
            weekOffset = 0

            let today = Date.now
            newPayday = today > nextPaymentDate ? nextPaymentDate : today
          }
          .buttonStyle(.borderedProminent)
          .bold()
        }
        .padding()
        .background(.ultraThinMaterial)
      }
    }
  }

  func deleteRow(at offsets: IndexSet) {
    for index in offsets {
      let paymentToDelete = payments[index]
      modelContext.delete(paymentToDelete)
    }
  }
}
