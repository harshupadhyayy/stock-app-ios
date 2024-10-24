//
//  Portfolio.swift
//  StockSearch
//
//  Created by Harsh Upadhyay on 4/3/24.
//

import SwiftUI
import SwiftyJSON

struct Portfolio: View {
//    @Binding var posts: [Post]
    @ObservedObject var viewModel: PortfolioViewModel
    @ObservedObject var wViewModel: WatchlistViewModel
    @State private var timerPaused = false
    let timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Net Worth")
                    .font(.headline)
                Text("$\(viewModel.netWorth + viewModel.walletBalance, specifier: "%.2f")")
                    .font(.system(size: 22))
                    .bold()
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("Cash Balance")
                    .font(.headline)
                Text("$\(viewModel.walletBalance, specifier: "%.2f")")
                    .font(.system(size: 22))
                    .bold()
            }
        }
        
        
        
        ForEach(viewModel.portfolioData) { stock in
            let currentPrice = viewModel.stockData[stock.symbol]
            let currentTotal = Double(stock.quantity) * (currentPrice ?? 0)
            let percentageChange = ((currentTotal - stock.totalPrice) / stock.totalPrice) * 100
            
            
            NavigationLink(destination: StockInfo(symbol: stock.symbol, wViewModel: wViewModel, pViewModel: viewModel)) {
                VStack {
                    HStack {
                        Text(stock.symbol)
                            .font(.system(size: 22))
                            .bold()
                        Spacer()
                        Text("$\(currentTotal, specifier: "%.2f")")
                            .font(.headline)

                    }
                    HStack {
                        Text("\(stock.quantity) \(stock.quantity == 1 ? "share" : "shares")")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                        if(currentTotal - stock.totalPrice > 0.0) {
                            Image(systemName: "line.diagonal.arrow")
                                .foregroundColor(.green)
                                .font(.system(size: 16))
                        } else if(currentTotal - stock.totalPrice < 0.0) {
                            Image(systemName: "line.diagonal.arrow")
                                               .rotationEffect(Angle(degrees: 90))
                                .foregroundColor(.red)
                                .font(.system(size: 16))
                        } else {
                            Image(systemName: "minus")
                            //                                .rotationEffect(Angle(degrees: 90))
                                .foregroundColor(.gray)
                                .font(.system(size: 16))
                        }
                        Text("\(currentTotal - stock.totalPrice, specifier: "%.2f")")
                            .font(.system(size: 18))
                            .foregroundColor(currentTotal - stock.totalPrice > 0.0 ? .green : (currentTotal - stock.totalPrice < 0.0 ? .red : .gray))
                        Text("(\(percentageChange, specifier: "%.2f")%)")
                            .font(.system(size: 18))
                            .foregroundColor(currentTotal - stock.totalPrice > 0.0 ? .green : (currentTotal - stock.totalPrice < 0.0 ? .red : .gray))

                    }
                }
            }
        }
        .onMove(perform: { indices, newOffset in
                        viewModel.portfolioData.move(fromOffsets: indices, toOffset: newOffset)
                    })
        .onReceive(timer) { _ in
            if !timerPaused {
                                print("executed the 15 second timer")
                                viewModel.fetchPortfolio()
                            }
            }
        .onDisappear {
        
                        timerPaused = true
                    }
                    .onAppear {
            
                        timerPaused = false
                    }
    }
    
        
    }

struct Portfolio_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = PortfolioViewModel()
        let wViewModel = WatchlistViewModel()
        Portfolio(viewModel: viewModel, wViewModel: wViewModel)
    }
}
