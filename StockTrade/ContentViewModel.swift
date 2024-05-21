//
//  ContentViewModel.swift
//  StockTrade
//
//  Created by Gaurav Baisware on 4/15/24.
//

import Foundation
import Alamofire

class ContentViewModel: ObservableObject {
    @Published var stock_ticker = ""
    @Published var stocksDataForPortfolio: [StockInfo] = []
    @Published var portfolioData: [PortFolioElement] = []
    @Published var favourites: [WatchListElement] = []
    @Published var cashBalance: Double = 0.0
    @Published var netWorth: Double = 0.0
    @Published var isEditable = false
    @Published var timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    @Published var portfolioUpdated = false
    @Published var favouritesUpdated = false
    @Published var isLoading = true

    func fetchData() {
        fetchPortfolioAndWallet { result in
            switch result {
            case .success(let portfolio):
                fetchFavourites { result in
                    switch result {
                    case .success(let watchlist):
                        self.favourites = watchlist
                        self.cashBalance = portfolio.wallet_account.amount
                        self.portfolioData = portfolio.portfolio
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.updateFavourites()
                            self.updateStockDataList()
                        }
                        
                    case .failure(let error):
                        print("Error fetching watchlist data: \(error.localizedDescription)")
//                        self.favourites = []
                    }
                }
            case .failure(let error):
                print("Error fetching portfolio data: \(error.localizedDescription)")
//                self.portfolioData = []
            }
        }
    }

    func updateFavourites() {
        let dispatchGroup = DispatchGroup()
        var favouritesData: [WatchListElement] = []
        for element in self.favourites {
            dispatchGroup.enter()
            fetchLatestPrice(stock_ticker: element.stock_ticker) { latest_price_info in
                switch latest_price_info {
                case .success(let price_info):
                    let stock = WatchListElement( id: element.id
                                                , stock_ticker: element.stock_ticker
                                                , stock_company: element.stock_company
                                                , current_price: price_info.c
                                                , change_in_price: price_info.d
                                                , change_in_price_percentage: price_info.dp / 100
                    )
                    favouritesData.append(stock)
                case .failure(let error):
                    print("Error fetching watchlist data: \(error.localizedDescription)")
//                    self.favourites = []
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            self.favourites = favouritesData
            print("Updated Favs : \(self.favourites)")
            self.favouritesUpdated = true
            self.isLoading = !(self.portfolioUpdated && self.favouritesUpdated)
        }
    }

    func updateStockDataList() {
        let dispatchGroup = DispatchGroup()
        var portFolioElementsData: [StockInfo] = []
        for element in self.portfolioData {
            dispatchGroup.enter()
            fetchLatestPrice(stock_ticker: element.stock_ticker) { latest_price_info in
                switch latest_price_info {
                case .success(let price_info):
                    var stock = StockInfo( id: element.id
                                          , stock_ticker: element.stock_ticker
                                          , quantity: element.quantity
                                          , stock_company: element.stock_company
                                          , total_cost: element.total_cost
                                          , current_price: price_info.c
                    )
                    stock.market_value = getMarketValue(stock_info: stock)
                    stock.change_in_price = getChangeInPrice(stock_info: stock)
                    stock.change_in_price_percentage = getChangeInPricePercent(stock_info: stock)
                    portFolioElementsData.append(stock)
                case .failure(let error):
                    print("Error fetching portfolio data: \(error.localizedDescription)")
//                    self.portfolioData = []
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            self.stocksDataForPortfolio = portFolioElementsData
            print("Updated Port : \(self.stocksDataForPortfolio)")
            self.updateNetWorth()
            self.portfolioUpdated = true
            self.isLoading = !(self.portfolioUpdated && self.favouritesUpdated)
        }
    }

    func updateNetWorth() {
        var totalNetWorth = self.cashBalance
        for stock in self.stocksDataForPortfolio {
            totalNetWorth += stock.market_value ?? 0.0
        }
        self.netWorth = totalNetWorth
    }
}
