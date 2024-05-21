//
//  StockDetailsModel.swift
//  StockTrade
//
//  Created by Gaurav Baisware on 4/21/24.
//

import Foundation

class StockDetailsModel: ObservableObject {
    @Published var stock_ticker = ""
    
    @Published var stock_info: StockInfoData = getDefaultStockInfoData()
    @Published var stockPortfolioData: PortFolioElement?
    @Published var peers_list: [String] = []
    @Published var top_news: [TopNewsElement] = []
    @Published var hourly_chart_data: [PointDetails] = []
    @Published var hourly_chart_data_count: Int64 = 0
    @Published var historical_chart_data: [PointDetails] = []
    @Published var recommendation_trends_chart_data: [StockRecommendationElement] = []
    @Published var eps_chart_data: [StockEarningsElement] = []
    
    @Published var current_price: Double = 0.0
    @Published var change_in_price: Double = 0.0
    @Published var change_in_price_percentage: Double = 0.0
    @Published var high_price: Double = 0.0
    @Published var low_price: Double = 0.0
    @Published var open_price: Double = 0.0
    @Published var prev_close_price: Double = 0.0
    @Published var avg_cost_per_share: Double = 0.0
    @Published var market_value: Double = 0.0
    @Published var change_from_total_cost: Double = 0.0
    @Published var cashBalance: Double = 0.0
    @Published var total_mspr: Double = 0.0
    @Published var positive_mspr: Double = 0.0
    @Published var negative_mspr: Double = 0.0
    @Published var total_change: Double = 0.0
    @Published var positive_change: Double = 0.0
    @Published var negative_change: Double = 0.0
    @Published var isInFavourite = false
    @Published var timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    @Published var favouriteToastMessage: String = ""
    @Published var successfulToastMessage: String = ""
    
    @Published var stockPortfolioUpdated = false
    @Published var shouldShowFavouriteToast = false
    @Published var stockInfoUpdated = false
    @Published var stockFavouriteUpdated = false
    @Published var peersListUpdated = false
    @Published var insiderSentimentUpdated = false
    @Published var topNewsUpdated = false
    @Published var hourlyChartDataUpdated = false
    @Published var historicalChartDataUpdated = false
    @Published var recommendationTrendsChartDataUpdated = false
    @Published var epsChartDataUpdated = false
    @Published var isLoading = true

    func fetchStockData() {
        fetchStockPortfolioAndWallet(stock_ticker: self.stock_ticker) { result in
            switch result {
            case .success(let portfolio):
                self.cashBalance = portfolio.wallet_account.amount
                self.stockPortfolioUpdated = true
                self.updateStockInfo(portfolio: portfolio)
                self.updateCompanyPeers()
                self.updateInsiderSentimentDetails()
                self.updateTopNews()
                self.updateChartsData()
                fetchStockFavourite(stock_ticker: self.stock_ticker) { result in
                    switch result {
                    case .success(let favourite):
                        self.isInFavourite = !(favourite==nil)
                        self.stockFavouriteUpdated = true
                        self.isLoading = false
                    case .failure(let error):
                        print("Error fetching watchlist data: \(error.localizedDescription)")
                        self.isInFavourite = false
                        self.isLoading = !(self.stockPortfolioUpdated && self.stockFavouriteUpdated && self.stockInfoUpdated && self.peersListUpdated && self.insiderSentimentUpdated && self.topNewsUpdated && self.hourlyChartDataUpdated && self.historicalChartDataUpdated && self.recommendationTrendsChartDataUpdated && self.epsChartDataUpdated)
                    }
                }
            case .failure(let error):
                print("Error fetching portfolio data for stock \(self.stock_ticker): \(error.localizedDescription)")
                self.isLoading = !(self.stockPortfolioUpdated && self.stockFavouriteUpdated && self.stockInfoUpdated && self.peersListUpdated && self.insiderSentimentUpdated && self.topNewsUpdated && self.hourlyChartDataUpdated && self.historicalChartDataUpdated && self.recommendationTrendsChartDataUpdated && self.epsChartDataUpdated)
            }
        }
    }
    
