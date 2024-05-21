//
//  StockDetails.swift
//  StockTrade
//
//  Created by Gaurav Baisware on 4/21/24.
//

import SwiftUI
import Kingfisher

struct StockDetails: View {
    @StateObject var stockModel = StockDetailsModel()

    var stock_ticker: String
    var viewModel: ContentViewModel
    @State private var selectedNews: TopNewsElement? = nil
    @State private var displayTradeSheet: Bool = false
    @Environment(\.dismiss) var stockDetailsPageDismiss
    
    var body: some View {
        if stockModel.isLoading {
            VStack(alignment: .center, content: {
                Spacer()
                ProgressView("Fetching Data...")
                Spacer()
            })
            .frame(maxHeight: .infinity)
            .onAppear(){
                stockModel.stock_ticker = self.stock_ticker
                stockModel.fetchStockData()
            }
        } else {
            ScrollView {
                VStack(alignment: .leading, content: {
                    HStack{
                        Text(stockModel.stock_info.name)
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                        Spacer()
                        KFImage(URL(string: stockModel.stock_info.logo))
                            .cacheMemoryOnly()
                            .onFailure { error in
                                print("Error fetching Logo : \(error.localizedDescription)")
                            }
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .cornerRadius(6)
                    }
                    .padding(.horizontal)
                    HStack {
                        Text(getCurrencyFormat(value: stockModel.current_price))
                            .font(.system(size: 36))
                            .fontWeight(.bold)
                            .padding(.trailing, 1)
                        HStack (alignment: .bottom, content: {
                            Image(systemName: String(format: "%.2f", abs(stockModel.change_in_price)) == "0.00" ? "minus" : (stockModel.change_in_price > 0.0 ? "arrow.up.forward" : "arrow.down.forward"))
                                .font(.system(size: 18))
                                .foregroundColor(String(format: "%.2f", abs(stockModel.change_in_price)) == "0.00" ? .secondary :(stockModel.change_in_price > 0.0 ? .green : .red))
                            (Text(getCurrencyFormat(value: stockModel.change_in_price)) + Text(" (") + Text(getPercentageFormat(value: stockModel.change_in_price_percentage)) + Text(")"))
                                .font(.system(size: 18))
                                .foregroundColor(String(format: "%.2f", abs(stockModel.change_in_price)) == "0.00" ? .secondary :(stockModel.change_in_price > 0.0 ? .green : .red))
                        })
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 3)
                    HStack{
                        ChartsView(stockModel: stockModel, stock_ticker: stockModel.stock_ticker, hourly_chart_data: stockModel.hourly_chart_data, historical_chart_data: stockModel.historical_chart_data, change_in_price: stockModel.change_in_price)
                    }
                    .frame(maxWidth: .infinity, minHeight: 440)
                    .padding(.bottom, 4)
                    Text("Portfolio")
                        .font(.system(size: 24))
                        .padding(.horizontal)
                    HStack{
                        VStack(alignment: .leading, content: {
                            if (stockModel.stockPortfolioData?.quantity ?? 0 > 0) {
                                HStack{
                                    Text("Shares Owned: ")
                                        .fontWeight(.semibold)
                                    Text("\(stockModel.stockPortfolioData?.quantity ?? 0)")
                                }
                                    .padding(.vertical, 0.5)
                                HStack{
                                    Text("Avg. Cost/Share: ")
                                        .fontWeight(.semibold)
                                    Text("\(getCurrencyFormat(value: stockModel.avg_cost_per_share))")
                                }
                                    .padding(.vertical, 0.5)
                                HStack{
                                    Text("Total Cost: ")
                                        .fontWeight(.semibold)
                                    Text("\(getCurrencyFormat(value: stockModel.stockPortfolioData?.total_cost ?? 0.0))")
                                }
                                    .padding(.vertical, 0.5)
                                HStack{
                                    Text("Change: ")
                                        .fontWeight(.semibold)
                                    Text("\(getCurrencyFormat(value: stockModel.change_from_total_cost))")
                                }
                                    .foregroundColor(String(format: "%.2f", abs(stockModel.change_from_total_cost)) == "0.00" ? .secondary :(stockModel.change_from_total_cost > 0.0 ? .green : .red))
                                    .padding(.vertical, 0.5)
                                HStack{
                                    Text("Market Value: ")
                                        .fontWeight(.semibold)
                                    Text("\(getCurrencyFormat(value: stockModel.market_value))")
                                }
                                    .foregroundColor(String(format: "%.2f", abs(stockModel.change_from_total_cost)) == "0.00" ? .secondary :(stockModel.change_from_total_cost > 0.0 ? .green : .red))
                                    .padding(.vertical, 0.5)
                            } else {
                                Text("You have 0 shares of \(stockModel.stock_ticker).")
                                Text("Start Trading!")
                            }
                        })
                        .font(.system(size: 14))
                        Spacer()
                        Button("Trade") {
                        }
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding()
                        .padding(.horizontal, 36)
                        .background(Color.green)
                        .cornerRadius(40)
                        .onTapGesture {
                            displayTradeSheet = true
                        }
                        .sheet(isPresented: $displayTradeSheet, content: {
                            TradeSheetView(stock_info: stockModel.stock_info, stockPortfolioData: stockModel.stockPortfolioData ?? getDefaultPortfolioElement(ticker: stockModel.stock_info.ticker, name: stockModel.stock_info.name), cashBalance: stockModel.cashBalance, current_price: stockModel.current_price, stockModel: stockModel, stockDetailsView: self, viewModel: self.viewModel)
                        })
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    Text("Stats")
                        .font(.system(size: 24))
                        .padding(.horizontal)
                    HStack(spacing: 0, content: {
                        VStack(content: {
                            HStack{
                                Text("High Price: ")
                                    .fontWeight(.semibold)
                                Text(getCurrencyFormat(value: stockModel.high_price))
                            }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 3)
                            HStack{
                                Text("Low Price: ")
                                    .fontWeight(.semibold)
                                Text(getCurrencyFormat(value: stockModel.low_price))
                            }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 3)
                        })
                        .frame(minWidth: 0, maxWidth: .infinity)
                        VStack(content: {
                            HStack{
                                Text("Open Price: ")
                                    .fontWeight(.semibold)
                                Text(getCurrencyFormat(value: stockModel.open_price))
                            }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 3)
                            HStack{
                                Text("Prev. Price: ")
                                    .fontWeight(.semibold)
                                Text(getCurrencyFormat(value: stockModel.prev_close_price))
                            }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 3)
                        })
                        .frame(minWidth: 0, maxWidth: .infinity)
                    })
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                    .font(.system(size: 14))
                    Text("About")
                        .font(.system(size: 24))
                        .padding(.horizontal)
                    HStack(spacing: 0, content: {
                        VStack(content: {
                            Text("IPO Start Date:")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 0.2)
                                .fontWeight(.semibold)
                            Text("Industry:")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 0.2)
                                .fontWeight(.semibold)
                            Text("Webpage:")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 0.2)
                                .fontWeight(.semibold)
                            Text("Company Peers:")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 0.2)
                                .fontWeight(.semibold)
                        })
                        .frame(minWidth: 0, maxWidth: .infinity)
                        VStack(content: {
                            Text(stockModel.stock_info.ipo ?? "1980-01-01")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 0.2)
                                .lineLimit(1)
                            Text(stockModel.stock_info.finnhubIndustry ?? "Technology")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 0.2)
                                .lineLimit(1)
                            Link(stockModel.stock_info.weburl, destination: URL(string: stockModel.stock_info.weburl)!)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 0.2)
                                .lineLimit(1)
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(stockModel.peers_list, id: \.self) { index in
                                        NavigationLink(destination: StockDetails( stock_ticker: index, viewModel: self.viewModel)){
                                            Text("\(index),")
                                        }
                                    }
                                }
                            }
                            .transition(.move(edge: .bottom))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 0.2)
                        })
                        .frame(maxWidth: .infinity)
                    })
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                    .font(.system(size: 14))
                    Text("Insights")
                        .font(.system(size: 24))
                        .padding(.horizontal)
                        .padding(.bottom, 6)
                    VStack(spacing: 0) {
                        HStack(alignment: .center, spacing: 0, content: {
                            Text("Insider Sentiments")
                                .font(.system(size: 22))
                                .bold()
                                .frame(maxWidth: .infinity)
                        })
                        .padding(.bottom, 10)
                        HStack(alignment: .center, spacing: 18, content: {
                            VStack(alignment: .leading, spacing: 10, content: {
                                Text(stockModel.stock_info.name)
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                                Divider()
                                    .background(Color.gray)
                                    .padding(.bottom, 1)
                                Text("Total")
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                                Divider()
                                    .background(Color.gray)
                                    .padding(.bottom, 1)
                                Text("Positive")
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                                Divider()
                                    .background(Color.gray)
                                    .padding(.bottom, 1)
                                Text("Negative")
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                                Divider()
                                    .background(Color.gray)
                                    .padding(.bottom, 1)
                            })
                            VStack(alignment: .leading, spacing: 10, content: {
                                Text("MSPR")
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Divider()
                                    .background(Color.gray)
                                    .padding(.bottom, 1)
                                Text(String(format: "%.2f", stockModel.total_mspr))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                                Divider()
                                    .background(Color.gray)
                                    .padding(.bottom, 1)
                                Text(String(format: "%.2f", stockModel.positive_mspr))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                                Divider()
                                    .background(Color.gray)
                                    .padding(.bottom, 1)
                                Text(String(format: "%.2f", stockModel.negative_mspr))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                                Divider()
                                    .background(Color.gray)
                                    .padding(.bottom, 1)
                            })
                            VStack(alignment: .leading, spacing: 10, content: {
                                Text("Change")
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Divider()
                                    .background(Color.gray)
                                    .padding(.bottom, 1)
                                Text(String(format: "%.2f", stockModel.total_change))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                                Divider()
                                    .background(Color.gray)
                                    .padding(.bottom, 1)
                                Text(String(format: "%.2f", stockModel.positive_change))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                                Divider()
                                    .background(Color.gray)
                                    .padding(.bottom, 1)
                                Text(String(format: "%.2f", stockModel.negative_change))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                                Divider()
                                    .background(Color.gray)
                                    .padding(.bottom, 1)
                            })
                        })
                    }
                    .font(.system(size: 14))
                    .padding(.horizontal)
                    .padding(.bottom, 36)
                    HStack{
                        RecommendationTrendsChartComponent(recommendationTrendsSeriesData: stockModel.recommendation_trends_chart_data)
                    }
                    .frame(maxWidth: .infinity, minHeight: 410)
                    .padding(.bottom, 24)
                    HStack{
                        EPSChartsComponent(epsChartsData: stockModel.eps_chart_data)
                    }
                    .padding(.bottom, 18)
                    .frame(maxWidth: .infinity, minHeight: 410)
                    Text("News")
                        .font(.system(size: 24))
                        .padding(.horizontal)
                    ForEach(stockModel.top_news.indices, id: \.self) { index in
                        let news_element = stockModel.top_news[index]
                        VStack{
                            if (news_element == stockModel.top_news.first){
                                VStack(alignment: .leading) {
                                    KFImage(URL(string: news_element.image))
                                        .cacheMemoryOnly()
                                        .onFailure { error in
                                            print("Error fetching news image : \(error.localizedDescription)")
                                        }
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                                        .cornerRadius(10)
                                        .padding(.bottom, 8)
                                    HStack{
                                        Text(news_element.source)
                                            .fontWeight(.semibold)
                                        Text(getRelativeDateTime(from: news_element.datetime))
                                    }
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 13))
                                        .padding(.bottom, 2)
                                    Text(news_element.headline)
                                        .bold()
                                        .lineLimit(3)
                                        .font(.system(size: 16))
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 6)
                            } else {
                                HStack (alignment: .top) {
                                    VStack(alignment: .leading) {
                                        HStack{
                                            Text(news_element.source)
                                                .fontWeight(.semibold)
                                            Text(getRelativeDateTime(from: news_element.datetime))
                                        }
                                            .foregroundColor(.secondary)
                                            .font(.system(size: 13))
                                            .padding(.bottom, 2)
                                        Text(news_element.headline)
                                            .bold()
                                            .lineLimit(3)
                                            .font(.system(size: 16))
                                    }
                                    Spacer()
                                    KFImage(URL(string: news_element.image))
                                        .cacheMemoryOnly()
                                        .onFailure { error in
                                            print("Error fetching news image : \(error.localizedDescription)")
                                        }
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 90, height: 90)
                                        .cornerRadius(10)
                                }
                                .padding(.horizontal)
                                .frame(height: 100)
                            }
                        }
                        .onTapGesture {
                            selectedNews = news_element
                        }
                        .sheet(item: $selectedNews) { news_element in
                            NewsSheetView(news_element: news_element)
                        }
                    }
                })
            }
            .toast(isShowing: $stockModel.shouldShowFavouriteToast, text: Text(stockModel.favouriteToastMessage))
            .onAppear(){
                stockModel.stock_ticker = self.stock_ticker
                stockModel.fetchStockData()
            }
            .navigationTitle(self.stockModel.isLoading ? "" : self.stock_ticker)
            .navigationBarItems(trailing: Button(action: {
                stockModel.addOrRemoveFromFavourites()
                print(stockModel)
                viewModel.fetchData()
            }) {
                Image(systemName: stockModel.isInFavourite ? "plus.circle.fill" : "plus.circle")
                    .foregroundColor(.blue)
            }
                .buttonStyle(PlainButtonStyle()))
        }
    }
}
