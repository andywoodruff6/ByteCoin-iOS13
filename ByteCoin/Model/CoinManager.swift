//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Andy W on 02/01/2023.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdatePrice(_ coinManager: CoinManager, coin: CoinModel)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "D29A5D38-2EBC-40EB-B67E-C7EB721CF96E"
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    var delegate: CoinManagerDelegate?
    
    
    // https://rest.coinapi.io/v1/exchangerate/BTC/USD?apikey=
    func getCoinPrice(for currency: String) {
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    let coin = self.parseJSON(safeData)
                    self.delegate?.didUpdatePrice(self, coin: coin!)
                }
            }
            task.resume()
        }
    }
    func parseJSON(_ data: Data) -> CoinModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = String(format: "%.1f",decodedData.rate)
            let currencyName = decodedData.asset_id_quote
            let coinName = decodedData.asset_id_base
            
            let coin = CoinModel(currencyName: currencyName, coinName: coinName, coinPrice: lastPrice)
            return coin
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