    func updateStockInfo(portfolio: StockPortfolioElement) {
        fetchCompanyInfo(stock_ticker: self.stock_ticker) { stock_info_data in
            switch stock_info_data {
            case .success(let stock_info):
                self.stock_info = stock_info
                self.stockPortfolioData = portfolio.portfolio_data ?? getDefaultPortfolioElement(ticker: stock_info.ticker, name:  stock_info.name)
                self.avg_cost_per_share = (self.stockPortfolioData?.total_cost ?? 0.0) / Double(self.stockPortfolioData?.quantity ?? 1)
                self.updateLatestPrice()
                self.stockInfoUpdated = true
                self.isLoading = !(self.stockPortfolioUpdated && self.stockFavouriteUpdated && self.stockInfoUpdated && self.peersListUpdated && self.insiderSentimentUpdated && self.topNewsUpdated && self.hourlyChartDataUpdated && self.historicalChartDataUpdated && self.recommendationTrendsChartDataUpdated && self.epsChartDataUpdated)
            case .failure(let error):
                print("Error fetching stock details data for \(self.stock_ticker): \(error.localizedDescription)")
                self.isLoading = !(self.stockPortfolioUpdated && self.stockFavouriteUpdated && self.stockInfoUpdated && self.peersListUpdated && self.insiderSentimentUpdated && self.topNewsUpdated && self.hourlyChartDataUpdated && self.historicalChartDataUpdated && self.recommendationTrendsChartDataUpdated && self.epsChartDataUpdated)
            }
        }
    }

    func updateLatestPrice() {
        fetchLatestPrice(stock_ticker: self.stock_ticker) { latest_price_info in
            switch latest_price_info {
            case .success(let price_info):
                self.current_price = price_info.c
                self.change_in_price = price_info.d
                self.change_in_price_percentage = price_info.dp
                self.high_price = price_info.h
                self.low_price = price_info.l
                self.open_price = price_info.o
                self.prev_close_price = price_info.pc
                self.market_value = Double(self.stockPortfolioData?.quantity ?? 0) * self.current_price
                self.change_from_total_cost = self.market_value - (self.stockPortfolioData?.total_cost ?? 0.0)
                self.isLoading = !(self.stockPortfolioUpdated && self.stockFavouriteUpdated && self.stockInfoUpdated && self.peersListUpdated && self.insiderSentimentUpdated && self.topNewsUpdated && self.hourlyChartDataUpdated && self.historicalChartDataUpdated && self.recommendationTrendsChartDataUpdated && self.epsChartDataUpdated)
            case .failure(let error):
                print("Error fetching price data for stock \(self.stock_ticker): \(error.localizedDescription)")
                self.isLoading = !(self.stockPortfolioUpdated && self.stockFavouriteUpdated && self.stockInfoUpdated && self.peersListUpdated && self.insiderSentimentUpdated && self.topNewsUpdated && self.hourlyChartDataUpdated && self.historicalChartDataUpdated && self.recommendationTrendsChartDataUpdated && self.epsChartDataUpdated)
            }
        }
    }
    
    func updateCompanyPeers() {
        fetchCompanyPeers(stock_ticker: self.stock_ticker) { peers_data in
            switch peers_data {
            case .success(let peers):
                self.peers_list = peers
                self.peersListUpdated = true
                self.isLoading = !(self.stockPortfolioUpdated && self.stockFavouriteUpdated && self.stockInfoUpdated && self.peersListUpdated && self.insiderSentimentUpdated && self.topNewsUpdated && self.hourlyChartDataUpdated && self.historicalChartDataUpdated && self.recommendationTrendsChartDataUpdated && self.epsChartDataUpdated)
            case .failure(let error):
                print("Error fetching company peers data for stock \(self.stock_ticker): \(error.localizedDescription)")
                self.isLoading = !(self.stockPortfolioUpdated && self.stockFavouriteUpdated && self.stockInfoUpdated && self.peersListUpdated && self.insiderSentimentUpdated && self.topNewsUpdated && self.hourlyChartDataUpdated && self.historicalChartDataUpdated && self.recommendationTrendsChartDataUpdated && self.epsChartDataUpdated)
            }
        }
    }
    
