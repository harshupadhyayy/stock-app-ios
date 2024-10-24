//
//  Autocomplete.swift
//  StockSearch
//
//  Created by Harsh Upadhyay on 4/4/24.
//

import Foundation

struct Stock: Codable, Hashable, Identifiable {
    var id = UUID()
    var description: String
    var displaySymbol: String
    var symbol: String
    var type: String
    
    init(json: [String: Any]) {
            description = json["description"] as? String ?? ""
            displaySymbol = json["displaySymbol"] as? String ?? ""
            symbol = json["symbol"] as? String ?? ""
            type = json["type"] as? String ?? ""
        }
}
