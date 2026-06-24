//
//  Payment.swift
//  debtcounter
//
//  Created by Yaroslav Nikitochkin on 31.01.26.
//
import Foundation
import SwiftData

@Model
class Payment {
  var payday: Date
  var balance: Int

  init(payday: Date, balance: Int) {
    self.payday = payday
    self.balance = balance
  }
}