    func updateInsiderSentimentDetails() {
        fetchStockInsiderSentiment(stock_ticker: self.stock_ticker) { insider_sentiment_data in
            switch insider_sentiment_data {
            case .success(let insider_sentiment):
                let mspr_list = insider_sentiment.data.compactMap({ StockInsiderSentimentElement in
                    StockInsiderSentimentElement.mspr
                })
                self.total_mspr = mspr_list.reduce(0, +)
                self.positive_mspr = mspr_list.filter({ i in i>=0}).reduce(0, +)
                self.negative_mspr = mspr_list.filter({ i in i<0}).reduce(0, +)
                let change_list = insider_sentiment.data.compactMap({ StockInsiderSentimentElement in
                    StockInsiderSentimentElement.change
                })
                self.total_change = change_list.reduce(0, +)
                self.positive_change = change_list.filter({ i in i>=0}).reduce(0, +)
                self.negative_change = change_list.filter({ i in i<0}).reduce(0, +)
                self.insiderSentimentUpdated = true
                self.isLoading = !(self.stockPortfolioUpdated && self.stockFavouriteUpdated && self.stockInfoUpdated && self.peersListUpdated && self.insiderSentimentUpdated && self.topNewsUpdated && self.hourlyChartDataUpdated && self.historicalChartDataUpdated && self.recommendationTrendsChartDataUpdated && self.epsChartDataUpdated)
            case .failure(let error):
                print("Error fetching insider sentiments for stock \(self.stock_ticker): \(error.localizedDescription)")
                self.isLoading = !(self.stockPortfolioUpdated && self.stockFavouriteUpdated && self.stockInfoUpdated && self.peersListUpdated && self.insiderSentimentUpdated && self.topNewsUpdated && self.hourlyChartDataUpdated && self.historicalChartDataUpdated && self.recommendationTrendsChartDataUpdated && self.epsChartDataUpdated)
            }
        }
    }
    
    func updateTopNews() {
        fetchTopNews(stock_ticker: self.stock_ticker) { top_news_data in
            switch top_news_data {
            case .success(let top_news):
                DispatchQueue.main.async {
                    self.top_news = Array(top_news.prefix(20))
                    self.topNewsUpdated = true
                    self.isLoading = !(self.stockPortfolioUpdated && self.stockFavouriteUpdated && self.stockInfoUpdated && self.peersListUpdated && self.insiderSentimentUpdated && self.topNewsUpdated && self.hourlyChartDataUpdated && self.historicalChartDataUpdated && self.recommendationTrendsChartDataUpdated && self.epsChartDataUpdated)
                }
            case .failure(let error):
                print("Error fetching top news for stock \(self.stock_ticker): \(error.localizedDescription)")
                self.isLoading = !(self.stockPortfolioUpdated && self.stockFavouriteUpdated && self.stockInfoUpdated && self.peersListUpdated && self.insiderSentimentUpdated && self.topNewsUpdated && self.hourlyChartDataUpdated && self.historicalChartDataUpdated && self.recommendationTrendsChartDataUpdated && self.epsChartDataUpdated)
            }
        }
    }
    
