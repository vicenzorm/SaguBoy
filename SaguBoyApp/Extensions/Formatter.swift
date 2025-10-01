//
//  Formatter.swift
//  SaguBoyApp
//
//  Created by Enzo Tonatto on 29/09/25.
//

import Foundation

extension Formatter {
    static let score9: NumberFormatter = {
        let f = NumberFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.numberStyle = .decimal
        f.usesGroupingSeparator = true
        f.groupingSize = 3
        f.minimumIntegerDigits = 9
        f.maximumFractionDigits = 0
        return f
    }()
}
extension Int {
    var score9: String { Formatter.score9.string(from: NSNumber(value: self)) ?? "000.000.000" }
}
