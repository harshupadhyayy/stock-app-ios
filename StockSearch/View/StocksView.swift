//
//  StocksView.swift
//  StockSearch
//
//  Created by Harsh Upadhyay on 4/4/24.
//

import SwiftUI
import Alamofire
import SwiftyJSON
import Combine

class WatchlistViewModel: ObservableObject {
    @Published var watchlistData: [StockItem] = []
}



struct StockItem: Identifiable, Decodable, Hashable {
    let id = UUID()
    let name: String
    let symbol: String
}

struct StocksView: View {
    let pViewModel = PortfolioViewModel()
    @State private var searchText = ""
    @State private var isLoading = false
    let autocomViewModel = AutocompleteViewModel()
    @State private var loading = true
    let watchlistViewModel = WatchlistViewModel()
    
    func getCurrentDate() -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM d, yyyy"
            return dateFormatter.string(from: Date())
        }
    
    @State private var searchTextPublisher = PassthroughSubject<String, Never>()
    private var cancellable: AnyCancellable?
    
    var body: some View {
        if !loading {
            NavigationStack {
                Group {
                    if searchText.isEmpty {
                        
                        List {
                            Section {
                                let formattedDate = getCurrentDate()
                                HStack {
                                    Text("\(formattedDate)")
                                        .foregroundStyle(.gray)
                                        .font(.system(size: 28))
                                    .bold()
                                    Spacer()
                                }
                            }
                            .frame(width: 200, height: 40)
                            
                            
                            Section(header: Text("PORTFOLIO")) {
                                Portfolio(viewModel: pViewModel, wViewModel: watchlistViewModel)
                            }
                            
                            
                            
                            
                            Section(header: Text("FAVORITES")) {
                                Watchlist(viewModel: watchlistViewModel, pviewModel: pViewModel)
                            }
                            
                            Section {
                                HStack {
                                    Spacer()
                                    Link("Powered by Finnhub.io",
                                         destination: URL(string: "https://finnhub.io/")!)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    Spacer()
                                }
                                
                            }
                        }
                        
                        .navigationTitle("Stocks")
                        .navigationBarItems(trailing:
                                            EditButton()
                                        )
                    } else {
                        DropDownRow(viewModel: autocomViewModel, wViewModel: watchlistViewModel, pViewModel: pViewModel)
                    }
                }
                .searchable(text: $searchText)
//                .onChange(of: searchText) {
//                    autocomViewModel.fetchResults(query: searchText)
////                    print("this is executing")
////                    print(searchText)
//                }
                .onReceive(searchTextPublisher.debounce(for: 0.5, scheduler: RunLoop.main)) { text in
                                    autocomViewModel.fetchResults(query: text)
                                }
                                .onReceive(Just(searchText)) { searchText in
                                    self.searchTextPublisher.send(searchText)
                                }
                .disableAutocorrection(true)
                .autocapitalization(.none)
            }

        } else {
            ProgressView()
                .onAppear{fetchData()}
        }
                
    }
    
    private func fetchData() {
        let group = DispatchGroup()
        
        group.enter()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
//            AF.request("API/api/v1/fetch-watchlist").responseJSON { response in
//                switch response.result {
//                case .success(let value):
//                    let json = JSON(value)
//                    print(json)
//                    self.watchlistData = json
//                    
//                case .failure(let error):
//                    print("Error: \(error)")
//                }
//                group.leave()
//            }
//        }
        AF.request("API/api/v1/fetch-watchlist")
            .responseDecodable(of: [StockItem].self) { response in
                switch response.result {
                case .success(let posts):
                    watchlistViewModel.watchlistData = posts
//                    print(watchlistViewModel.watchlistData)
                case .failure(let error):
                    print(error)
                }
                group.leave()
            }
        
        group.notify(queue: .main) {
            loading = false
        }

    }
}

#Preview {
    StocksView()
}