    func updateChartsData() {
        fetchHourlyPriceData(stock_ticker: self.stock_ticker) { hourly_chart_data in
            switch hourly_chart_data {
            case .success(let data):
                self.hourly_chart_data = data.results
                self.hourly_chart_data_count = data.count
                self.hourlyChartDataUpdated = true
                self.isLoading = !(self.stockPortfolioUpdated && self.stockFavouriteUpdated && self.stockInfoUpdated && self.peersListUpdated && self.insiderSentimentUpdated && self.topNewsUpdated && self.hourlyChartDataUpdated && self.historicalChartDataUpdated && self.recommendationTrendsChartDataUpdated && self.epsChartDataUpdated)
            case .failure(let error):
                print("Error fetching hourly chart data for stock \(self.stock_ticker): \(error.localizedDescription)")
                self.isLoading = !(self.stockPortfolioUpdated && self.stockFavouriteUpdated && self.stockInfoUpdated && self.peersListUpdated && self.insiderSentimentUpdated && self.topNewsUpdated && self.hourlyChartDataUpdated && self.historicalChartDataUpdated && self.recommendationTrendsChartDataUpdated && self.epsChartDataUpdated)
            }
        }
        
        fetchHistoricalPriceData(stock_ticker: self.stock_ticker) { historical_chart_data in
            switch historical_chart_data {
            case .success(let data):
                self.historical_chart_data = data.results
                self.historicalChartDataUpdated = true
                self.isLoading = !(self.stockPortfolioUpdated && self.stockFavouriteUpdated && self.stockInfoUpdated && self.peersListUpdated && self.insiderSentimentUpdated && self.topNewsUpdated && self.hourlyChartDataUpdated && self.historicalChartDataUpdated && self.recommendationTrendsChartDataUpdated && self.epsChartDataUpdated)
            case .failure(let error):
                print("Error fetching hourly chart data for stock \(self.stock_ticker): \(error.localizedDescription)")
                self.isLoading = !(self.stockPortfolioUpdated && self.stockFavouriteUpdated && self.stockInfoUpdated && self.peersListUpdated && self.insiderSentimentUpdated && self.topNewsUpdated && self.hourlyChartDataUpdated && self.historicalChartDataUpdated && self.recommendationTrendsChartDataUpdated && self.epsChartDataUpdated)
            }
        }
        
        fetchStockRecommendation(stock_ticker: self.stock_ticker) { stock_recommendation_data in
            switch stock_recommendation_data {
            case .success(let data):
                self.recommendation_trends_chart_data = data
                self.recommendationTrendsChartDataUpdated = true
                self.isLoading = !(self.stockPortfolioUpdated && self.stockFavouriteUpdated && self.stockInfoUpdated && self.peersListUpdated && self.insiderSentimentUpdated && self.topNewsUpdated && self.hourlyChartDataUpdated && self.historicalChartDataUpdated && self.recommendationTrendsChartDataUpdated && self.epsChartDataUpdated)
            case .failure(let error):
                print("Error fetching hourly chart data for stock \(self.stock_ticker): \(error.localizedDescription)")
                self.isLoading = !(self.stockPortfolioUpdated && self.stockFavouriteUpdated && self.stockInfoUpdated && self.peersListUpdated && self.insiderSentimentUpdated && self.topNewsUpdated && self.hourlyChartDataUpdated && self.historicalChartDataUpdated && self.recommendationTrendsChartDataUpdated && self.epsChartDataUpdated)
            }
        }
        
        fetchStockEarnings(stock_ticker: self.stock_ticker) { stock_earnings_data in
            switch stock_earnings_data {
            case .success(let data):
                self.eps_chart_data = data
                self.epsChartDataUpdated = true
                self.isLoading = !(self.stockPortfolioUpdated && self.stockFavouriteUpdated && self.stockInfoUpdated && self.peersListUpdated && self.insiderSentimentUpdated && self.topNewsUpdated && self.hourlyChartDataUpdated && self.historicalChartDataUpdated && self.recommendationTrendsChartDataUpdated && self.epsChartDataUpdated)
            case .failure(let error):
                print("Error fetching hourly chart data for stock \(self.stock_ticker): \(error.localizedDescription)")
                self.isLoading = !(self.stockPortfolioUpdated && self.stockFavouriteUpdated && self.stockInfoUpdated && self.peersListUpdated && self.insiderSentimentUpdated && self.topNewsUpdated && self.hourlyChartDataUpdated && self.historicalChartDataUpdated && self.recommendationTrendsChartDataUpdated && self.epsChartDataUpdated)
            }
        }
    }
    
    func addOrRemoveFromFavourites() {
        if self.isInFavourite {
            deleteFavourites(stock_ticker: self.stock_ticker) { response in
                switch response {
                case .success(let resp):
                    if (resp.deletedCount == 1){
                        self.isInFavourite.toggle()
                        self.favouriteToastMessage = "Removing \(self.stock_ticker) from Favourites"
                        self.shouldShowFavouriteToast = true
                    }
                case .failure(let error):
                    print("Error deleting \(self.stock_ticker) from Watchlist : \(error.localizedDescription)")
                }
            }
        } else {
            addToFavourite(stock_ticker: self.stock_ticker, stock_company: self.stock_info.name) { response in
                switch response {
                case .success(let resp):
                    if resp.acknowledged{
                        self.isInFavourite.toggle()
                        self.favouriteToastMessage = "Adding \(self.stock_ticker) to Favourites"
                        self.shouldShowFavouriteToast = true
                    }
                case .failure(let error):
                    print("Error adding \(self.stock_ticker) to Watchlist : \(error.localizedDescription)")
                }
            }
        }
    }
    
}
