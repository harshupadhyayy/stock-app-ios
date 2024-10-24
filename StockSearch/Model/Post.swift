//
//  Post.swift
//  StockSearch
//
//  Created by Harsh Upadhyay on 4/3/24.
//

import Foundation

struct Post: Decodable, Identifiable {
    var id: Int
    var title: String
    var body: String
}
