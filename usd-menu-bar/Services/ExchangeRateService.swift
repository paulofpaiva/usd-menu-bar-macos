//
//  ExchangeRateService.swift
//  usd-menu-bar
//
//  Created by Paulo Paiva on 22/12/25.
//

import Foundation

/// Service responsible for fetching exchange rate data from the API
final class ExchangeRateService {
    
    // MARK: - Constants
    
    private static let apiURL = "https://open.er-api.com/v6/latest/USD"
    private static let targetCurrency = "BRL"
    
    // MARK: - Properties
    
    private let session: URLSession
    
    // MARK: - Initialization
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - Public Methods
    
    /// Fetches the current USD to BRL exchange rate
    /// - Parameter completion: Callback with the result (rate value or error)
    func fetchRate(completion: @escaping (Result<Double, Error>) -> Void) {
        guard let url = URL(string: Self.apiURL) else {
            completion(.failure(ExchangeRateError.invalidURL))
            return
        }
        
        let task = session.dataTask(with: url) { data, response, error in
            // Artificial delay for loading visualization (remove in production)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(ExchangeRateError.noData))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(ExchangeRateResponse.self, from: data)
                    
                    if let rate = response.rates[Self.targetCurrency] {
                        completion(.success(rate))
                    } else {
                        completion(.failure(ExchangeRateError.currencyNotFound))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
}

// MARK: - Error Types

enum ExchangeRateError: Error {
    case invalidURL
    case noData
    case currencyNotFound
}

