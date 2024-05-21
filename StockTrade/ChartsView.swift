//
//  ChartsView.swift
//  StockTrade
//
//  Created by Gaurav Baisware on 4/29/24.
//

import Foundation
import SwiftUI

struct ChartsView: View {
    var stockModel: StockDetailsModel
    var stock_ticker: String
    var hourly_chart_data: [PointDetails]
    var historical_chart_data: [PointDetails]
    var change_in_price: Double
    
    var body: some View{
        TabView{
            HourlyChartComponent(stockTicker: stock_ticker, hourlyChartData: hourly_chart_data, changeInPrice: change_in_price)
                .tabItem {
                    Label("Hourly", systemImage: "chart.xyaxis.line")
                }
            HistoricalChartComponent(stockTicker: stock_ticker, historicalChartData: historical_chart_data)
                .tabItem {
                    Label("Historical", systemImage: "clock")
                }
        }
        .onAppear(perform: {
            stockModel.updateChartsData()
        })
    }
}
