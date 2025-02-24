//
//  LocaleExtended.swift
//  Calculator
//
//  Created by Ariana Rodríguez on 24/02/25.
//

import Foundation

extension Locale {
    
    static func getDecimalSeparator() -> String {
        Locale.current.decimalSeparator ?? "."
    }
}
