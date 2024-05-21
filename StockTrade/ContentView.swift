//
//  ContentView.swift
//  StockTrade
//
//  Created by Gaurav Baisware on 4/8/24.
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
    @State private var stockSymbolOptions: [StockSymbolOption] = []
    @State private var searchTimer: Timer?
    @State private var isSearchActive: Bool = false
    
    func fetchAutocompleteOptions(for query: String) {
        guard !query.isEmpty else {
            stockSymbolOptions = []
            return
        }

        let url = "https://assignment-3-backend-lctarnhjkq-wl.a.run.app/getStockSymbols/"+query
        AF.request(url).responseDecodable(of: [StockSymbolOption].self) { response in
            switch response.result {
            case .success(let options):
                stockSymbolOptions = options
            case .failure(let error):
                print("Error: \(error)")
                stockSymbolOptions = []
            }
        }
    }
    
    private var mainContent: some View{
        Form {
            Section {
                Text(Date.now.formatted(date: .long, time: .omitted))
                    .font(.title)
                    .foregroundColor(Color.gray)
                    .bold()
                    .padding(.horizontal, 2.0)
                    .padding(.vertical, 4.0)
            }
            PortfolioSection(viewModel: self.viewModel)
            FavouritesSection(viewModel: self.viewModel)
            FooterSection()
        }
    }
    
    private var searchResults: some View {
        Group {
            if !stockSymbolOptions.isEmpty {
                List($stockSymbolOptions, id: \.id) { option in
                    NavigationLink(destination: StockDetails(stock_ticker: option.displaySymbol.wrappedValue, viewModel: self.viewModel)) {
                        VStack(alignment: .leading) {
                            Text(option.displaySymbol.wrappedValue)
                                .font(.system(size: 22))
                                .fontWeight(.bold)
                            Text(option.description.wrappedValue)
                                .foregroundColor(.secondary)
                                .font(.system(size: 16))
                        }
                    }
                }
                .background(Color.white.opacity(0.9))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .zIndex(1)
    }
    
    private func debounceSearch() {
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.fetchAutocompleteOptions(for: self.viewModel.stock_ticker)
        }
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                if viewModel.isLoading {
                    ProgressView("Fetching Data...")
                } else {
                    if !self.isSearchActive {
                        mainContent
                    }
                    searchResults
                }
            }
            .navigationTitle("Stocks")
            .onAppear {
                viewModel.fetchData()
            }
            .toolbar {
                ToolbarItem() {
                    EditButton()
                }
            }
            .searchable(text: $viewModel.stock_ticker, placement: .navigationBarDrawer(displayMode: .always)) {
                EmptyView()
            }
            .onChange(of: $viewModel.stock_ticker.wrappedValue) {
                self.isSearchActive = viewModel.stock_ticker != ""
                debounceSearch()
            }
        }
    }
}

#Preview {
    ContentView()
}
