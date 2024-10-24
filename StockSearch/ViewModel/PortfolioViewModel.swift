//
//  PortfolioViewModel.swift
//  StockSearch
//
//  Created by Harsh Upadhyay on 4/22/24.
//

import Foundation
import Alamofire
import SwiftyJSON


struct PortfolioItem: Identifiable, Decodable, Hashable {
    let id = UUID()
    let name: String
    let symbol: String
    let totalPrice: Double
    let quantity: Int
}

class PortfolioViewModel: ObservableObject {
//    @Published var autocompleteResponse: Response = Response(count: 0, result: [])
    @Published var stockData: [String: Double] = [:]
    
    @Published var portfolioData: [PortfolioItem] = [] {
        didSet {
            handleUpdate()
//            updateNetWorth()
        }
    }
    
    @Published var netWorth: Double = 0
    @Published var walletBalance: Double = 0
    
    init() {
        fetchWallet()
        fetchPortfolio()
    }
    
    func updateNetWorth() {
        self.netWorth = self.portfolioData.reduce(0) { result, stock in
            let currentPrice = self.stockData[stock.symbol] ?? 0
                return result + (Double(stock.quantity) * currentPrice)
            }
        }

    
    func handleUpdate() {
        let symbols = self.portfolioData.map { $0.symbol }
        
        
        let dispatchGroup = DispatchGroup()
        
        for symbol in symbols {
            dispatchGroup.enter()
            
            AF.request("API/api/v1/quote?symbol=\(symbol)").responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    self.stockData[symbol] = json["c"].doubleValue
                case .failure(let error):
                    print("Error fetching data for \(symbol): \(error)")
                }
                
                dispatchGroup.leave()
            }
        }
        
       
        dispatchGroup.notify(queue: .main) {
            self.updateNetWorth()
        }
    }

    
    func fetchPortfolio() {
        AF.request("API/api/v1/fetch-portfolio")
            .responseDecodable(of: [PortfolioItem].self) { response in
                switch response.result {
                case .success(let posts):
                    self.portfolioData = posts
                    print(self.portfolioData)
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    func fetchWallet() {
        AF.request("API/api/v1/fetch-wallet").responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
//                print(json["wallet"])
                self.walletBalance = json["wallet"].doubleValue
                print(self.walletBalance)
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func setWallet(balance: Double) {
        self.walletBalance = balance
        
        let parameters: [String: Any] = [
            "amount": balance
        ]
        
        AF.request("API/api/v1/update-wallet", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                
                    print("Response JSON: \(value)")
                case .failure(let error):
                
                    print("Error: \(error)")
                }
            }
    }
}
