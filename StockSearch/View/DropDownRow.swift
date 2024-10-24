import SwiftUI

struct DropDownRow: View {
    @ObservedObject var viewModel: AutocompleteViewModel
    @ObservedObject var wViewModel: WatchlistViewModel
    @ObservedObject var pViewModel: PortfolioViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.stock, id: \.self) { item in
                NavigationLink(destination: StockInfo(symbol: item.displaySymbol, wViewModel: wViewModel, pViewModel: pViewModel)) {
                    VStack(alignment: .leading) {
                        Text(item.displaySymbol)
                            .font(.headline)
                        Text(item.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
//            NavigationLink(destination: StockInfo(symbol: "AAPL", wViewModel: wViewModel)) {
//                VStack(alignment: .leading) {
//                    Text("AAPL")
//                        .font(.headline)
//                    Text("Apple Inc.")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                }
//            }
        }
    }
}

struct DropDownRow_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AutocompleteViewModel()
        let wViewModel = WatchlistViewModel()
        let pViewModel = PortfolioViewModel()
        NavigationView {
            DropDownRow(viewModel: viewModel, wViewModel: wViewModel, pViewModel: pViewModel)
            }
        }
}


