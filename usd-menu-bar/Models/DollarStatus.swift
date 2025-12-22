//
//  DollarStatus.swift
//  usd-menu-bar
//
//  Created by Paulo Paiva on 22/12/25.
//

import Foundation

/// Represents the current state of the dollar rate fetch operation
enum DollarStatus {
    case idle
    case loading
    case success(Double)
    case error
    
    /// Returns true if the status is loading
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
}

