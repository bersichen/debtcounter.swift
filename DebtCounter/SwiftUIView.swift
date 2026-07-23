//
//  SwiftUIView.swift
//  Debt_Counter
//
//  Created by Michael Nikitochkin on 23.12.25.
//

import SwiftUI

// A simple local structure to bundle the data together (Not a database model)
struct LocalPayment: Identifiable {
    let id = UUID()
    var payday: Date
    var balance: Int
    var isExamWeek: Bool
}

struct SwiftUIView: View {
    // Local state array to hold your payments while the app is open
    @State private var payments: [LocalPayment] = []
    
    @State private var newBalance = 1334
    @State private var newPayday = Date.now
    @State private var weekOffset: Int = 0

    // Calculates the next payment date using the local array
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
                    // Manually sorting the local array by date (Newest first)
                    ForEach(payments.sorted(by: { $0.payday > $1.payday })) { payment in
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
            // Safety Check: Clamps the selected payday if the nextPaymentDate changes to an earlier date
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

                    // CHANGED: Range now caps selection strictly at nextPaymentDate
                    DatePicker(
                        "Payday:",
                        selection: $newPayday, 
                        in: Date.distantPast...nextPaymentDate,
                        displayedComponents: .date
                    )

                    Button("Save") {
                        let newPayment = LocalPayment(
                            payday: newPayday,
                            balance: newBalance,
                            isExamWeek: weekOffset == 1
                        )
                        payments.append(newPayment)

                        // Reset layouts and clean values safely
                        newBalance -= 42
                        weekOffset = 0
                        
                        // Default back to today, but clamp it to the next payment date if today is somehow past it
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
        let sortedPayments = payments.sorted(by: { $0.payday > $1.payday })
        for index in offsets {
            let paymentToDelete = sortedPayments[index]
            payments.removeAll(where: { $0.id == paymentToDelete.id })
        }
    }
}
