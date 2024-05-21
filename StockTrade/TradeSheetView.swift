//
//  TradeSheetView.swift
//  StockTrade
//
//  Created by Gaurav Baisware on 4/28/24.
//

import Foundation
import SwiftUI

struct TradeSheetView: View {
    var stock_info: StockInfoData
    var stockPortfolioData: PortFolioElement
    var cashBalance: Double
    var current_price: Double
    
    var stockModel: StockDetailsModel
    var stockDetailsView: StockDetails
    var viewModel: ContentViewModel
    @State private var displayTradeSuccessfulSheet: Bool = false
    @State private var quantity: Int64 = 0
    @State private var quantityString: String = ""
    @State private var isShowingToast: Bool = false
    @State private var toastMessage: Text = Text("")
    @State private var allStocksSold: Bool = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .center, content: {
            HStack{
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .padding()
                        .cornerRadius(8)
                        .font(.system(size: 18))
                }
                
            }
            Text("Trade \(stock_info.name) shares")
                .bold()
                .font(.system(size: 18))
            Spacer()
            HStack(alignment: .bottom, content: {
                TextField("0", text: Binding(
                    get: {
                        if let value = Int64(self.quantityString) {
                            return String(value)
                        } else {
                            return ""
                        }
                    },
                    set: {
                        if let value = Int64($0) {
                            self.quantity = value
                        } else {
                            if !($0 == "") {
                                self.isShowingToast = true
                                self.toastMessage = Text("Please enter a valid amount")
                            }
                            self.quantity = 0
                        }
                    }
                ))
                    .keyboardType(.decimalPad)
                    .font(.system(size: 110,  weight: .thin))
                    .foregroundColor(self.$quantity.wrappedValue == 0 ? .secondary : .black)
                Text(self.$quantity.wrappedValue < 2 ? "Share" : "Shares")
                    .font(.system(size: 38))
                    .padding(.bottom, 10)
            })
            HStack{
                Spacer()
                Text("x $\(String(format: "%.2f", current_price))/share = $\(String(format: "%.2f", current_price * Double(quantity)))")
                    .font(.system(size: 17))
            }
            Spacer()
            Text("$\(String(format: "%.2f", cashBalance)) available to buy \(stock_info.ticker)")
                .foregroundColor(.secondary)
                .font(.system(size: 14))
            HStack(alignment: .center, content: {
                Button(action: {
                    buyStocks(portfolio_element: stockPortfolioData, quantity_bought: quantity, cash_balance: cashBalance) { response in
                        switch response{
                        case .success(let resp):
                            if resp.contains("successfully") {
                                self.stockModel.successfulToastMessage = resp
                                self.displayTradeSuccessfulSheet = self.stockModel.successfulToastMessage.contains("successfully")
                            } else {
                                isShowingToast = true
                                toastMessage = Text(resp)
                            }
                        case .failure(let error):
                            isShowingToast = true
                            toastMessage = Text("Failed to buy stocks: \(error.localizedDescription)")
                        }
                    }
                }) {
                    Text("Buy")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(40)
                
                Button(action: {
                    sellStocks(portfolio_element: stockPortfolioData, quantity_sold: quantity, cash_balance: cashBalance) { response in
                        switch response{
                        case .success(let resp):
                            if resp.contains("successfully") {
                                self.stockModel.successfulToastMessage = resp
                                if (self.stockPortfolioData.quantity == quantity) {
                                    self.allStocksSold = true
                                }
                                self.displayTradeSuccessfulSheet = self.stockModel.successfulToastMessage.contains("successfully")
                            } else {
                                isShowingToast = true
                                toastMessage = Text(resp)
                            }
                        case .failure(let error):
                            isShowingToast = true
                            toastMessage = Text("Failed to sell stocks: \(error.localizedDescription)")
                        }
                    }
                }) {
                    Text("Sell")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(40)
                
            })
            .font(.system(size: 16))
        })
        .sheet(isPresented: $displayTradeSuccessfulSheet, content: {
            SuccessfulTradeView(stockModel: self.stockModel, tradeSheet: self, stockDetailsView: self.stockDetailsView, allStocksSold: self.allStocksSold, viewModel: self.viewModel)
        })
        .toast(isShowing: $isShowingToast, text: toastMessage)
        .font(.title)
        .padding()
    }
}
