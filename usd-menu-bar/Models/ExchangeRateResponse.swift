//
//  ExchangeRateResponse.swift
//  usd-menu-bar
//
//  Created by Paulo Paiva on 22/12/25.
//

import Foundation

/// API response model for exchange rate data
struct ExchangeRateResponse: Codable {
    let rates: [String: Double]
}

