//
//  SentimentTable.swift
//  StockSearch
//
//  Created by Harsh Upadhyay on 4/13/24.
//

import SwiftUI
import SwiftyJSON

struct SentimentTable: View {
    let data: JSON
    let name: String
    
    var totalMSPR: String {
        String(format: "%.2f", data.arrayValue.reduce(0) { $0 + $1["mspr"].doubleValue })
    }
    
    var positiveMSPR: String {
        String(format: "%.2f", data.arrayValue.filter { $0["mspr"].doubleValue >= 0 }.reduce(0) { $0 + $1["mspr"].doubleValue })
    }
    
    var negativeMSPR: String {
        String(format: "%.2f", data.arrayValue.filter { $0["mspr"].doubleValue < 0 }.reduce(0) { $0 + $1["mspr"].doubleValue })
    }
    
    var totalChange: String {
            String(data.arrayValue.reduce(0) { $0 + $1["change"].intValue })
        }
        
        var positiveChange: String {
            String(data.arrayValue.filter { $0["change"].intValue > 0 }.reduce(0) { $0 + $1["change"].intValue })
        }
        
        var negativeChange: String {
            String(data.arrayValue.filter { $0["change"].intValue < 0 }.reduce(0) { $0 + $1["change"].intValue })
        }
    
    var body: some View {
        Text("Insider Sentiments")
            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
        HStack {
//            VStack(alignment: .leading) {
//                Text("\(name)")
//                Text("Total")
//                Text("Positive")
//                Text("Negative")
//            }
//            VStack(alignment: .leading) {
//                Text("MSPR")
//                Text("\(totalMSPR)")
//                Text("\(positiveMSPR)")
//                Text("\(negativeMSPR)")
//            }
//            VStack(alignment: .leading) {
//                Text("Change")
//                Text("\(totalChange)")
//                Text("\(positiveChange)")
//                Text("\(negativeChange)")
//            }
            
            VStack(alignment: .leading) {
                Text("Apple Inc.")
//                Rectangle()
//                    .fill(Color.gray)
//                            .frame(height: 1)
                Divider()
                Text("Total")
                Divider()
                Text("Positive")
                Divider()
                Text("Negative")
                Divider()
            }
            .frame(width: 120, alignment: .leading)
            Spacer()
            VStack(alignment: .leading) {
                Text("MSPR")
                Divider()
                Text("-687.59")
                Divider()
                Text("200.00")
                Divider()
                Text("-887.59")
                Divider()
            }
            .frame(width: 120, alignment: .leading)
            Spacer()
            VStack(alignment: .leading) {
                Text("Change")
                Divider()
                Text("-3361942.00")
                Divider()
                Text("827822.00")
                Divider()
                Text("-4189764.00")
                Divider()
            }
            .frame(width: 120, alignment: .leading)
        }
        .padding(.top, 1)
    }
}

#Preview {
    SentimentTable(data: [], name: "AAPL")
}
