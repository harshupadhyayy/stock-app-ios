//
//  TradeSheet.swift
//  StockSearch
//
//  Created by Harsh Upadhyay on 4/22/24.
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct TradeSheet: View {
    @State private var quantity: Int = 0
    @ObservedObject var pViewModel = PortfolioViewModel()
    let symbol: String
    let name: String
    @State private var currentPrice = 0.00
    @State private var availableQuantity = 0
    @Environment(\.presentationMode) var presentationMode
    @State private var showToast = false
    @State private var toastMsg = ""
    @State private var showCongrats: Bool = false
    @State private var buttonClicked = ""
    
    var body: some View {
        if showCongrats {
            VStack {
                Spacer()
                Text("Congratulations!")
                    .bold()
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .foregroundStyle(.white)
                Text("You have successfully \(buttonClicked) \(quantity) \(quantity > 1 ? "shares" : "share") of \(symbol)")
                    .foregroundStyle(.white)
                    .padding(.top)
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Spacer()
                        Text("Done")
                        Spacer()
                    }
                    .padding()
                }
                .foregroundStyle(.green)
                .background(Color.white)
                .cornerRadius(40)
                .padding()

            }
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            .background(.green)
                        
        } else {
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                    }
                }
                
                Text("Trade \(name) shares")
                    .font(.headline)
                
                Spacer()
                HStack {
                    TextField("0", value: $quantity, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                                   .padding(10)
                                   .background(Color.clear)
                               .cornerRadius(10)
                               .font(.system(size: 100))
                    
                    if(quantity > 1) {
                        Text("Shares")
                            .font(.system(size: 35))
                    } else {
                        Text("Share")
                            .font(.system(size: 35))
                    }
                    
                }
                
                HStack {
                    Spacer()
                    Text("x $\(currentPrice, specifier: "%.2f")/share = $\((Double(quantity) * currentPrice), specifier: "%.2f")")
                }
                
                Spacer()
                
                
                
                Text("$\(pViewModel.walletBalance, specifier: "%.2f") available to buy \(symbol)")
                    .foregroundStyle(.gray)
                
                HStack {
                    Button(action: {
                        if(quantity > 0) {
                            let total = Double(quantity) * currentPrice
                            
                            if total > pViewModel.walletBalance {
                                toastMsg = "Not enough money to buy"
                                showToast = true
                            } else {
                                let parameters: [String: Any] = [
                                    "symbol": symbol,
                                    "totalPrice": total,
                                    "quantity": quantity,
                                    "name": name
                                ]
                                
                                let item = PortfolioItem(name: name, symbol: symbol, totalPrice: total, quantity: quantity)
                                pViewModel.portfolioData.append(item)
                                
                                AF.request("API/api/v1/buy-symbol", method: .post, parameters: parameters, encoding: JSONEncoding.default)
                                    .validate() 
                                    .responseJSON { response in
                                        switch response.result {
                                        case .success(let value):
                                            // Handle success
                                            print("Response JSON: \(value)")
                                        case .failure(let error):
                                            // Handle failure
                                            print("Error: \(error)")
                                        }
                                    }
                                
                                

                                pViewModel.setWallet(balance: pViewModel.walletBalance - total)
                                
                                buttonClicked = "bought"
                                showCongrats = true
                            }
                            
                            
                        } else {
                            toastMsg = "Cannot buy non-positive shares"
                            showToast = true
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Buy")
                                
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                    .cornerRadius(40)
                    }
                    
                    Button(action: {
                        if(quantity > 0) {
                            if(quantity > availableQuantity) {
                                print("cannot sell more than available quantity")
                                toastMsg = "Not enough shares to sell"
                                showToast = true
                            } else {
                                let total = Double(quantity) * currentPrice
                                
                                pViewModel.setWallet(balance: pViewModel.walletBalance + total)
                                
                                pViewModel.portfolioData.removeAll { $0.symbol == symbol }
                                
                                AF.request("API/api/v1/symbol-delete?symbol=\(symbol)", method: .delete).responseJSON { response in
                                    switch response.result {
                                    case .success(let value):
                                        let json = JSON(value)
    //                                    self.currentPrice = json["c"].doubleValue
    //                                    print(json)
                                        print(json)
                                    case .failure(let error):
                                        print("Error: \(error)")
                                    }
                                }
    //                            let parameters: [String: Any] = [
    //                                "symbol": symbol,
    //                                "totalPrice": total,
    //                                "quantity": quantity,
    //                                "name": name
    //                            ]
    //
    //                            AF.request("API/api/v1/buy-symbol-update", method: .post, parameters: parameters, encoding: JSONEncoding.default)
    //                                .validate() // Optional: Validate the response
    //                                .responseJSON { response in
    //                                    switch response.result {
    //                                    case .success(let value):
    //                                        // Handle success
    //                                        print("Response JSON: \(value)")
    //                                    case .failure(let error):
    //                                        // Handle failure
    //                                        print("Error: \(error)")
    //                                    }
    //                                }
    //                            pViewModel.setWallet(balance: pViewModel.walletBalance + total)
                                buttonClicked = "sold"
                                showCongrats = true
                            }
                            
                            }
                        else {
                            toastMsg = "Cannot sell non-positive shares"
                            showToast = true
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Sell")
                                
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                    .cornerRadius(40)
                    }
                }
                .padding()
            }
            .padding()
            .onAppear {
                fetchCurrentPrice()
                getAvailableQuantity()
            }
            .toast(isPresented: $showToast, message: toastMsg)
        }
        
    }
    
    func getAvailableQuantity() {
        print(pViewModel.portfolioData)
        if let portfolioItem = pViewModel.portfolioData.first(where: { $0.symbol == symbol }) {
            print("Portfolio item found: \(portfolioItem)")
            self.availableQuantity = portfolioItem.quantity
        } else {
            self.availableQuantity = 0
        }
    }
    
    func fetchCurrentPrice() {
            AF.request("API/api/v1/quote?symbol=\(symbol)").responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    self.currentPrice = json["c"].doubleValue
//                    print(json)
//                    print(self.currentPrice)
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
    
    
}

//toast reference: https://stackoverflow.com/questions/56550135/swiftui-global-overlay-that-can-be-triggered-from-any-view
struct ToastView: View {
    let message: String
    
    var body: some View {
        ZStack {
//            Color.black
//                .opacity(0.7)
//                .ignoresSafeArea()
            VStack {
                Spacer()
                HStack {
                    Text(message)
                        .padding()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.gray)
                .cornerRadius(40)
            .padding(.horizontal, 20)
//                    .padding(.vertical, 10)
            }
            .frame(maxWidth: .infinity)
            .transition(.move(edge: .bottom))
            .animation(.easeInOut(duration: 0.3))
            .padding()
        }
    }
}

extension View {
    func toast(isPresented: Binding<Bool>, message: String) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                ToastView(message: message)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isPresented.wrappedValue = false
                            }
                        }
                    }
                    .zIndex(/*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
            }
        }
    }
}

#Preview {
    TradeSheet(symbol: "AAPL", name: "Apple Inc")
}
