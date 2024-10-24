//
//  AutocompleteViewModel.swift
//  StockSearch
//
//  Created by Harsh Upadhyay on 4/4/24.
//

import Foundation
import Alamofire
import SwiftyJSON


class AutocompleteViewModel: ObservableObject {
//    @Published var autocompleteResponse: Response = Response(count: 0, result: [])
    
    @Published var stock: [Stock] = []
    
    func fetchResults(query: String) {
        
        if query.isEmpty {
            self.stock = []
            return
        }
        
        //reference: https://github.com/Alamofire/Alamofire
        AF.request("https://API/api/v1/search?q=\(query)").responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        let stocks = json["result"].arrayValue.map { Stock(json: $0.dictionaryObject ?? [:]) }
//                        print(json["result"])
                        self.stock = stocks
//                        print(self.stock)
                    case .failure(let error):
                        print(error)
                    }
                }
    }
    
    func clearResults() {
        self.stock = []
    }

}
