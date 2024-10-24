import SwiftUI
import Alamofire
import SwiftyJSON

struct Watchlist: View {
    @ObservedObject var viewModel: WatchlistViewModel
    @ObservedObject var pviewModel: PortfolioViewModel
    @State private var stockData: [String: JSON] = [:]

    var body: some View {
        ForEach(viewModel.watchlistData, id: \.self) { stockSymbol in
            NavigationLink(destination: StockInfo(symbol: stockSymbol.symbol, wViewModel: viewModel, pViewModel: pviewModel)) {
                if let data = stockData[stockSymbol.symbol] {
                    VStack {
                        HStack {
                            Text(stockSymbol.symbol)
                                .font(.system(size: 22))
                                .bold()
                            Spacer()
                            Text("$\(data["c"].doubleValue, specifier: "%.2f")")
                                .font(.headline)
                        }
                        HStack {
                            Text(stockSymbol.name)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Spacer()
                            if(data["d"].doubleValue >= 0.0) {
                                Image(systemName: "line.diagonal.arrow")
                                    .foregroundColor(.green)
                                    .font(.system(size: 16))
                            } else {
                                Image(systemName: "line.diagonal.arrow")
                                    .rotationEffect(Angle(degrees: 90))
                                    .foregroundColor(.red)
                                    .font(.system(size: 16))
                            }
                            
                            Text("\(data["d"].doubleValue, specifier: "%.2f")")
                                .font(.system(size: 16))
                                .foregroundColor(data["d"].doubleValue >= 0.0 ? .green : .red)
                            Text("(\(data["dp"].doubleValue, specifier: "%.2f")%)")
                                .font(.system(size: 16))
                                .foregroundColor(data["d"].doubleValue >= 0.0 ? .green : .red)
                        }
                    }
                } else {
                    Text("Loading...")
                }
            }
        }
        .onDelete(perform: { indexSet in
            //reference taken: https://stackoverflow.com/questions/56790502/list-with-drag-and-drop-to-reorder-on-swiftui
            for index in indexSet {
                    let removedSymbol = viewModel.watchlistData[index].symbol
                AF.request("API/api/v1/delete-symbol-watchlist?symbol=\(removedSymbol)", method: .delete)
                    .validate()
                    .response { response in
                        switch response.result {
                        case .success:
                    
                            print("Symbol \(removedSymbol) deleted successfully")
                        case .failure(let error):
                    
                            print("Error: \(error)")
                        }
                    }
                }
            viewModel.watchlistData.remove(atOffsets: indexSet)
            
        })
        .onMove(perform: { indices, newOffset in
                    viewModel.watchlistData.move(fromOffsets: indices, toOffset: newOffset)
                })
        .onAppear {
            fetchStockData()
        }
    }

    private func fetchStockData() {
        let symbols = viewModel.watchlistData.map { $0.symbol }

        for symbol in symbols {
            AF.request("API/api/v1/quote?symbol=\(symbol)").responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    stockData[symbol] = json
                case .failure(let error):
                    print("Error fetching data for \(symbol): \(error)")
                }
            }
        }
    }
}




//struct Watchlist_Previews: PreviewProvider {
//    static var previews: some View {
//        let viewModel = WatchlistViewModel()
//        Watchlist(viewModel: viewModel)
//    }
//}
