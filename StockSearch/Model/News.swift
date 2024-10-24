//
//  News.swift
//  StockSearch
//
//  Created by Harsh Upadhyay on 4/14/24.
//

import Foundation

struct News: Codable, Hashable, Identifiable {
    var id: Int
    var category: String
    var datetime: Int
    var headline: String
    var image: String
    var related: String
    var source: String
    var summary: String
    var url: String
    
    init(json: [String: Any]) {
        id = json["id"] as? Int ?? 0
        category = json["category"] as? String ?? ""
        datetime = json["datetime"] as? Int ?? 0
        headline = json["headline"] as? String ?? ""
        image = json["image"] as? String ?? ""
        related = json["related"] as? String ?? ""
        source = json["source"] as? String ?? ""
        summary = json["summary"] as? String ?? ""
        url = json["url"] as? String ?? ""
    }
}

