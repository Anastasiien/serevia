//
//  TestHistory.swift
//  serevia
//
//  Created by ekatizzz on 14.04.2026.
//

import Foundation

struct TestResult: Codable, Identifiable {
    let id = UUID()
    let testName: String
    let score: Double // для BDI/BAI - целое, для MAAS - с десятичной
    let date: Date
    let status: String
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter.string(from: date)
    }
}
