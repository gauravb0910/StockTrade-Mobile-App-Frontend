//
//  PortfolioSection.swift
//  StockTrade
//
//  Created by Gaurav Baisware on 4/15/24.
//

import SwiftUI

struct PortfolioSection: View {
    @ObservedObject var viewModel: ContentViewModel

    var body: some View {
        Section(header: Text("PORTFOLIO"), content: {
            HStack{
                VStack(alignment: .leading, content: {
                    Text("Net Worth")
                        .font(.system(size: 18))
                    Text(viewModel.netWorth, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                })
                Spacer()
                VStack (alignment: .leading, content: {
                    Text("Cash Balance")
                        .font(.system(size: 18))
                    Text(viewModel.cashBalance, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                })
            }
            List {
                ForEach($viewModel.stocksDataForPortfolio, id: \.self.id) { element in
                    NavigationLink(destination: StockDetails(stock_ticker: element.stock_ticker.wrappedValue, viewModel: self.viewModel)) {
                        VStack{
                            HStack(alignment: .center, content: {
                                Text(element.stock_ticker.wrappedValue)
                                    .font(.system(size: 24))
                                    .fontWeight(.semibold)
                                Spacer()
                                Text(getCurrencyFormat(value: element.market_value.wrappedValue ?? 0.0))
                                    .fontWeight(.semibold)
                            })
                            HStack(alignment: .center, content: {
                                Text("\(element.quantity.wrappedValue) shares")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 16))
                                Spacer()
                                Image(systemName: String(format: "%.2f", abs(element.change_in_price.wrappedValue ?? 0.0)) == "0.00" ? "minus" : (element.change_in_price.wrappedValue ?? 0.0 > 0.0 ? "arrow.up.forward" : "arrow.down.forward"))
                                    .foregroundColor(String(format: "%.2f", abs(element.change_in_price.wrappedValue ?? 0.0)) == "0.00" ? .secondary :(element.change_in_price.wrappedValue ?? 0.0 > 0.0 ? .green : .red))
                                (Text(getCurrencyFormat(value: element.change_in_price.wrappedValue ?? 0.0)) + Text(" (") + Text(getPercentageFormat(value: element.change_in_price_percentage.wrappedValue ?? 0.0)) + Text(")"))
                                    .foregroundColor(String(format: "%.2f", abs(element.change_in_price.wrappedValue ?? 0.0)) == "0.00" ? .secondary :(element.change_in_price.wrappedValue ?? 0.0 > 0.0 ? .green : .red))
                            })
                        }
                    }
                }
                .onMove(perform: { indices, newOffset in
                    viewModel.stocksDataForPortfolio.move(fromOffsets: indices, toOffset: newOffset)
                    withAnimation {
                        viewModel.isEditable = false
                    }
                })
                .onLongPressGesture {
                    withAnimation {
                        viewModel.isEditable = true
                    }
                }
            }
            .environment(\.editMode, viewModel.isEditable ? .constant(.active) : .constant(.inactive))
            .padding(.horizontal, 5.0)
        })
        .onReceive(viewModel.timer) { _ in
            viewModel.updateStockDataList()
        }
    }
}
